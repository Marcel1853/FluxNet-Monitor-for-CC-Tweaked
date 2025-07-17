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

-- Alle Dateien wurden erfolgreich heruntergeladen
print("All files have been downloaded!")
print("FluxNet Monitor was successfully installed!")
print("Reboot in 5 seconds...")
sleep(5) -- Kurze Pause für die Anzeige der Nachricht
shell.run("reboot") -- Optional: Neustart des Systems nach der Installation