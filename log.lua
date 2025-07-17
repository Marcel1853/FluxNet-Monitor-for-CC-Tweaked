-- log.lua (robust mit Rotation)
local log = {}

local LOG_DIR = "/logs"
local LOG_FILE = LOG_DIR .. "/log.json"
local MAX_LOG_SIZE = 50 * 1024 -- 50 KB

-- Stelle sicher, dass das Verzeichnis existiert
local function ensureLogDir()
    if not fs.exists(LOG_DIR) then
        fs.makeDir(LOG_DIR)
    end
end

-- Logrotation: alte Logs werden verschoben
local function rotateLogs()
    for i = 5, 1, -1 do
        local old = LOG_DIR .. "/log_" .. i .. ".json"
        local new = LOG_DIR .. "/log_" .. (i + 1) .. ".json"
        if fs.exists(old) then
            if fs.exists(new) then fs.delete(new) end
            fs.move(old, new)
        end
    end
    if fs.exists(LOG_FILE) then
        fs.move(LOG_FILE, LOG_DIR .. "/log_1.json")
    end
end

-- Füge neuen Eintrag hinzu
function log.add(level, message, data)
    ensureLogDir()

    if fs.exists(LOG_FILE) and fs.getSize(LOG_FILE) > MAX_LOG_SIZE then
        rotateLogs()
    end

    local logs = {}
    if fs.exists(LOG_FILE) then
        local file = fs.open(LOG_FILE, "r")
        local content = file.readAll()
        file.close()
        if content and #content > 0 then
            local parsed = textutils.unserializeJSON(content)
            if type(parsed) == "table" then
                logs = { table.unpack(parsed) }
            end
        end
    end

    table.insert(logs, {
        time = os.time(),
        level = level,
        message = message,
        data = data
    })

    local file = fs.open(LOG_FILE, "w")
    file.write(textutils.serialiseJSON(logs))
    file.close()
end

-- Kurzformen
function log.error(m, d) log.add("ERROR", m, d) end

function log.warn(m, d) log.add("WARN", m, d) end

function log.info(m, d) log.add("INFO", m, d) end

function log.debug(m, d) log.add("DEBUG", m, d) end

-- Init wird automatisch ausgeführt
ensureLogDir()
return log
