
# Sektion 3: Data Structure – Das Fundament der Vernetzung

> Quellen- und Claim-Mapping fuer diese Sektion: [data-structure-quellen.md](data-structure-quellen.md)

## Folie 1: Triple-basierte Speicherung – Weg von der Tabelle
**Kernbotschaft:** Triple-Stores speichern Fakten atomar und vermeiden das "NULL-Problem" relationaler Datenbanken.

*   **Das Problem der "breiten Tabelle" (SQL):**
    *   In SQL müssen Spalten vorab definiert werden. Fehlen Informationen (z. B. das Gründungsdatum einer Uni), entstehen "leere" Zellen (NULL-Werte).
    *   **Beispiel:** Eine Tabelle `Universitäten` mit Spalten für `Name`, `Stadt`, `Rektor`, `Gründungsjahr`. Viele Felder bleiben leer, wenn Daten unvollständig sind.
*   **Die Lösung: Vertikale Triple-Struktur:**
    *   Wissen wird in eine Liste einfacher Fakten zerlegt: **Subjekt – Prädikat – Objekt**.
    *   **Beispiel (Roter Faden):**
        1. `Uni_Stuttgart` -> `hat_Name` -> `"Universität Stuttgart"`.
        2. `Uni_Stuttgart` -> `liegt_in` -> `Stuttgart`.
        *(Kein Fakt zum Gründungsjahr? Dann existiert einfach kein Triple – kein Platz wird verschwendet.)*
*   **Vorteil:** Natürliche Abbildung vernetzter Daten ohne künstliche Tabellenstrukturen oder Join-Tabellen für n:m-Beziehungen.


---

## Folie 2: Schema-Flexibilität – Dynamisches Wachstum für AI-Pipelines
**Kernbotschaft:** Semantic Triple Stores sind "Schema-light" – das Wissen bestimmt die Struktur, nicht die Datenbank-Administration.

*   **Wachstum ohne "ALTER TABLE":**
    *   In SQL erfordert jedes neue Attribut (z. B. `Social_Media_Profil` für Professoren) eine Änderung des Tabellenschemas, was oft bestehende Anwendungen unterbricht.
    *   **Beispiel:** Ein AI-Agent findet neue Infos über Forschungsbereiche. In RDF hängen wir einfach ein neues Triple an: `Prof_Müller` -> `forscht_an` -> `Quantencomputing`.
*   **Vorteil für agile AI-Workflows:**
    *   AI-Systeme (z. B. RAG) müssen oft heterogene, sich ständig ändernde Quellen integrieren.
    *   RDF bricht nicht, wenn neue Datentypen auftauchen; es ist inhärent erweiterbar.
*   **Gegenüberstellung:**
    *   **SQL:** Starr, vordefiniert, Fokus auf Tabellen-Integrität.
    *   **RDF:** Flexibel, dynamisch, Fokus auf semantische Erweiterbarkeit.

---

## Folie 3: Physische Speicherung I – Triple Table und Dictionary-Encoding
**Kernbotschaft:** Triple Stores speichern intern nicht lange Strings, sondern kompakte IDs. Das reduziert Speicherbedarf und beschleunigt Vergleiche.

*   **Triple Table auf Speicher-Ebene:**
    *   Logisch sehen wir `Subjekt – Prädikat – Objekt`.
    *   Physisch liegen meist 3 numerische IDs pro Triple vor (statt langer URI-Strings).
*   **Dictionary-Encoding (ID-Mapping):**
    *   Separate Struktur mappt `ID -> URI/Literal`.
    *   Beispiel: `101 -> dbr:Stuttgart`, `502 -> dbo:location`.
    *   Physisches Triple: `(601, 502, 101)` statt `dbr:Uni_Stuttgart dbo:location dbr:Stuttgart`.
*   **Warum das relevant ist:**
    *   Schnelle Vergleiche auf Integer-Ebene statt teurer String-Vergleiche.
    *   Wiederholte URIs/Literale werden nur einmal im Dictionary gehalten.
*   **Trade-off:**
    *   Zusätzliche Dictionary-Verwaltung.
    *   Dafür deutlich bessere Query-Performance bei großen Wissensgraphen.

