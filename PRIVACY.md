# Privacy

Porch Radar runs on your own PC. It has no accounts, no analytics and no tracking, and it sends nothing to its author.

## What stays on your PC

- **Settings**: your home address and coordinates, an optional office, favorites, your Watch list, an optional FlightAware username, and any keys you add (AISStream, OpenSky). They are stored in `settings.json` next to the program.
- **The debug log**: `app.log` next to the program. It leaves your PC only if you choose **Email debug log** and send the email yourself.
- **Display choices**: theme, map style and similar options are kept in your browser.

Uninstalling leaves `settings.json` and the log in the install folder. Delete the folder to remove them.

## What leaves your PC

To do its job, the app contacts these services directly from your computer. Each one sees your internet address, as any website does, and has its own privacy policy.

| Service | What is sent | When |
|---|---|---|
| adsb.fi | Your home's map coordinates; tail numbers you search for; your favorite planes' codes | Always, to find aircraft |
| OpenSky Network | A box of map coordinates around your home, with your OpenSky API client | Only if you add an OpenSky client, and only while adsb.fi is failing |
| OpenStreetMap Nominatim | An address you type into Settings | When you look up an address |
| Planespotters.net, Airport-Data.com, adsbdb, adsb.lol, Wikipedia | Aircraft identifiers, callsigns and registrations | To look up photos, owners and routes |
| Esri | The map area you are looking at | Always, for map tiles |
| OpenStreetMap, OpenFreeMap, NASA GIBS | The map area you are looking at | Only if you pick one of those map styles |
| cdnjs, jsDelivr | Nothing about you; the MapLibre GL map library is downloaded | Only the first time you pick an OpenFreeMap style |
| Iowa Environmental Mesonet | The map area you are looking at | Only with the US weather radar on |
| RainViewer | The map area you are looking at | Only with the world rain radar on |
| NOAA nowCOAST | The map area you are looking at | Only with the infrared satellite on |
| aviationweather.gov | The map area, and an airport's code or position when you click it | For airport weather |
| tfr.faa.gov, OurAirports | Nothing about you; the app downloads public lists | Always |
| FAA aircraft registry (registry.faa.gov) | Nothing about you; the app downloads the public registry file | Only after you press Download the FAA registry in a plane's panel, then at start-up when the file is over 30 days old |
| FAA open data (services6.arcgis.com) | Nothing about you; the app downloads the airspace outlines | Once a week, only after you turn on Special Use Airspace or ARTCC boundaries |
| jsDelivr | Airline codes, for logos | Always |
| AISStream.io | The area around your home, with your AISStream key | Only if you add a key |
| FlightAware | The feeder username in Settings | Only if you add one |
| ADS-B Exchange | The plane you are viewing | Only when you open its viewer |
| jsDelivr, Hugging Face | Nothing about you; the voice files are downloaded | Only if you pick a Kokoro voice (the words spoken never leave your PC) |
| GitHub | Nothing about you; the app checks for and downloads updates, and downloads the plane-alert list of interesting planes once a day | Updates unless you turn them off; the list always |

## Other people on your network

The dashboard opens only on the PC it is installed on. If you turn on **Settings → Network**, phones and tablets on your home Wi-Fi can open it too. It is never published to the internet by the app.

## Feedback

**Send feedback** opens a pre-filled issue on this project's GitHub page. Nothing is sent until you press Submit there, and anything you submit is public.

## Changes

This page changes when the app starts or stops using a service. The history of this file shows every change.

This is a plain description of what the software does, not legal advice.
