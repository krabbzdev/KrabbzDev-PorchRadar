# KrabbzDev's Porch Radar

[![Install now](https://img.shields.io/badge/Install_now-Windows_installer-0048FE?style=for-the-badge&logo=windows&logoColor=white)](https://github.com/krabbzdev/KrabbzDev-PorchRadar/releases/latest/download/KrabbzDev-PorchRadar-Setup.exe)

By **Charles Love** (Krabbz9999).

A live dashboard of the planes flying over your house. Runs on any Windows PC as a single `.exe`,
shows a map of everything nearby, and takes over the screen with a close-up and a spoken alert
when a plane passes right overhead.

## Install

1. Download **`KrabbzDev-PorchRadar-Setup.exe`** from the [latest release](../../releases/latest) and run it.
   - Windows may say *"Windows protected your PC"* because the app isn't code-signed.
     Click **More info → Run anyway**.
   - It installs for you only, **without admin rights**, into
     `C:\Users\Public\Apps\KrabbzDev-PorchRadar`, with a Start menu entry. Optional: a desktop
     shortcut, and starting with Windows (in the tray, without opening the browser).
2. Your browser opens the dashboard at `http://localhost:8090`. The first time, it asks for your
   **ZIP code or address**. That's it.

Nothing else to install: no Node.js, no accounts. The dashboard opens only on the PC it's installed on,
unless you turn on **Settings → Network** to let phones and tablets on your home Wi-Fi watch it too. To stop it, right-click the ✈ tray icon → **Quit**. To uninstall, use Windows
**Settings → Apps** (your settings and log are left in the install folder; delete it to remove them).

The plain `KrabbzDev-PorchRadar.exe` is in each release too: it's what installed copies update
themselves from, and it still runs on its own from any folder.

## Support

If something goes wrong, **Settings → Help → Email debug log** (or the tray icon's menu)
opens an email with the app's log attached.

Got an idea or found a bug? Press the floating **💬 Feedback** button in the app, or use **Send feedback** in Settings → Help (or the tray icon's right-click menu): it opens a
pre-filled issue on this project's GitHub page (nothing is sent until you press Submit there), or you can copy the text.

If Porch Radar makes you smile, you can [buy me a coffee](https://buymeacoffee.com/krabbzdev).

[![Buy me a coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-FFDD00?style=for-the-badge&logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/krabbzdev)

## Updates

The app checks this repository's releases a minute after it starts and every 6 hours. When there's a
newer build it downloads it, swaps itself and restarts, and open pages reload onto the new version.
You can turn that off, or check now, under **⚙ Settings → Updates**. The build number is shown in the
bottom-right corner.

## Features

- **Live map** of aircraft around home (default 20 mile radius), with airports, your home and an optional office
- **Weather overlay**: live rain radar on the map (US, NWS NEXRAD via Iowa Environmental Mesonet), switched on with 🌧 Weather, plus an optional world rain radar from RainViewer and an optional NOAA infrared satellite picture of the clouds
- **Map styles**: Esri Dark, Light, Streets, Topographic and Satellite, OpenStreetMap, five OpenFreeMap styles, and NASA's satellite picture from yesterday with its clouds
- **Aeronautical charts**: the FAA's VFR Sectional, VFR Terminal Area, IFR Low and IFR High Enroute charts under the map, picked with 🗺 Chart (US, not for navigation)
- **Airspace outlines** (US, optional): the FAA's Special Use Airspace (restricted, prohibited, warning and alert areas and military operations areas) and the boundaries of the air route traffic control centers, switched on in Map Options. Not for navigation, and they don't show when an area is active
- **For pilots**: airport weather dots coloured by flying conditions (VFR / MVFR / IFR / LIFR), the FAA's temporary flight restrictions (TFRs) as red areas, a day/night line, a distance and heading tool, the likely runway in use and sunrise/sunset on airport cards, squawk, vertical speed and pressure + GPS altitude on planes, and knots / nautical miles as an option
- **Cruise ships and boats** (optional, free): live ship positions from [AISStream.io](https://aisstream.io), with cruise ships highlighted and listed in a Cruise ships panel. Needs your own free AISStream key (Settings → More)
- **Tray icon**: a ✈ in the Windows system tray while it runs; click to open the dashboard, right-click → Quit to stop it (a tiny helper, tray/Tray.cs, carried inside the .exe and unpacked next to it)
- **Overhead Plane Alert**: inside the overhead circle (1 mile to start, adjustable), a full-screen close-up with the flight path,
  predicted closest approach, where it's from and going, plus a chime and an upbeat spoken alert with the plane type, speed,
  altitude and destination. You can rewrite what it says in Settings → Alerts (🔔 Sound toggle)
- **Airport and helipad details**: click any airport, heliport or seaplane base for its runways or helipads, radio
  frequencies, current weather, planes arriving and leaving right now, a Wikipedia summary and handy links
- **Planned route**: click a plane to draw its route on the map, from its departure airport to its destination
- **Aircraft details**: photo, maker and model, airline, owner, route, altitude, speed and time tracked
- **Flight Wall**: the 🧱 Flight Wall button in the top bar opens it in its own window (drag it to a second screen, press F for full screen; if the browser blocks pop-ups it goes full screen in the same page) with an airport split-flap board look: the
  airline logo (or a text tile), flight number, route, aircraft type and photo (when there are several photos they flip every 2 seconds), altitude, speed, heading and distance, and
  a line showing the path of the flight beside a small map of where the plane is right now, for each plane within 2 nm of home (and for 5 minutes after it passes, marked "Left N min ago"), plus the time it was seen in 24-hour time and the plane's age when known, 8 seconds each (click for the next, ✕ Close
  to close the window). Good for a spare monitor or TV
- **Backup plane feed**: optional. Add your own OpenSky API client in Settings (Flights) and the app falls back to OpenSky, at most every 30 seconds, whenever adsb.fi is down
- **Favorite planes**: star any plane (or type its tail number) and the app watches for it worldwide, shows whether
  it's flying now or where it was last seen. When one is in range (or a plane matching your Watch list is) it can't be missed: a gold banner across the top, a
  glowing star on its map marker, a spoken alert (outside quiet hours), and a badge on the Flight Wall. A few planes are
  there from the start (N711MG, N29UB, N247WE, N628TS, N7478D, and the two Air Force One jets); remove any you don't want and it stays removed
- **Plane finder**: type a tail number (like N1932K) in the Jump to box to go to the plane, live, or to where the app
  last heard it
- **Tail-number panel**: click any registration for owner and registration details and a flight-path map
- **ADS-B Exchange viewer** for any plane, without leaving the dashboard
- **Military / interesting / emergency** aircraft highlighted, with pop-up alerts. The plane-alert list of interesting planes (governments, military, police, medical, historic and odd ones) adds thousands more, each with what it is, switched with ★ Interesting planes in Map Options
- **Today's log**: aircraft count, by-hour chart and leaderboards (closest, lowest, fastest, highest, airlines, types)
- **FlightAware feeder stats** if you feed FlightAware (add your username in Settings)

## Settings (⚙)

Everything personal is stored in `settings.json` next to the `.exe`, so each installation is its own:
home address, an optional office, your FlightAware username, and an optional contact for photo lookups.

## Data sources and credits

| What | Source |
|---|---|
| Live aircraft | [adsb.fi](https://adsb.fi) open data (free for personal, non-commercial use) |
| Photos | [Planespotters.net](https://www.planespotters.net), then [Airport-Data.com](https://airport-data.com) (photographer credited), else a stock model photo from [Wikipedia](https://www.wikipedia.org) |
| Aircraft and owner info | [adsbdb](https://www.adsbdb.com), optional FAA registry file |
| Interesting planes | [plane-alert-db](https://github.com/sdr-enthusiasts/plane-alert-db) by SDR-Enthusiasts and contributors, under the [Open Database License](https://opendatacommons.org/licenses/odbl/1.0/); downloaded from GitHub once a day |
| Routes | [adsb.lol](https://adsb.lol) route data, adsbdb |
| Airports, runways, radio frequencies | [OurAirports](https://ourairports.com) (public domain) |
| Airport weather | [NOAA Aviation Weather Center](https://aviationweather.gov) (US government, public domain) |
| Airline logos | [sexym0nk3y/airline-logos](https://github.com/sexym0nk3y/airline-logos) via jsDelivr (logos are trademarks of their airlines) |
| Aeronautical charts | [FAA Aeronautical Information Services](https://www.faa.gov/air_traffic/flight_info/aeronav/digital_products/) (US government, public domain) |
| Airport weather (METARs) | [NOAA Aviation Weather Center](https://aviationweather.gov) (US government, public domain) |
| Temporary flight restrictions | [FAA TFR list](https://tfr.faa.gov) (US government, public domain) |
| Special Use Airspace and ARTCC boundaries | [FAA Aeronautical Information Services](https://www.faa.gov/air_traffic/flight_info/aeronav/aero_data/) open data (US government, public domain), downloaded once a week |
| Weather radar | NWS NEXRAD via [Iowa Environmental Mesonet](https://mesonet.agron.iastate.edu) (US); [RainViewer](https://www.rainviewer.com) for the optional world rain radar; [NOAA nowCOAST](https://nowcoast.noaa.gov) for the optional infrared satellite picture |
| Ships (optional) | [AISStream.io](https://aisstream.io) live AIS data, with your own free API key |
| Kokoro voices (optional) | [Kokoro-82M](https://huggingface.co/hexgrad/Kokoro-82M) via [kokoro-js](https://github.com/hexgrad/kokoro) (Apache 2.0), downloaded on first use from jsDelivr and Hugging Face; runs in your browser |
| Map | Esri maps (Dark Gray by default), or, if you pick those styles, [OpenStreetMap](https://www.openstreetmap.org/copyright) tiles, [OpenFreeMap](https://openfreemap.org) vector maps (which load the MapLibre GL library from cdnjs and jsDelivr the first time you pick one) or NASA [GIBS](https://www.earthdata.nasa.gov/engage/open-data-services-software/earthdata-developer-portal/gibs-api) satellite imagery; [Leaflet](https://leafletjs.com) |
| Address lookup | [OpenStreetMap Nominatim](https://nominatim.org) |

**Software and fonts we build on:** [Leaflet](https://leafletjs.com), [MapLibre GL JS](https://maplibre.org) (only for the OpenFreeMap styles), [Node.js](https://nodejs.org), [Inter](https://rsms.me/inter/) and [JetBrains Mono](https://www.jetbrains.com/lp/mono/) (Google Fonts), [Inno Setup](https://jrsoftware.org/isinfo.php) for the installer, and [postject](https://github.com/nodejs/postject) and [rcedit](https://github.com/electron/rcedit) in the build. Also: [LiveATC.net](https://www.liveatc.net) (listen-to-ATC links), [Zippopotam.us](https://zippopotam.us) (ZIP code lookup), and links out to ADS-B Exchange, Flightradar24, AirNav, SkyVector and JetPhotos. The same list is in the app under Settings, Credits, and a short form runs along the bottom of the Flight Wall.

Each service has its own terms; this project is for personal, non-commercial use.

## Optional: full FAA owner records

US registration details (co-owners, city/state, serial number, registration dates) come from the FAA.
Open a plane's panel and press **Get the full FAA record** (or **Download the FAA registry** in Settings, Flights): the app
downloads a small ready-made file from this project's GitHub (rebuilt monthly from the FAA's public
[ReleasableAircraft.zip](https://registry.faa.gov/database/ReleasableAircraft.zip)), or the FAA's own 73 MB file if that isn't
there yet, into its own folder and reads it, with nothing else to do. It happens once; the app never updates it on its
own, and **Update now** in Settings, Flights fetches fresh records whenever you like. You can still download the FAA file
yourself and put it next to the `.exe`. Street addresses are never shown.

## Building from source

Needs [Node.js](https://nodejs.org) 22+ (24 recommended).

```bat
node server.js        rem run from source at http://localhost:8090
build-exe.cmd         rem build KrabbzDev-PorchRadar.exe locally, for testing (and the installer, if Inno Setup 6 is installed)
release.cmd "notes"   rem bump the build number, tag and push; GitHub builds and publishes the release
```

`server.js` is the whole back end (no dependencies) and `index.html` is the whole front end.
Published `.exe` files are always built from this repository by
[GitHub Actions](.github/workflows/release.yml), never on a personal computer.

## Security

Found a security problem? Please report it privately through [GitHub's private form](https://github.com/krabbzdev/KrabbzDev-PorchRadar/security/advisories/new) (see [SECURITY.md](SECURITY.md)), not in a public issue.

## Privacy

The full statement is in [PRIVACY.md](PRIVACY.md). In short:

This program does not collect, store or send personal information to the author, and has no
analytics or tracking. Your settings stay in `settings.json` next to the program. To do its job it
contacts these services directly from your computer:

- **adsb.fi**: your home's map coordinates, to ask which aircraft are nearby; tail numbers you search for, and your favorite planes' codes, to find them
- **OpenSky Network** (only if you add your own OpenSky API client in Settings, and only while adsb.fi is failing): a box of map coordinates around your home, to ask which aircraft are nearby
- **OpenStreetMap Nominatim**: an address you type into Settings, to find its coordinates
- **Planespotters.net, Airport-Data.com, adsbdb, adsb.lol, Wikipedia**: aircraft identifiers, callsigns and registrations, to look up photos, owners and routes
- **FlightAware**: the feeder username in Settings, to show its public stats page
- **GitHub**: to check for and download updates, and the plane-alert list of interesting planes (once a day; nothing about you is sent)
- **aviationweather.gov**: the area the map is showing (for the airport weather dots), and an airport's code or position when you click it
- **tfr.faa.gov**: nothing about you; the app downloads the list of current TFRs
- **FAA open data (services6.arcgis.com)**: nothing about you; the app downloads the airspace outlines once a week
- **Esri** (map tiles), **OpenStreetMap**, **OpenFreeMap** and **NASA GIBS** (map tiles and styles, only if you pick one of those map styles), **RainViewer** (only if you turn on the world rain radar), **NOAA nowCOAST** (only if you turn on the infrared satellite), **OurAirports** (airport list), **jsDelivr** (airline logos), **Iowa Environmental Mesonet** (weather radar), **AISStream.io** (only if you add a key: the area around your home, so it can send the ships there), **ADS-B Exchange** (only when you open its viewer), **jsDelivr** and **Hugging Face** (the Kokoro voice files, only if you pick a Kokoro voice; the words spoken never leave your PC)

## License

[MIT](LICENSE) © 2026 Charles Love (Krabbz9999)
