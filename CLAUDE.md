# CLAUDE.md — Navigationsdatei für dieses Repo

Dieses Repo enthält Seminar-Präsentationen für den Kurs **Advanced Data Models (SS 2026)**.
Für Romi (roman) ist nur **Gruppe 2 (Triple Stores)** relevant — alle anderen Gruppen ignorieren.

Und sonst eben die Dateien auf oberste Ebene wie `README.md` und `report.md`

## Aufgabenteilung Präsentation

**Roman präsentiert:** Data Structure · Query Model · Comparison
**Vinzent präsentiert:** Motivation · Conceptual Model · Architecture · Demo

---

## Relevanter Bereich: Gruppe 2 – Triple Stores

**Pfad:** `groups/group2-triple-stores/`
`report.md` enthält die Vorgaben des Professors, wie unsere Präsentation zu sein hat und wie sie bewertet wird. Dies ist natürlich ebenfalls sehr wichtig.

---

## Präsentationsstruktur — Übersicht der Slide-Dateien


### Sprechtext / Wissensbasis (pro Kapitel)
Unter `slides/chapter/` liegen ausformulierte Sprechtexte als Präsentationsgrundlage

### Strukturdateien (Archiv/Referenz)
Unter `slides/structure/` liegen ältere Gliederungsversionen und Hilfsdokumente:
| Datei | Rolle |
|---|---|
| `slides/structure/final strucutre.md` | Inhaltliche Hauptgrundlage (9 Slots, ~140 min, Aha-Momente, TODOs) |
| `slides/structure/Priorisierte Gliederung Vinz.md` | **Prio-Liste pro Kapitel (Prio 1/2/3)** — maßgeblich für Fokus und Tiefe |

`slides/präsentation_V*.html`enthält die finale Präsentation, immer einfach aktuellste Version anpassen. 
Für Anpassungen immer instructions slide desgin beachten! 




### Sonstige Vorlesungen

`slides/extraced other slides` Text aus pdf-Slides der anderen Gruppen extrahiert als Ideen / Inspo

## Themenstruktur & Prio-Listen pro Kapitel

Die **maßgebliche Prio-Quelle** ist `slides/Priorisierte Gliederung Vinz`.
Die inhaltliche Ausarbeitung steht in `slides/final strucutre`.

---

## Demo

- `demo/files/demo_README.md` — **Hauptdoku für die Live-Demo**, erklärt alle 7 Queries Schritt für Schritt, Ablaufplan, Vorbereitung-Checkliste
- `demo/files/triplestore-demo/docker-compose.yml` — Oxigraph Docker-Setup (Port 7878)
- `demo/files/triplestore-demo/run_demo.sh` — Automatisches Demo-Script
- `demo/files/triplestore-demo/README_demo.md` — Demo-Doku direkt im triplestore-demo Ordner
- `demo/files/triplestore-demo/data/` — Turtle-Datensätze
- `demo/files/triplestore-demo/queries/` — SPARQL-Queries (01–07)
- `demo/files/triplestore-demo.tar.gz` — Archiv des Demo-Setups


---

## Technisches Setup

```bash
# Demo starten
cd groups/group2-triple-stores/demo/files/triplestore-demo
docker-compose up -d
open http://localhost:7878
bash run_demo.sh
```

- **Tool:** Oxigraph (Rust-basiert, kein JVM, leichtgewichtig)
- **Daten laden:** `PUT /store?default` mit Turtle-File
- **SPARQL-Endpoint:** `http://localhost:7878/query`

---

## Kontext / Stand

- **Thema:** Semantic Triple Stores, RDF, SPARQL, Inferencing
- **Gruppe:** Roman Lahm + Vinzent Lahm
- **Branch:** `Lahms_Triplestores` (feature branch), `main` (upstream)
- **Kern-Aha-Moment der Präsentation:** Query 4 (0 Ergebnisse ohne Inferencing) → Query 5 (7 Ergebnisse mit `rdfs:subClassOf*`) — zeigt den fundamentalen Unterschied zu SQL und Property Graphs
- **Kritischer Restpunkt laut Gliederung:** Ontologien dürfen nicht zu oberflächlich behandelt werden, sonst wirkt alles wie „Graph DB + SPARQL"


