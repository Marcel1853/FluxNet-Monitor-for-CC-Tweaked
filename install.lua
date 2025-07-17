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
print("Alle Dateien wurden geladen!")
print("FluxNet Monitor wurde erfolgreich installiert!")
print("Reboot in 5 Sekunden...")
sleep(5) -- Kurze Pause für die Anzeige der Nachricht
shell.run("reboot") -- Optional: Neustart des Systems nach der Installation