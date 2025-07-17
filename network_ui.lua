local ui = {}

-- Zeichnet eine gefüllte Box mit optionalem Text
function ui.drawBox(win, x, y, w, h, bgColor, fgColor, text)
    win.setBackgroundColor(bgColor)
    win.setTextColor(fgColor)
    for i = 0, h - 1 do
        win.setCursorPos(x, y + i)
        win.write(string.rep(" ", w))
    end
    if text then
        local tx = x + math.floor((w - #text) / 2)
        local ty = y + math.floor(h / 2)
        win.setCursorPos(tx, ty)
        win.write(text)
    end
end

-- Zeichnet einen Balken mit Prozentanzeige
function ui.drawBarWithPercent(win, x, y, w, h, percent)
    local fillW = math.floor((w - 2) * percent)
    local emptyW = (w - 2) - fillW
    local percentText = string.format("%.1f%%", percent * 100)
    local textX = x + math.floor((w - #percentText) / 2)

    -- Hintergrund
    win.setBackgroundColor(colors.gray)
    win.setCursorPos(x, y)
    win.write(string.rep(" ", w))

    -- Füllung
    if fillW > 0 then
        win.setBackgroundColor(colors.lime)
        win.setCursorPos(x + 1, y)
        win.write(string.rep(" ", fillW))
    end

    -- Leer
    if emptyW > 0 then
        win.setBackgroundColor(colors.red)
        win.setCursorPos(x + 1 + fillW, y)
        win.write(string.rep(" ", emptyW))
    end

    -- Prozent-Text zentriert, Farbe je nach Position
    local percentPos = textX - x
    local bgColor = colors.gray
    if percentPos >= 1 and percentPos <= fillW then
        bgColor = colors.lime
    elseif percentPos > fillW and percentPos <= fillW + emptyW then
        bgColor = colors.red
    end
    win.setBackgroundColor(bgColor)
    win.setTextColor(bgColor == colors.lime and colors.black or colors.white)
    win.setCursorPos(textX, y)
    win.write(percentText)

    -- Reset
    win.setBackgroundColor(colors.black)
    win.setTextColor(colors.white)
end

-- Zeichnet ein Balkendiagramm (Input: grün, Output: rot)
function ui.drawBarChart(win, x, y, w, h, inputData, outputData)
    local maxVal = 1
    for _, v in ipairs(inputData) do if v > maxVal then maxVal = v end end
    for _, v in ipairs(outputData) do if v > maxVal then maxVal = v end end

    local len = math.min(#inputData, w)
    for i = 1, len do
        local inVal = inputData[#inputData - len + i] or 0
        local outVal = outputData[#outputData - len + i] or 0

        local inH = math.floor((inVal / maxVal) * h)
        local outH = math.floor((outVal / maxVal) * h)

        for row = 0, h - 1 do
            win.setCursorPos(x + i - 1, y + h - row - 1)
            if row < inH then
                win.setBackgroundColor(colors.lime)
            elseif row < inH + outH then
                win.setBackgroundColor(colors.red)
            else
                win.setBackgroundColor(colors.black)
            end
            win.write(" ")
        end
    end

    win.setBackgroundColor(colors.black)
    win.setTextColor(colors.white)
end

return ui
