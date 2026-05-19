# Priorisierte Gliederung: Semantic Triple Stores / RDF + SPARQL

## Motivation

> Introduce the data model and explain why it was developed. Relate to AI use cases (e.g., graph models for recommendations).

**Prio 1:**
- Schwachstellen relationaler Datenbanken:
  - Starre Schemata
  - Keine Semantik
  - Komplexe Beziehungen nur über viele Joins, schwer wartbar
- Grundidee von RDF und warum es überlegen ist
- Relevanz für AI Use Cases:
  - Nutzung in RAG-Pipelines
  - Semantische Suche

**Prio 2:**
- Vorteile von Triple Stores:
  - Natürliches Modell für vernetzte Daten
  - Wissensrepräsentation und Integration verteilter Datenquellen
- Wissensgraphen für Explainability
- Unterstützung inferenzfähiger Anwendungen
- Typische Anwendungsfälle:
  - Knowledge Graphs
  - Linked Data / Web of Data
  - Integration heterogener Datenquellen über URIs

**Prio 3:**
- Reales Beispiel (z. B. Google Knowledge Graph)
- Beispiel einer komplexen Anfrage (SQL vs. SPARQL)
- Motivation durch offene SPARQL-Endpunkte
- Kurze Abgrenzung zu Property Graphs (nur anteasern)


---

## Conceptual Model

> Describe the core data structures (nodes/edges, triples, vectors, documents, key–value pairs, columns, data lake objects). Use diagrams and analogies.

**Prio 1:**
- RDF-Struktur und Komponenten:
  - Triple
  - Gerichteter Graph
  - URIs / Ressourcen
  - Literale
  - Blank Nodes
- Begriffe und Regeln:
  - RDF Schema (RDFS)
  - OWL
  - Ontologien und Vokabulare
- Inferenz (machine-readable)
- Named Graphs
- Unterschied zu Property Graphs

**Prio 2:**
- RDF-Grundstruktur:
  - Subjekt–Prädikat–Objekt
  - Subgraphen als Denkmodell
- RDF Graph vs. RDF Dataset:
  - Default Graph
- Semantik & Bedeutung:
  - Maschinenlesbarkeit durch standardisierte Prädikate
  - Grundlage für Inferenz

**Prio 3:**
- Turtle-Syntax Beispiel
- Visualisierung eines kleinen RDF-Graphs (3–5 Tripel)
- Intuitive Erklärung von Inferenz


---

## Data Structure

> Show how data are stored physically and logically. Discuss schema flexibility or constraints.

**Prio 1:**
- Triple-basierte Speicherung
- Schema-Flexibilität
- Datenintegration über URIs
- Physische Organisation:  Indizes (SPO, POS, …)

**Prio 2:**
- Speicherung als Triple Table / RDF Dataset
- Rolle von URIs:
  - Eindeutige Referenzierung
  - Linked Data
- Erweiterbarkeit durch neue Tripel
- Zusammenführung heterogener Datenquellen
- Semantische Struktur:
  - Beziehungen als Kanten

**Prio 3:**
- Named Graphs für Kontext/Quellen
- Beispiel: Eine Ressource mit Eigenschaften aus mehreren Quellen
- Kurze Erwähnung konkreter Stores (z. B. TDB)


---

## Query Model

> Introduce the query language (Cypher, SPARQL, ANN API, MongoDB queries, Redis commands, CQL, DuckDB SQL). Explain how queries differ from SQL.

**Prio 1:**
- SPARQL:
  - Pattern Matching
- Queries:
  - Basics (SELECT, WHERE)
  - FILTER / OPTIONAL
  - Aggregationen
- Federated Queries
- Unterschied zu SQL

**Prio 2:**
- SPARQL als W3C-Standard
- Triple Patterns mit Variablen
- Query-Typen:
  - SELECT, CONSTRUCT, ASK, DESCRIBE
- Weitere Features:
  - UNION
  - Subqueries
  - Property Paths
- Entailment-Regimes (RDFS, OWL)

**Prio 3:**
- Live-Beispiel (z. B. Universitäten in Deutschland)
- Ausgabeformate (JSON, CSV, TSV)


---

## Architektur

> Outline how the system is deployed (single node vs. distributed, replication, partitioning). Mention open-source tools and cloud options.

**Prio 1:**
- Aufbau eines Triple Stores:
  - RDF-Datenhaltung
- Indexierung = Physische Organisation:  Indizes (SPO, POS, …)?  
- SPARQL-Endpunkte
- Deployment:
  - Single vs. verteilte Systeme
- Storage-Architekturen:
  - In-Memory / Native / Non-Native
- Reasoning / Inferenz
- Systeme:
  - Apache Jena Fuseki
  - GraphDB

**Prio 2:**
- SPARQL Query Engine
- Reasoner / Inferenzschicht
- Zugriff über standardisierte Schnittstellen
- Skalierung & Performance:
  - Indexbasierte Optimierung
  - Herausforderungen bei großen Knowledge Graphs
- Weitere Systeme (z. B. Oxigraph)

**Prio 3:**
- Architekturdiagramm
- Cloud Triple Stores
- Query-Optimierung, Caching


---

## Comparison

> Highlight differences in data model, schema flexibility, scalability and performance.

**Prio 1:**
- Modell:
  - Tabelle vs. Graph / Triple
- Schema-Flexibilität:
  - Relational vs. RDF
- Skalierung / Performance:
  - Strukturierte vs. verlinkte Daten
- Use-Case-Vergleich

**Prio 2:**
- Abfragen:
  - SQL (Joins) vs. SPARQL (Pattern Matching)
- Flexibilität bei sich entwickelnden Daten
- Ergebnisse:
  - Tabelle vs. Graph/Tabelle

**Prio 3:**
- Vergleichstabelle für Folien
- Beispiel einer netzwerkartigen Domäne
- Trade-off:
  - Mehr Flexibilität vs. höherer Modellierungsaufwand
- Kombination beider Ansätze in modernen Architekturen