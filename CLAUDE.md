# CLAUDE.md — Navigationsdatei für dieses Repo

Dieses Repo enthält Seminar-Präsentationen für den Kurs **Advanced Data Models (SS 2026)**.
Für Romi (roman) ist nur **Gruppe 2 (Triple Stores)** relevant — alle anderen Gruppen ignorieren.

Und sonst eben die Dateien auf oberste Ebene wie `README.md`und `report.md`

---

## Relevanter Bereich: Gruppe 2 – Triple Stores

**Pfad:** `groups/group2-triple-stores/`

### Präsentationsstruktur / Gliederung
- `slides/final strucutre` — **Inhaltliche Hauptgrundlage**, detaillierter Slot-Plan (9 Slots, ~140 min), mit Entscheidungen, Aha-Momenten und offenen TODOs
- `slides/Presentation Structure renewed` — Überarbeitete, bewertungsoptimierte Folienstruktur mit Timing und Bewertungshinweisen
- `slides/Gliederung Vinz` — Vinzents Gliederungsvorschlag
- `slides/Mail Structure` — Kommunikationsstruktur (E-Mail-Entwurf)
- `slides/presentation_structure` — Ältere Strukturversion

### Demo
- `demo/files/demo_README.md` — **Hauptdoku für die Live-Demo**, erklärt alle 7 Queries Schritt für Schritt, Ablaufplan, Vorbereitung-Checkliste
- `demo/files/triplestore-demo/README.md` — Technische Demo-Doku (identischer Inhalt, leicht abweichende Version)
- `demo/files/triplestore-demo/docker-compose.yml` — Oxigraph Docker-Setup (Port 7878)
- `demo/files/triplestore-demo/run_demo.sh` — Automatisches Demo-Script
- `demo/files/triplestore-demo/data/universitaeten.ttl` — Turtle-Datensatz (4 Städte, 4 Unis, 3 Profs, 4 Studenten)

### SPARQL-Queries (in `demo/files/triplestore-demo/queries/`)
| Datei | Inhalt | Besonderheit |
|---|---|---|
| `01_alle_universitaeten.sparql` | Alle Unis | Einstieg |
| `02_unis_in_bw.sparql` | Filter auf Bundesland | Multi-Pattern, Unicode-Escape nötig |
| `03_studenten_uni_stuttgart.sparql` | Studenten an UniStuttgart | URI als harter Filter |
| `04_personen_OHNE_inferenz.sparql` | Alle Personen ohne Reasoning | Ergebnis: 0 Zeilen → Aha-Moment Teil 1 |
| `05_personen_MIT_inferenz.sparql` | Alle Personen mit Reasoning | `rdfs:subClassOf*` → 7 Zeilen → Aha-Moment Teil 2 |
| `06_count_pro_uni.sparql` | COUNT + GROUP BY | Aggregation |
| `07_federated_dbpedia.sparql` | SERVICE gegen DBpedia | Optional, braucht Internet |

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

---

## Was ignoriert werden kann

- `groups/group1-graph-databases/` bis `groups/group7-data-lakes/` — andere Gruppen, nicht relevant
- `groups/schedule.md` — Semesterplanung für alle Gruppen
- `report.md`, `cover.jpg`, `LICENSE` — Repo-Boilerplate
