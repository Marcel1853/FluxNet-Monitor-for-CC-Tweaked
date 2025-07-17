-- install.lua
local files = {
    "startup.lua",
    "log.lua",
    "network_ui.lua",
    "themes.lua"
}
local base = "https://raw.githubusercontent.com/Marcel1853/FluxNet-Monitor-for-CC-Tweaked/main/"
for _, file in ipairs(files) do
    shell.run("wget", base .. file, file)
end
print("Alle Dateien wurden geladen!")