---

## Folie 4: Physische Speicherung II – Index-Permutationen fuer SPARQL
**Kernbotschaft:** Ein Triple Store braucht mehrere Index-Reihenfolgen (z. B. SPO, POS, OSP), damit unterschiedliche SPARQL-Muster ohne Full Scan laufen.

*   **Index-Idee:**
    *   Typische Permutationen: `SPO`, `SOP`, `PSO`, `POS`, `OSP`, `OPS`.
    *   Jede Permutation beschleunigt ein anderes Muster von "bekannt" vs. "variable".
*   **Konkrete Query-Muster (Universitaetsbeispiel):**
    *   `dbr:Uni_Stuttgart ?p ?o` -> Start ueber bekanntes Subjekt (`SPO`/`SOP`).
    *   `?s dbo:location dbr:Stuttgart` -> bekanntes Prädikat + Objekt (`POS` oder `OPS`).
    *   `?s ?p dbr:Stuttgart` -> bekanntes Objekt (`OSP`/`OPS`).
*   **Warum mehrere Indizes noetig sind:**
    *   Ohne passende Reihenfolge muesste der Store viele Triples sequentiell pruefen.
    *   Mit passendem Index sinkt die Suchflaeche drastisch.
*   **Trade-off Speicher vs. Geschwindigkeit:**
    *   Mehr Indexstrukturen bedeuten mehr Speicherverbrauch.
    *   Dafuer stabile Antwortzeiten bei unterschiedlichen Anfrageformen.

---

## Folie 5: Datenintegration über URIs – Die globale Identität
**Kernbotschaft:** URIs machen Ressourcen weltweit eindeutig und ermöglichen die nahtlose Datenintegration.

*   **Vermeidung von Ambiguität:**
    *   Der Text "Stuttgart" ist mehrdeutig (Stadt, Nachname, String). Eine URI wie `http://dbpedia.org/resource/Stuttgart` ist global eindeutig.
*   **Ressourcen in verschiedenen Rollen:**
    *   Eine Ressource (URI) kann in einem Triple als **Subjekt** und in einem anderen als **Objekt** auftreten.
    *   **Beispiel:**
        1. `Stuttgart` (S) -> `liegt_in` -> `Baden-Württemberg` (O).
        2. `Uni_Stuttgart` (S) -> `liegt_in` -> `Stuttgart` (O).
    *   Dies erschließt automatisch die Kette: `Uni_Stuttgart` -> `Stuttgart` -> `Baden-Württemberg`.
*   **Datenintegration am Beispiel:**
    *   Interne Daten: `Meine_Uni` -> `kooperiert_mit` -> `http://dbpedia.org/resource/Stuttgart`.
    *   DBpedia-Daten: `http://dbpedia.org/resource/Stuttgart` -> `Einwohner` -> `600.000`.
    *   **Ergebnis:** Automatische Verschmelzung beider Quellen über die identische URI.

*   **Optional (Prio 3): Named Graphs fuer Kontext/Quellen**
    *   Zusaetzliche Kontextgrenzen, um Datenherkunft (Provenienz) in Datasets abzubilden.
    *   Gut fuer spaetere Quellenarbeit und Nachvollziehbarkeit im Demo-Storytelling.

---

## Folie 6: Zusammenfassung – Von isolierten Fakten zur globalen Struktur
**Kernbotschaft (Roter Faden):** Die Kombination aus Triples, Flexibilität und URIs schafft eine skalierbare Wissensstruktur.

*   **Wissen vernetzen:**
    1.  **Atomisierung:** Daten in Triples zerlegen (einfach, stabil).
    2.  **Identifizierung:** Globale URIs nutzen (eindeutig, verknüpfbar).
    3.  **Flexibilität:** Wissen organisch wachsen lassen (keine starren Grenzen).
*   **Ergebnis:** Eine globale Wissensstruktur, die über Datenbankgrenzen hinweg maschinenlesbar und inferenzfähig bleibt.
*   *Überleitung zum nächsten Slot:* "Wie fragen wir dieses vernetzte Wissen nun effizient ab? -> SPARQL Query Model"

