# CLAUDE.md — Navigationsdatei für dieses Repo

Dieses Repo enthält Seminar-Präsentationen für den Kurs **Advanced Data Models (SS 2026)**.
Für Romi (roman) ist nur **Gruppe 2 (Triple Stores)** relevant — alle anderen Gruppen ignorieren.

Und sonst eben die Dateien auf oberste Ebene wie `README.md` und `report.md`

---

## Relevanter Bereich: Gruppe 2 – Triple Stores

**Pfad:** `groups/group2-triple-stores/`

---

## Präsentationsstruktur — Übersicht der Slide-Dateien

| Datei | Rolle |
|---|---|
| `slides/final strucutre` | **Inhaltliche Hauptgrundlage** — 9 Slots, ~140 min, mit Entscheidungen, Aha-Momenten, TODOs |
| `slides/Priorisierte Gliederung Vinz` | **Prio-Liste pro Kapitel (Prio 1/2/3)** — maßgeblich für Fokus und Tiefe |
| `slides/Presentation Structure renewed` | Bewertungsoptimierte Folienstruktur mit Timing-Hinweisen |
| `slides/Gliederung Vinz` | Vinzents ursprünglicher Gliederungsvorschlag |
| `slides/presentation_structure` | Ältere Strukturversion mit Slide-Nummerierung |
| `slides/Mail Structure` | Kommunikationsstruktur / Abstimmungsnotizen |

---

## Themenstruktur & Prio-Listen pro Kapitel

Die **maßgebliche Prio-Quelle** ist `slides/Priorisierte Gliederung Vinz`.
Die inhaltliche Ausarbeitung steht in `slides/final strucutre`.

### 1. Motivation (10 min)
**Prio 1:** Schwachstellen relationaler DBs (starres Schema, keine Semantik, Join-Komplexität) · Grundidee RDF · AI-Relevanz (RAG, semantische Suche)
**Prio 2:** Vorteile Triplestores (vernetzte Daten, Wissensrepräsentation) · Wissensgraphen für Explainability · Anwendungsfälle (Knowledge Graphs, Linked Data)
**Prio 3:** Reales Beispiel (Google Knowledge Graph) · SQL vs. SPARQL Beispiel · Kurze Abgrenzung Property Graphs

### 2. Conceptual Model (15 min)
**Prio 1:** RDF-Struktur (Triple, gerichteter Graph, URIs, Literale, Blank Nodes) · RDFS, OWL, Ontologien · Inferenz (machine-readable) · Named Graphs · Unterschied zu Property Graphs
**Prio 2:** RDF Graph vs. RDF Dataset (Default Graph) · Semantik durch standardisierte Prädikate
**Prio 3:** Turtle-Syntax · Visualisierung RDF-Graph · Intuitive Inferenz-Erklärung

### 3. Data Structure (15 min)
> **Abgrenzung zu Conceptual Model:** Conceptual Model = logische Ebene (was ist ein Triple).
> Data Structure = physische/organisatorische Ebene (wie wird es gespeichert und warum ist das performant/flexibel).

**Prio 1:** Triple-basierte Speicherung (Triple Table) · Physische Organisation (SPO/POS/...-Indizes) · Schema-Flexibilität (kein ALTER TABLE) · Datenintegration über URIs
**Prio 2:** Triple Table / RDF Dataset · Rolle von URIs (Linked Data) · Erweiterbarkeit durch neue Tripel · Zusammenführung heterogener Quellen · Semantische Struktur (Beziehungen als Kanten)
**Prio 3:** Named Graphs für Kontext/Provenienz · Beispiel mit mehreren Quellen · Kurze Erwähnung konkreter Stores (TDB)

**NotebookLM-Fragestellung für Data Structure:**
> "Erkläre, wie ein Semantic Triple Store RDF-Daten physisch speichert. Geh dabei auf folgende Aspekte ein: (1) Was ist eine Triple Table und warum ist sie fundamental anders als relationale Tabellen? (2) Welche SPO-Indizes gibt es und warum braucht man mehrere? (3) Wie ermöglicht die Triple-basierte Speicherung Schema-Flexibilität, die SQL nicht hat? (4) Wie funktioniert Datenintegration aus verschiedenen Quellen über URIs — was bedeutet das konkret am Beispiel?"

### 4. Query Model / SPARQL (15 min)
**Prio 1:** SPARQL Pattern Matching · Basics (SELECT, WHERE) · FILTER / OPTIONAL · Aggregationen · Federated Queries · Unterschied zu SQL
**Prio 2:** SPARQL als W3C-Standard · Triple Patterns mit Variablen · Query-Typen (SELECT, CONSTRUCT, ASK, DESCRIBE) · UNION, Subqueries, Property Paths · Entailment-Regimes
**Prio 3:** Live-Beispiel · Ausgabeformate (JSON, CSV, TSV)

### 5. Architecture Overview (15 min)
**Prio 1:** Aufbau Triple Store (RDF-Datenhaltung, Indexierung) · SPARQL-Endpunkte · Deployment (Single vs. verteilt) · Storage-Architekturen (In-Memory / Native / Non-Native) · Reasoning/Inferenz · Systeme (Jena Fuseki, GraphDB)
**Prio 2:** SPARQL Query Engine · Reasoner/Inferenzschicht · Skalierung & Performance · Oxigraph als Alternative
**Prio 3:** Architekturdiagramm · Cloud Triple Stores · Query-Optimierung, Caching

### 6. Comparison to Relational & Graph DB (10 min)
**Prio 1:** Modell (Tabelle vs. Graph/Triple) · Schema-Flexibilität · Skalierung/Performance · Use-Case-Vergleich
**Prio 2:** Abfragen (SQL Joins vs. SPARQL Pattern Matching) · Flexibilität bei sich entwickelnden Daten
**Prio 3:** Vergleichstabelle · Netzwerkartige Domäne als Beispiel · Trade-offs · Kombination beider Ansätze

---

## Demo

- `demo/files/demo_README.md` — **Hauptdoku für die Live-Demo**, erklärt alle 7 Queries Schritt für Schritt, Ablaufplan, Vorbereitung-Checkliste
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

### Aktueller Arbeitsstand
- Demo-Setup ist fertig (Oxigraph + 7 Queries + Datensatz)
- Inhaltliche Grundlage steht (`final strucutre`)
- Prio-Liste pro Kapitel liegt vor (`Priorisierte Gliederung Vinz`)
- Nächster Schritt: Inhalte mit NotebookLM ausarbeiten — Start mit **Data Structure** und **Query Model**

---

## Was ignoriert werden kann

- `groups/group1-graph-databases/` bis `groups/group7-data-lakes/` — andere Gruppen, nicht relevant
- `groups/schedule.md` — Semesterplanung für alle Gruppen
- `report.md`, `cover.jpg`, `LICENSE` — Repo-Boilerplate
