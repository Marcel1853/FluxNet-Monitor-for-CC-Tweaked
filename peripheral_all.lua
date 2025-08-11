-- gib mir all peripheral geräte aus
local function safeWrap(name)
    local ok, dev = pcall(peripheral.wrap, name)
    if ok and dev then return dev end
    return nil
end
local function getPeripherals()
    local devices = {}
    for _, name in ipairs(peripheral.getNames()) do
        local dev = safeWrap(name)
        if dev then
            devices[name] = dev
        end
    end
    return devices
end

local function getPeripheral(name)
    local dev = safeWrap(name)
    if dev then
        return dev
    else
        error("No peripheral found with name: " .. name)
    end
end

local function getPeripheralType(name)
    local dev = getPeripheral(name)
    return dev.getType and dev.getType() or "Unknown"
end

local function getPeripheralMethods(name)
    local dev = getPeripheral(name)
    local methods = {}
    for k, v in pairs(dev) do
        if type(v) == "function" then
            table.insert(methods, k)
        end
    end
    return methods
end


local function getPeripheralInfo(name)
    local dev = getPeripheral(name)
    local info = {
        name = name,
        type = getPeripheralType(name),
        methods = getPeripheralMethods(name),
    }
    return info
end

local function listPeripherals()
    local devices = getPeripherals()
    local infoList = {}
    for name, dev in pairs(devices) do
        table.insert(infoList, getPeripheralInfo(name))
    end
    return infoList
end

-- prints all peripherals and their methods
local function printPeripherals()
    local devices = listPeripherals()
    for _, info in ipairs(devices) do
        print("Peripheral Name: " .. info.name)
        print("Type: " .. info.type)
        print("Methods: " .. table.concat(info.methods, ", "))
        print("-----")
    end
end

-- main function to run on startup
local function main()
    print("Starting up...")
    print("Available Peripherals:")
    printPeripherals()
    print("Startup complete.")
end

-- Run the main function
main()