---

# Sektion 4: Query Model – Folienstruktur (kompakt)

### Folie 1: Kernidee & Lernziele
- **Kern:** Was macht SPARQL anders als SQL? (Graph vs. Tabelle)
- **Lernziele:** Pattern-Matching verstehen, Inferenz‑Impact erkennen, einfache Queries schreiben
- **Visual:** 1‑Zeilen Vergleichstabelle SQL ↔ SPARQL
Kommentar: Unnötig? 

### Folie 2: Triple Patterns + SELECT/WHERE
- **Kern:** Triple-Pattern = Subjekt‑Prädikat‑Objekt (Variablen mit `?`)
- **Beispiel:** einfache `SELECT`/`WHERE` Query (Typ + Label)
- **Takeaway:** geteilte Variablen verbinden Muster (implizite JOINs)
Kommentar:  Präfixe erklären in diesem Kontext? 

### Folie 3: FILTER, OPTIONAL, UNION (Kurzreferenz)
- **FILTER:** Eingrenzen von Bindungen (kurzes Beispiel)
- **OPTIONAL:** wie LEFT JOIN, fehlende Fakten bleiben erlaubt
- **UNION:** Alternativen in Mustern (kurze Notation)
Kommentar: Kann ich statt Union nicht einfach das | verwenden oder geht das nur bei  prädikaten diese property paths?  

### Folie 4: Aggregation & Praxisbeispiel
- **Konzepte:** `COUNT`, `GROUP BY`, `ORDER BY` in SPARQL
- **Beispiel:** Personenanzahl pro Universität (mit `rdfs:subClassOf*`)
- **Hinweis:** Aggregation + Gruppierung korrekt verwenden

### Folie 5: Property Paths & Inferenz (RDFS/OWL kurz)
- **Property Paths:** `/`, `|`, `*`, `+` — Beispiel `rdfs:subClassOf*`
- **Inferenz:** ohne vs. mit RDFS/OWL (Aha‑Moment: Query4 vs. Query5)
- **Visual:** kleine Klassen‑Hierarchy mit Traversalpfeil
Kommentar: Im Vergleich zu Porperty Graph kann ich ja auch da durchgehen, wie sieht das da konkret aus und warum heißt dass dann, das die besser sind im langen durchgehen (also so hab ich das verstanden, weil da stand, property grpah stark bei traversal performance)? 

### Folie 6: Federation, Ausgabeformate & Debug‑Checks
- **Federation:** `SERVICE`‑Pattern kurz erwähnen (dbpedia Beispiel)
- **Formate:** JSON (API), CSV (Analysen) — kurzer Tipp
- **Debug:** typische Fehlerchecks (DefaultGraph, Encoding, Entailment)

### Vielleicht Folie 7 mit ASK / CONSTRUCT / DESCRIBE

---
# Sektion 5: Architekture

## Folie 1 – Von RDF zur praktischen Umsetzung

### Titel

Vom RDF-Modell zur produktiven Anwendung

#### Bekannte Anwendungsfälle

##### Semantische Unternehmenssuche

Mitarbeiter sucht:
„Wer arbeitet an SAP-Projekten im Bereich Logistik?“

➡ RDF verknüpft Mitarbeiter, Projekte und Fachbereiche

---

##### RAG-Systeme mit LLMs

LLM beantwortet Fragen auf Basis eines Wissensgraphen

➡ Beziehungen und Kontext können gezielt abgefragt werden

---

##### Knowledge Graphs / Suchmaschinen

Verknüpfung von Personen, Orten, Organisationen und Ereignissen

➡ Zusammenhänge statt isolierter Datensätze

---

#### Technischer Aufbau

Datenquellen
↓
RDF / Ontologie
↓
Triple Store
↓
SPARQL
↓
Anwendung / KI / Suche

---
Wichitigste Entscheidung: Triple store selbst betreiben und aufbauen
oder Cloud dienst verwenden

---
#### Übergangsfrage an das Publikum

Angenommen ihr müsstet morgen einen RDF-basierten Knowledge Graph entwickeln:

Wann ürdet ihr ...

