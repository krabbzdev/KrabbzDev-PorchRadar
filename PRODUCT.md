# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Stack

Existing codebase: Node.js back end (`server.js`, no dependencies) and a single-file front end (`index.html`, Leaflet maps). Shipped as a Windows `.exe` and installer built by GitHub Actions.

## Users

Home plane-spotters: hobbyists and curious neighbours who install Porch Radar on a Windows PC at home and watch the planes flying over their own house. Some run it on a spare monitor or TV (the Flight Wall); others open the dashboard from a phone or tablet on home Wi-Fi.

## Product Purpose

A live dashboard of the planes flying over your house. It shows a map of everything nearby and takes over the screen with a close-up and a spoken alert when a plane passes right overhead. Success is the owner noticing the planes they care about, without having to go looking.

## Positioning

Personal to your own sky and private by design: centred on your house (overhead alerts, favorites and a Watch list, spoken announcements, a Flight Wall of only what passes within 2 nm), and a single local `.exe` with no account, no tracking, and settings that stay on your PC.

## Operating Context

Runs on any Windows PC from one `.exe` (installs without admin rights) and is opened in a browser at `localhost:8090`. Reachable from phones and tablets on the home network only if the owner turns on Settings, Network. Live aircraft data comes from adsb.fi, with an optional OpenSky backup feed. Updates itself from GitHub releases.

## Capabilities and Constraints

- Live map of aircraft (default 20 mile radius), airports, weather radar, FAA charts, TFRs, optional ships.
- Overhead Plane Alert, Flight Wall (full-screen split-flap board), favorites and Watch list with gold alerts, plane finder, tail-number panel, daily log.
- Personal, non-commercial use; data sources carry their own terms.
- Every input, select, textarea and button must have a tooltip or title (enforced by the page self-test in CI).
- Back end has no dependencies; secrets such as OpenSky credentials live only in each install's `settings.json`.

## Brand Commitments

Product name: "KrabbzDev's Porch Radar", by Charles Love (Krabbz9999). Public repo github.com/krabbzdev/KrabbzDev-PorchRadar, MIT licence. Voice is friendly and plain-spoken.

## Evidence on Hand

README with feature list, data-source credits and privacy statement; guide pictures are labelled as illustrations with sample data. No testimonials, user counts or benchmarks exist; do not invent them.

## Product Principles

- Your house is the centre of the map, and the product is about what passes it.
- Private and local first: no accounts, no tracking, settings stay on the PC.
- Noticing beats browsing: important planes (overhead, favorites, Watch list) must be impossible to miss.
- Free to run, one download, nothing else to install.
- Credit the data sources and respect their terms.

## Accessibility & Inclusion

No specific standard has been set. Existing requirement: every control has a tooltip or title. Alerts are spoken as well as shown.
