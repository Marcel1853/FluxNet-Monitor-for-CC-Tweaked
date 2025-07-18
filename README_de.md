# FluxNet-Monitor für CC: Tweaked

Dieses Projekt zeigt die wichtigsten Statistiken und den Energiefluss von [Flux Networks x CC: Tweaked](https://www.curseforge.com/minecraft/mc-mods/flux-network-x-cc-tweaked) auf einem oder mehreren Computercraft-Monitoren an.

## Features

- Übersicht über alle Flux-Controller im Netzwerk
- Tabs für mehrere Netzwerke/Controller
- Live-Anzeige von Energie, Input/Output, Buffer, Verbindungen, Points, Storages, Plugs
- Automatische Skalierung für kleine und große Monitore
- Touch-Unterstützung: Tab-Wechsel, Reset, Reboot
- Logging mit Rotation (log.json im `/logs`-Ordner)
- Mehrere Themes (Farbschemata) auswählbar

## Voraussetzungen

- [CC: Tweaked](https://modrinth.com/mod/cc-tweaked) (Computercraft für moderne Minecraft-Versionen)
- [Flux Networks x CC: Tweaked](https://www.curseforge.com/minecraft/mc-mods/flux-network-x-cc-tweaked)
- Ein Computer (oder Advanced Computer) mit angeschlossenem Monitor
- Optional: Mehrere Monitore für Multi-Display

**Hinweis:**  
Das Programm ist für Monitore mit mindestens 6x5 Blöcken optimiert.  
Mit dieser Größe (oder größer) sieht die Anzeige am besten aus und alle Funktionen sind gut lesbar.

## Installation

**Variante 1: Manuell kopieren**

1. Kopiere alle `.lua`-Dateien (`startup.lua`, `log.lua`, `network_ui.lua`, `themes.lua`) in den Computer-Ordner (`computercraft/computer/<ID>/`).
2. Passe das Theme in `startup.lua` an (z. B. `local theme = themes.default` oder `themes.blue`).
3. Starte den Computer – das Programm läuft automatisch.

**Variante 2: Automatische Installation mit einem Befehl**

Führe im CC: Tweaked-Terminal folgenden Befehl aus, um alle Dateien automatisch zu laden:

```
wget run https://raw.githubusercontent.com/Marcel1853/FluxNet-Monitor-for-CC-Tweaked/main/install.lua
```

Das Installationsskript lädt alle benötigten Dateien und startet das Programm.

## Bedienung

- **Tab-Wechsel:** Tippe oben auf die Tab-Leiste des Monitors.
- **Reset Tab:** Tippe auf „Reset Tab“ unten, um die Verlaufsgrafik zurückzusetzen.
- **Reboot PC:** Tippe auf „Reboot PC“, um den Computer neu zu starten.
- **Mehrere Monitore:** Jeder Monitor kann unabhängig bedient werden.

## Hinweise

- Die Anzeige passt sich automatisch an die Monitorgröße an.
- Große Zahlen werden als „1.2k“, „3.4M“ usw. angezeigt.
- Logdateien findest du im `/logs`-Ordner auf dem Computer.

## Support

Fragen, Fehler oder Wünsche?  
Erstelle ein Issue oder kontaktiere mich direkt!

## Screenshots

![Monitoranzeige mit Tab und Diagramm](img/monitor.png)
![Mehrere Monitore und Netzwerke](img/monitore.png)
![FluxNet Verkabelung und Controller](img/connecte_conkollers.png)
![Seitenansicht Monitor und Kabel](img/connected_monitors.png)

Weitere Beispielanzeige mit aktiviertem blauen Theme:
![Anzeige mit blauem Theme](img/blue_thema.png.png)


---

**Mods benötigt:**
- [CC: Tweaked (Modrinth)](https://modrinth.com/mod/cc-tweaked)
- [Fluy Networks (CurseForge)](https://www.curseforge.com/minecraft/mc-mods/flux-networks)
- [Flux Networks x CC: Tweaked (CurseForge)](https://www.curseforge.com/minecraft/mc-mods/flux-network-x-cc-tweaked)