🖥️ den Triple Store selbst betreiben?

oder

☁️ einen Cloud-Dienst verwenden?

Welche Vorteile erwartet ihr jeweils?


## Folie 2 – Triple Stores und Cloud-Lösungen in der Praxis

### Titel
### Entscheidungsregel

#### Selbst betreiben

Vorteile:

* Volle Kontrolle
* Geringe Kosten
* Frei konfigurierbar

Geeignet für:

* Lernen
* Forschung
* Prototypen
* Kleine bis mittlere Projekte

---

#### Cloud-Lösung

Vorteile:

* Kein Betriebsaufwand
* Automatische Backups
* Hohe Verfügbarkeit
* Einfache Skalierung

Geeignet für:

* Produktivsysteme
* Große Datenmengen
* Unternehmensanwendungen

---
Welche Lösung für welchen Anwendungsfall?

| Lösung             | Typ                       | Hauptvorteil                               | Typischer Einsatz                |
| ------------------ | ------------------------- | ------------------------------------------ | -------------------------------- |
| Apache Jena Fuseki | Open Source               | Einfacher Einstieg, kostenlos              | Lehre, Forschung, Prototypen     |
| Oxigraph           | Open Source               | Leichtgewichtig, performant                | Kleine Anwendungen               |
| GraphDB            | Enterprise Triple Store   | Reasoning, Verwaltung, Skalierung          | Unternehmensprojekte             |
| Amazon Neptune     | Managed Cloud             | Automatische Skalierung, Hochverfügbarkeit | Große produktive Systeme         |
| Stardog Cloud      | Knowledge-Graph-Plattform | Datenintegration, Ontologien               | Unternehmensweite Wissensgraphen |



### Folie 3 – Single Node vs. Distributed Triple Store

#### Single Node

* Einfacher Betrieb
* Gute Performance
* Begrenzte Skalierung
* Vertikale Skalierung (CPU, RAM, SSD)

#### Distributed

* Mehrere Knoten im Cluster
* Horizontale Skalierung
* Höhere Verfügbarkeit
* Höhere Komplexität

#### Beispiele

**Single Node**

* Apache Jena TDB/TDB2
* RDF4J Native Store
* GraphDB Free
* Stardog (Single Server)

**Distributed**

* GraphDB Cluster
* Amazon Neptune
* Stardog Cluster

#### Illustration

```text
Single Node

Client
  |
Triple Store
```

```text
Distributed

          Client
             |
     +-------+-------+
     |       |       |
   Node1   Node2   Node3
```

#### Merksatz

> Single Node = einfacher Betrieb
> Distributed = höhere Skalierbarkeit

---

### Folie 4 – Skalierung im Cluster

#### Replication

* Gleiche Daten mehrfach speichern
* Ausfallsicherheit
* Höhere Verfügbarkeit
* Lastverteilung bei Lesezugriffen

#### Partitionierung (Sharding)

* Daten werden auf mehrere Knoten verteilt
* Mehr Gesamtspeicher
* Parallele Verarbeitung

#### Illustration

##### Replication

```text
Node A
  ↓
Node B
  ↓
Node C
```

##### Partitionierung

```text
Node A
Universitäten

Node B
Professoren

Node C
Projekte
```

#### Merksatz

> Replication = gleiche Daten mehrfach
> Partitionierung = Daten aufteilen

---

### Folie 5 – RDF-spezifisches Problem: Verteilte SPARQL-Joins

#### RDF-Graph

```text
Uni Stuttgart
      |
 locatedIn
      |
 Stuttgart
      |
 locatedIn
      |
Deutschland
```

#### Nach Partitionierung

##### Node A

```text
Uni Stuttgart
locatedIn Stuttgart
```

##### Node B

```text
Stuttgart
locatedIn Deutschland
```

#### Problem

```sparql
Uni_Stuttgart
 → Stuttgart
 → Deutschland
```

#### Kernaussage

* RDF besteht aus stark vernetzten Knoten
* Verbindungen können über mehrere Server verteilt sein
* SPARQL-Joins benötigen Netzwerkkommunikation

#### Merksatz

