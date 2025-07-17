local log = require("log")
local ui = require("network_ui")
local themes = require("themes")

-- Theme-Auswahl: "default", "blue"
local theme = themes.default

-- local theme = themes.blue

local function safeWrap(name)
    local ok, dev = pcall(peripheral.wrap, name)
    if ok and dev then return dev end
    return nil
end

local function findControllers()
    local ctrls = {}
    for _, name in ipairs(peripheral.getNames()) do
        local t = peripheral.getType(name)
        if t == "fluxnetworks:flux_controller" then
            local dev = safeWrap(name)
            if dev then table.insert(ctrls, dev) end
        end
    end
    return ctrls
end

local function findMonitors()
    local mons = {}
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.getType(name) == "monitor" then
            local mon = safeWrap(name)
            if mon then table.insert(mons, mon) end
        end
    end
    return mons
end

local function shortNumber(n)
    if n >= 1e9 then
        return string.format("%.1fG", n / 1e9)
    elseif n >= 1e6 then
        return string.format("%.1fM", n / 1e6)
    elseif n >= 1e3 then
        return string.format("%.1fk", n / 1e3)
    else
        return tostring(n)
    end
end

local function main()
    log.info("Programm gestartet")

    local monitors = findMonitors()
    if #monitors == 0 then
        print("Kein Monitor gefunden!")
        log.error("Kein Monitor gefunden!")
        return
    end

    local controllers = findControllers()
    if #controllers == 0 then
        for _, monitor in ipairs(monitors) do
            monitor.setCursorPos(2, 2)
            monitor.setTextColor(theme.error)
            monitor.write("Keine Flux-Controller gefunden.")
        end
        sleep(3)
        return
    end

    -- Initialisierung für alle Monitore
    for _, monitor in ipairs(monitors) do
        monitor.setBackgroundColor(theme.background)
        monitor.setTextColor(theme.text)
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.write("Lade Flux-Netzwerke...")
    end
    sleep(1)

    local tab = {}
    for i = 1, #monitors do
        tab[i] = 1
    end

    local inputHistory, outputHistory = {}, {}
    local maxChartPoints = 20
    local chartHeight = 8
    local lastTab = {}
    for i = 1, #monitors do
        lastTab[i] = tab[i]
    end

    local function resetHistory()
        inputHistory[tab] = {}
        outputHistory[tab] = {}
    end

    local function drawTabs(win, mW, mH, thisTab)
        local tabWidth = math.floor(mW / #controllers)
        for i = 1, #controllers do
            local label = " Netzwerk " .. i .. " "
            local x = (i - 1) * tabWidth + 1
            win.setBackgroundColor(i == thisTab and theme.tab_active_bg or theme.tab_bg)
            win.setTextColor(i == thisTab and theme.tab_active_text or theme.tab_text)
            win.setCursorPos(x, 1)
            win.write(label .. string.rep(" ", tabWidth - #label))
        end
    end

    local function drawContent()
        for monitorIdx, win in ipairs(monitors) do
            local mW, mH = win.getSize()
            local thisTab = tab[monitorIdx]

            -- Nur löschen, wenn Tab auf diesem Monitor gewechselt wurde
            if thisTab ~= lastTab[monitorIdx] then
                win.setBackgroundColor(theme.background)
                win.clear()
                lastTab[monitorIdx] = thisTab
            end

            -- Tabs immer zeichnen!
            drawTabs(win, mW, mH, thisTab)

            -- Dynamische Werte je nach Monitorgröße
            local boxCols = mW >= 30 and 3 or (mW >= 20 and 2 or 1)
            local boxW = math.floor((mW - 2 * boxCols) / boxCols)
            local boxH = mH >= 16 and 4 or 3
            local padX = 2
            local padY = 1
            local startY = 3

            chartHeight = math.max(3, math.min(8, mH - (startY + boxH * math.ceil(8 / boxCols) + 5)))
            maxChartPoints = math.max(10, mW - 4)

            local ctrl = controllers[thisTab]
            if not ctrl then return end

            local success, stats = pcall(ctrl.networkStats)
            if not success or not stats then return end

            local energy = ctrl.getEnergy() or 0
            local capacity = ctrl.getEnergyCapacity() or 1
            local percent = capacity > 0 and energy / capacity or 0

            inputHistory[thisTab] = inputHistory[thisTab] or {}
            outputHistory[thisTab] = outputHistory[thisTab] or {}
            table.insert(inputHistory[thisTab], stats.energyInput or 0)
            table.insert(outputHistory[thisTab], stats.energyOutput or 0)
            if #inputHistory[thisTab] > maxChartPoints then table.remove(inputHistory[thisTab], 1) end
            if #outputHistory[thisTab] > maxChartPoints then table.remove(outputHistory[thisTab], 1) end

            -- Im drawContent(), vor dem Labels-Array:
            local function shortLabel(label, value, boxWidth)
                local txt = label .. ": " .. value
                if boxWidth < 10 then
                    -- Nur Wert anzeigen, Label weglassen
                    txt = value
                elseif #txt > boxWidth then
                    -- Label abkürzen, z. B. "E:" statt "Energy:"
                    local shortL = label:sub(1, 1) .. ":"
                    txt = shortL .. " " .. value
                    if #txt > boxWidth then
                        txt = string.sub(txt, 1, boxWidth - 1) .. "…"
                    end
                end
                return txt
            end

            -- Labels wie gehabt, aber mit shortLabel:
            local totalConnections = stats.connectionCount or 0
            local points = stats.pointCount or 0
            local controller = stats.controllerCount or 0
            local storages = stats.storageCount or 0
            local plugs = totalConnections - (points + storages + controller)

            local labels = {
                { "Energy",           shortNumber(energy) .. " / " .. shortNumber(capacity) .. " FE", theme.text },
                { "Energy %",         string.format("%.1f%%", percent * 100),                         theme.text },
                { "Total Connections", tostring(totalConnections),                                    theme.text },
                { "Plugs",            tostring(plugs),                                                theme.text },
                { "Points",           tostring(points),                                               theme.text },
                { "Storages",         tostring(storages),                                             theme.text },
                { "Input",            shortNumber(stats.energyInput or 0) .. " FE/t",                 theme.input or colors.lime },
                { "Output",           shortNumber(stats.energyOutput or 0) .. " FE/t",                theme.output or colors.red },
            }

            -- Boxen dynamisch anordnen
            for i, v in ipairs(labels) do
                local col = (i - 1) % boxCols
                local row = math.floor((i - 1) / boxCols)
                local x = 2 + col * (boxW + padX)
                local y = startY + row * (boxH + padY)

                local fg = v[3]
                local isSpecial = (fg == (theme.input or colors.lime) or fg == (theme.output or colors.red))
                local bg = isSpecial and colors.black or theme.tab_bg

                -- Text dynamisch kürzen
                local boxText = shortLabel(v[1], v[2], boxW)

                ui.drawBox(win, x, y, boxW, boxH, bg, fg, boxText)
            end

            -- Energie-Balken
            local barY = startY + math.ceil(#labels / boxCols) * (boxH + padY)
            ui.drawBarWithPercent(win, 2, barY, mW - 4, 1, percent)

            -- Diagramm
            local chartY = barY + 2
            ui.drawBarChart(win, 2, chartY, mW - 4, chartHeight, inputHistory[thisTab], outputHistory[thisTab])

            -- Buttons ggf. kürzen
            win.setCursorPos(2, mH - 1)
            win.setBackgroundColor(theme.reset_bg)
            win.setTextColor(theme.text)
            win.write(mW >= 20 and " Reset Tab " or "Reset")

            win.setCursorPos(mW >= 20 and 16 or math.floor(mW / 2), mH - 1)
            win.setBackgroundColor(theme.reboot_bg)
            win.setTextColor(theme.text)
            win.write(mW >= 20 and " Reboot PC " or "Reboot")

            win.setBackgroundColor(theme.background)
            win.setTextColor(theme.text)
        end
    end

    local function handleTouch(x, y, monitorIdx)
        local win = monitors[monitorIdx]
        local mW, mH = win.getSize()
        if y == 1 then
            local tabWidth = math.floor(mW / #controllers)
            local clicked = math.floor((x - 1) / tabWidth) + 1
            if controllers[clicked] then
                tab[monitorIdx] = clicked
            end
        elseif y == mH - 1 then
            if x >= 2 and x < 13 then
                resetHistory()
            elseif x >= 16 and x < 27 then
                os.reboot()
            end
        end
    end

    drawContent()

    parallel.waitForAny(
        function()
            while true do
                sleep(2)
                drawContent()
            end
        end,
        function()
            while true do
                local event, side, x, y = os.pullEvent("monitor_touch")
                -- Finde den Monitor, der berührt wurde
                local monitorIdx = 1
                for i, mon in ipairs(monitors) do
                    if side == peripheral.getName(mon) then
                        monitorIdx = i
                        break
                    end
                end
                handleTouch(x, y, monitorIdx)
                drawContent()
            end
        end
    )
end

local ok, err = pcall(main)
if not ok then
    log.error("Kritischer Fehler", { error = err })
    print("Ein kritischer Fehler ist aufgetreten - siehe log.json")
end
