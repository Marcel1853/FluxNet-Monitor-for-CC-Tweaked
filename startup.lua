local log = require("log")
local ui = require("network_ui")
local themes = require("themes")

-- Theme selection: "default", "blue"
--local theme = themes.default
local theme = themes.blue

local function safeWrap(name)
    local ok, dev = pcall(peripheral.wrap, name)
    if ok and dev then return dev end
    return nil
end

local function findControllers()
    local ctrls = {}
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.getType(name) == "fluxnetworks:flux_controller" then
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
    log.info("Program started")

    local monitors = findMonitors()
    if #monitors == 0 then
        print("No monitor found!")
        log.error("No monitor found!")
        return
    end

    local controllers = findControllers()
    if #controllers == 0 then
        for _, monitor in ipairs(monitors) do
            monitor.setCursorPos(2, 2)
            monitor.setTextColor(theme.error)
            monitor.write("No Flux Controller found.")
        end
        sleep(3)
        return
    end

    for _, monitor in ipairs(monitors) do
        monitor.setBackgroundColor(theme.background)
        monitor.setTextColor(theme.text)
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.write("Loading Flux Networks...")
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

    -- Cache für NetworkStats
    local statsCache = {}
    local function updateStatsCache()
        while true do
            for i, ctrl in ipairs(controllers) do
                if ctrl and ctrl.networkStats then
                    local okStats, stats = pcall(function()
                        return ctrl:networkStats()
                    end)
                    local okName, netName = pcall(function()
                        return ctrl:getNetworkName()
                    end)
                    if okStats and stats then
                        statsCache[i] = {
                            stats = stats,
                            networkName = okName and netName or "?"
                        }
                    end
                end
            end
            sleep(1) -- Update-Rate
        end
    end

    local function drawTabs(win, mW, mH, thisTab)
        local tabWidth = math.floor(mW / #controllers)
        for i = 1, #controllers do
            local netName = statsCache[i] and statsCache[i].networkName or "?"
            local label = netName .. " "
            local x = (i - 1) * tabWidth + 1
            win.setBackgroundColor(i == thisTab and theme.tab_active_bg or theme.tab_bg)
            win.setTextColor(i == thisTab and theme.tab_active_text or theme.tab_text)
            win.setCursorPos(x, 1)
            win.write(label .. string.rep(" ", math.max(0, tabWidth - #label)))
        end
    end

    local function drawContent()
        for monitorIdx, win in ipairs(monitors) do
            local mW, mH = win.getSize()
            local thisTab = tab[monitorIdx]

            -- Nur clear, wenn Tab gewechselt hat
            if thisTab ~= lastTab[monitorIdx] then
                win.setBackgroundColor(theme.background)
                win.clear()
                lastTab[monitorIdx] = thisTab
            end

            -- Hole Cache für diesen Tab
            local cache = statsCache[thisTab]
            if not cache then
                drawTabs(win, mW, mH, thisTab)
                win.setCursorPos(5, 5)
                win.write("Loading...")
            end

            local stats = cache.stats or {}
            local networkName = cache.networkName or "?"

            -- Tabs zeichnen
            drawTabs(win, mW, mH, thisTab)

            -- ===== Ab hier wie dein bisheriger Anzeige-Code =====
            local boxCols = mW >= 30 and 3 or (mW >= 20 and 2 or 1)
            local boxW = math.floor((mW - 2 * boxCols) / boxCols)
            local boxH = mH >= 16 and 4 or 3
            local padX, padY, startY = 2, 1, 3

            chartHeight = math.max(3, math.min(8, mH - (startY + boxH * math.ceil(8 / boxCols) + 5)))
            maxChartPoints = math.max(10, mW - 4)

            local energy = stats.energy or 0
            local capacity = stats.energyCapacity or 1
            local percent = capacity > 0 and energy / capacity or 0

            inputHistory[thisTab] = inputHistory[thisTab] or {}
            outputHistory[thisTab] = outputHistory[thisTab] or {}
            table.insert(inputHistory[thisTab], stats.energyInput or 0)
            table.insert(outputHistory[thisTab], stats.energyOutput or 0)
            if #inputHistory[thisTab] > maxChartPoints then table.remove(inputHistory[thisTab], 1) end
            if #outputHistory[thisTab] > maxChartPoints then table.remove(outputHistory[thisTab], 1) end

            local function shortLabel(label, value, boxWidth)
                local txt = label .. ": " .. value
                if boxWidth < 10 then
                    txt = value
                elseif #txt > boxWidth then
                    local shortL = label:sub(1, 1) .. ":"
                    txt = shortL .. " " .. value
                    if #txt > boxWidth then
                        txt = string.sub(txt, 1, boxWidth - 1) .. "…"
                    end
                end
                return txt
            end

            local totalConnections = stats.connectionCount or 0
            local points = stats.pointCount or 0
            local controller = stats.controllerCount or 0
            local storages = stats.storageCount or 0
            local plugs = totalConnections - (points + storages + controller)

            local labels = {
                { "Energy",            shortNumber(energy) .. " / " .. shortNumber(capacity) .. " FE", theme.text },
                { "Energy %",          string.format("%.1f%%", percent * 100),                         theme.text },
                { "Total Connections", tostring(totalConnections),                                     theme.text },
                { "Plugs",             tostring(plugs),                                                theme.text },
                { "Points",            tostring(points),                                               theme.text },
                { "Storages",          tostring(storages),                                             theme.text },
                { "Input",             shortNumber(stats.energyInput or 0) .. " FE/t",                 theme.input or colors.lime },
                { "Output",            shortNumber(stats.energyOutput or 0) .. " FE/t",                theme.output or colors.red },
            }

            for i, v in ipairs(labels) do
                local col = (i - 1) % boxCols
                local row = math.floor((i - 1) / boxCols)
                local x = 2 + col * (boxW + padX)
                local y = startY + row * (boxH + padY)

                local fg = v[3]
                local isSpecial = (fg == (theme.input or colors.lime) or fg == (theme.output or colors.red))
                local bg = isSpecial and colors.black or theme.tab_bg

                local boxText = shortLabel(v[1], v[2], boxW)
                ui.drawBox(win, x, y, boxW, boxH, bg, fg, boxText)
            end

            local barY = startY + math.ceil(#labels / boxCols) * (boxH + padY)
            ui.drawBarWithPercent(win, 2, barY, mW - 4, 1, percent)

            local chartY = barY + 2
            ui.drawBarChart(win, 2, chartY, mW - 4, chartHeight, inputHistory[thisTab], outputHistory[thisTab])

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

    parallel.waitForAny(
        updateStatsCache, -- Cache-Updater
        function()
            while true do
                sleep(0.2)
                drawContent()
            end
        end,
        function()
            while true do
                local event, side, x, y = os.pullEvent("monitor_touch")
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
    log.error("Critical error", { error = err })
    print("A critical error occurred - see log.json")
end