> Das eigentliche Skalierungsproblem bei RDF ist nicht die Speicherung, sondern die verteilte Ausführung von Graph-Abfragen.

---

### Folie 6 – Partitionierungsstrategien

#### Subject-basiert

```text
Uni Stuttgart
 ├ name
 ├ location
 └ ranking
```

* Alle Tripel eines Subjects gemeinsam speichern
* Einfach umzusetzen

---

#### Predicate-basiert

```text
locatedIn
worksAt
memberOf
```

* Aufteilung nach Prädikaten
* Geeignet für spezielle Analyse-Workloads

---

#### Graph Partitioning

```text
[Uni]
  |
[Professor]
  |
[Projekt]
```

* Zusammenhängende Teilgraphen gemeinsam speichern
* Ziel: weniger Netzwerkzugriffe

#### Ziel

> Möglichst wenige knotenübergreifende Joins

---


---

# Sektion 6: Comparison – Einordnung & Abgrenzung

### Folie 1: Triple Store vs. SQL – kurze Wiederholung
- **Kern:** Bekanntes nochmal scharf stellen, bevor wir in den Graph-Vergleich gehen
- **Tabelle (kompakt):**

| | SQL (Relational) | Triple Store (RDF) |
|---|---|---|
| Dateneinheit | Zeile in Tabelle | Subjekt–Prädikat–Objekt |
| Schema | starr, vordefiniert | flexibel, schema-light |
| Beziehungen | Joins (teuer, komplex) | Kanten = native Struktur |
| Abfragesprache | SQL | SPARQL (Pattern Matching) |
| Semantik | keine | RDFS/OWL, inferenzfähig |
| Datenintegration | schwierig (ETL) | URIs → direkt verlinkbar |

- **Takeaway:** SQL ist stark bei strukturierten, stabilen Daten – Triple Stores gewinnen, sobald Vernetzung und Semantik wichtig werden.

---

### Folie 2: Triple Store vs. Property Graph – die wichtige Abgrenzung
- **Kern:** Beide sind Graphmodelle – wo liegt der echte Unterschied?
- **Tabelle:**

| | Triple Store (RDF) | Property Graph (Neo4j) |
|---|---|---|
| Kanten-Eigenschaften | ❌ nur via Reifikation | ✅ nativ an der Kante |
| Standardisierung | ✅ W3C (SPARQL, OWL) | ❌ vendor-spezifisch (Cypher) |
| Inferenz | ✅ RDFS/OWL built-in | ❌ manuell implementieren |
| Traversal-Performance | ⚠️ gut mit Indizes | ✅ sehr gut (pointer-native) |
| Ext. Datenintegration | ✅ URIs, Linked Data, Federation | ❌ Insellösung |
| Typischer Use Case | Knowledge Graphs, Linked Data | soziale Netze, Routenplanung |

- **Key Message:** Property Graph gewinnt bei tiefer, performancekritischer Traversal in einer Datenbank. Triple Store gewinnt bei semantischer Reichweite, offener Datenintegration und Standardisierung.
- **Visual:** kleine Gegenüberstellung zweier Graphdarstellungen (RDF-Triple vs. Property-Graph-Knoten mit Properties an Kanten)

---

### Folie 3: Wann nimmt man was? – Use-Case-Matrix
- **Kern:** Klare Entscheidungshilfe für die Audience
- **Matrix:**

| Anforderung | Relational | Property Graph | Triple Store |
|---|---|---|---|
| Stabile, strukturierte Daten | ✅ | ⚠️ | ⚠️ |
| Tiefe Graphnavigation | ❌ | ✅ | ⚠️ |
| Semantik & Inferenz | ❌ | ❌ | ✅ |
| Offene Datenintegration (Linked Data) | ❌ | ❌ | ✅ |
| Einfacher Einstieg / Tooling | ✅ | ✅ | ⚠️ |
| AI / RAG / Knowledge Graphs | ⚠️ | ⚠️ | ✅ |

- **Takeaway:** Kein Modell gewinnt immer – Triple Stores sind die richtige Wahl, wenn Semantik, Standards und verteilte Datenintegration zählen.

---
