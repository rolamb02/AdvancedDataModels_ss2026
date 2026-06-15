
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

# Sektion 4: Query Model
**Kernbotschaft des Kapitels:** SPARQL fragt keine Tabellen ab — es beschreibt Bedeutungsstrukturen im Graphen und kann dabei Wissen *ableiten*, das nie explizit gespeichert wurde.

---

## Folie 1: SPARQL – Pattern Matching statt Tabellen
**Kernbotschaft:** SQL kennt Tabellen und fragt sie ab. SPARQL kennt keine Tabellen — es beschreibt, wie das Gesuchte *aussehen soll*, und der Store findet alle passenden Belegungen.

- **Das Grundprinzip — Triple Pattern als Schablone:**
    - Jedes Pattern sieht aus wie ein RDF-Triple, nur mit Variablen als Platzhalter (`?`)
    - `?u a uni:University` → "Finde alles, das ein University-Typ ist"
    - `?u uni:location ?stadt` → "Hole dazu die zugehörige Location-Ressource"
    - `?stadt uni:bundesland "Baden-Wuerttemberg"` → "Nur wenn die Location in BW liegt"
- **Geteilte Variablen = impliziter JOIN:**
    - `?u` taucht in zwei Patterns auf — das verbindet sie automatisch
    - Kein `JOIN`-Keyword, kein expliziter Fremdschlüssel nötig
    - Analogie: Lückentext — alle Lücken mit demselben Namen müssen denselben Wert haben
- **Gegenüberstellung SQL vs. SPARQL:**
    - SQL: `FROM university u JOIN city c ON u.location_id = c.id WHERE c.state = '...'`
    - SPARQL: `?u a uni:University . ?u uni:location ?stadt . ?stadt uni:bundesland "..."` — kein FROM, kein JOIN, kein Schema
- **Visual:** Split-Layout — SQL-Query links (mit JOIN hervorgehoben), SPARQL-Query rechts (mit geteilter Variable hervorgehoben)

---

## Folie 2: SELECT & WHERE – Anatomie einer SPARQL-Query
**Kernbotschaft:** Eine SPARQL-Query hat eine klar lesbare Struktur. Sobald man die Bestandteile kennt, kann man jede Query lesen und schreiben.

- **PREFIX — Namespace-Abkürzung:**
    - `uni:University` steht für `<http://example.org/uni/University>`
    - Vergleich: wie `import numpy as np` in Python — kein Datenbankzugriff, nur ein kurzer Name für einen langen Pfad
    - Ohne PREFIX: volle URI in spitzen Klammern überall nötig
- **SELECT — Ausgabe-Variablen:**
    - `SELECT ?u ?name` → diese zwei Variablen erscheinen als Spalten im Ergebnis
    - `SELECT *` → alle gebundenen Variablen ausgeben
- **WHERE — die Musterbedingungen:**
    - Jede Zeile ist ein Triple Pattern; alle Patterns müssen gleichzeitig erfüllt sein (implizites AND)
    - Reihenfolge der Patterns ist dem Store überlassen — der Query Optimizer entscheidet
- **ORDER BY, LIMIT, OFFSET:** funktionieren wie in SQL
- **Variablen-Konzept:**
    - Namen sind bedeutungslos: `?u`, `?x`, `?baum` liefern dasselbe
    - Typ entsteht durch Pattern (`?s a uni:University`), nicht durch den Variablennamen
    - Gleichnamige Variablen in verschiedenen Patterns müssen denselben Wert haben → impliziter Join-Mechanismus
- **Beispiel (Query 1):** `SELECT ?u ?name WHERE { ?u a uni:University . ?u rdfs:label ?name . } ORDER BY ?name`
- **Visual:** Annotierte Query mit farbigen Markierungen auf PREFIX, SELECT, WHERE, einzelne Patterns und Variablen

---

## Folie 3: FILTER · OPTIONAL · Property Paths
**Kernbotschaft:** SPARQL hat drei mächtige Werkzeuge, um Matches einzugrenzen, optionale Fakten zu behandeln und Pfade im Graphen zu traversieren.

- **FILTER — Einschränkung nach Match:**
    - `FILTER(?semester >= 5)` — schränkt bereits gebundene Variablen ein
    - Kommt *nach* den Pattern-Bindungen, nicht *statt* eines Patterns. Erst matchen, dann filtern
    - Analog SQL WHERE, aber auf Graph-Pattern-Ergebnissen
- **OPTIONAL — fehlende Fakten erlaubt:**
    - `OPTIONAL { ?p uni:fachgebiet ?fach . }` — Professoren ohne Fachgebiet bleiben im Ergebnis, `?fach` bleibt leer (unbound)
    - Entspricht SQL LEFT JOIN: alle Zeilen der linken Seite, ungebunden wenn kein Match rechts
    - **Open World Assumption:** Im RDF-Modell bedeutet ein fehlendes Triple "unbekannt", nicht "falsch"
    - **Ohne OPTIONAL:** das Pattern muss vollständig matchen — fehlender Wert = Zeile fällt komplett raus, 0 Ergebnisse für diese Entität, kein Fehler
- **Property Paths — Graph-Traversal in einer Zeile:**
    - `(uni:studiesAt | uni:worksAt)` → Alternative Prädikate. Gilt nur für Prädikate, nicht für ganze Muster
    - Für alternative Muster braucht man `UNION`: `{ ?p a uni:Student } UNION { ?p a uni:Professor }`
    - `rdfs:subClassOf*` → transitive Traversal, 0 oder mehr Schritte entlang der Klassenhierarchie
    - `rdfs:subClassOf+` → 1 oder mehr Schritte (direkte Superklasse ausgeschlossen)
    - SQL kennt kein Äquivalent ohne rekursive CTEs
- **Visual:** Drei-Spalten-Layout — FILTER links, OPTIONAL mitte, Property Path rechts, je mit Code-Snippet und Erklärung

---

## Folie 4: Aggregation – COUNT, GROUP BY, ORDER BY
**Kernbotschaft:** SPARQL kann aggregieren wie SQL — aber die Treffermenge entsteht durch Graph-Pattern-Matching mit Klassenhierarchie-Traversal, nicht durch einen einfachen Tabellen-Scan.

- **Die Query (Query 6) — Personen pro Universität zählen:**
    - `SELECT ?uniname (COUNT(?person) AS ?anzahl)`
    - `WHERE { ?person a ?typ . ?typ rdfs:subClassOf* uni:Person . ?person (uni:studiesAt|uni:worksAt) ?u . ?u rdfs:label ?uniname . }`
    - `GROUP BY ?uniname ORDER BY DESC(?anzahl)`
- **Was steckt drin:**
    - `COUNT(?person)` → Anzahl eindeutiger Personen pro Gruppe
    - `GROUP BY ?uniname` → eine Ergebniszeile pro Universität
    - `?typ rdfs:subClassOf* uni:Person` → findet alle Unterklassen: Student, Professor, Staff
    - `?person a ?typ` → findet die *Instanzen* dieser Klassen (nicht die Klassen selbst — deshalb beide Patterns zusammen nötig)
    - `(uni:studiesAt | uni:worksAt)` → Property Path Union: Personen egal ob Student oder Mitarbeiter
- **Wichtige Abgrenzung:**
    - **Aggregation** verdichtet vorhandene Treffer (COUNT, SUM, AVG, MIN, MAX)
    - **Inferenz** leitet neue Fakten ab — beides kommt hier vor, sind aber verschiedene Konzepte
- **Visual:** Query links annotiert, rechts drei Cards: Aggregation, rdfs:subClassOf*-Erklärung, Property Path Union

---

## Folie 5: Der Aha-Moment – Inferenz (Query 4 vs. Query 5)
**Kernbotschaft:** Gleiche Daten, gleiche Abfragesprache — aber mit Ontologie-Wissen findet SPARQL 7 Ergebnisse, wo naives SPARQL und SQL 0 liefern würden.

- **Das Setup — was im Store steht:**
    - `uni:Student rdfs:subClassOf uni:Person`
    - `uni:Professor rdfs:subClassOf uni:Person`
    - `uni:Staff rdfs:subClassOf uni:Person`
    - Alice ist als `uni:Student` gespeichert — *nie* explizit als `uni:Person`
- **Query 4 — ohne Klassenhierarchie → 0 Ergebnisse:**
    - `SELECT ?p WHERE { ?p a uni:Person . }`
    - Store gibt nur zurück, was wörtlich drin steht. Kein explizites `alice a uni:Person`-Triple → keine Treffer
    - Wie SQL: keine impliziten Ableitungen
- **Query 5 — mit Klassenhierarchie → 7 Ergebnisse:**
    - `SELECT ?p WHERE { ?p a ?typ . ?typ rdfs:subClassOf* uni:Person . }`
    - Zwei Patterns: erst Individuum → Klasse (`?p a ?typ`), dann Klassenhierarchie traversieren
    - Warum zwei Patterns? `?p rdfs:subClassOf* uni:Person` allein würde nur *Klassen* finden, nicht *Instanzen*
- **Chain of Thought:**
    - Store weiß: `Student subClassOf Person` → Alice ist Student → also *gilt*: Alice ist Person
    - SQL gibt zurück, was *steht*. SPARQL + Ontologie gibt zurück, was *gilt*
- **Abgrenzung Traversal vs. Inferenz:**
    - **Traversal (hier):** bewegt sich entlang *existierender* `subClassOf`-Kanten
    - **Inferenz/Entailment (stärker, kommt in Architecture):** Store leitet *neue* Triples ab — `Alice a Person` wird automatisch materialisiert
- **Property Graph-Vergleich:**
    - Property Graphs: direkte Speicher-Pointer zwischen Knoten → Traversal-Schritt = Pointer-Lookup, sehr schnell bei struktureller Navigation
    - RDF: Index-Lookup pro Schritt — etwas langsamer bei rein struktureller Traversal
    - RDF gewinnt beim *semantischen* Traversal: `rdfs:subClassOf*` nutzt Ontologie-Wissen. Property Graph kennt Klassenhierarchien nicht nativ — müsste manuell modelliert und traversiert werden
- **Visual:** Klassenhierarchie-Diagramm oben, darunter Query 4 (roter Rahmen, "0") vs. Query 5 (grüner Rahmen, "7")

---

## Folie 6: Federated Queries – Das Web of Data
**Kernbotschaft:** Eine SPARQL-Query kann Teile live an externe Endpoints delegieren und lokale Daten mit dem weltweiten Web of Data verbinden — ohne Datenkopie, ohne ETL.

- **SERVICE-Pattern — live gegen DBpedia (Query 7):**
    - `SERVICE <https://dbpedia.org/sparql> { ?dbCity dbo:abstract ?description . FILTER (lang(?description) = "de") }`
    - Der SERVICE-Block wird live an den externen Endpoint geschickt; Antwort wird mit lokalen Daten gejoint
    - Keine Datenkopie, kein Import, kein ETL-Job
- **Verbindung über owl:sameAs:**
    - `uni:Stuttgart owl:sameAs dbr:Stuttgart` — verknüpft lokale URI mit globaler DBpedia-URI
    - Der Store weiß: diese beiden Bezeichner meinen dieselbe Entität → Bindeglied zwischen lokalem Store und DBpedia
- **Warum das nur mit W3C SPARQL geht:**
    - Alle SPARQL-Endpoints (Oxigraph, DBpedia, Wikidata, GraphDB, Amazon Neptune) sprechen denselben Standard
    - Neo4j Cypher oder MongoDB können nicht gegen externe Endpoints queren — keine gemeinsame Sprache
    - W3C-Standardisierung = ein Query-Mechanismus, viele Datenquellen weltweit
- **Ausgabeformate:** JSON (APIs, RAG-Pipelines), CSV (Tabellenanalyse), RDF/XML (CONSTRUCT-Export)
- **Demo-Hinweis:** Query 7 ist internetabhängig — kann langsam sein oder fehlschlagen. Screenshot-Fallback bereithalten.
- **Visual:** Diagramm mit lokalem Store + Pfeil zu DBpedia-Endpoint + rückkommende Daten, daneben SERVICE-Code annotiert

---

## Folie 7: Query-Typen — SELECT · ASK · CONSTRUCT · DESCRIBE
**Kernbotschaft:** SPARQL hat vier Query-Formen für vier verschiedene Aufgaben. SELECT ist der Standardfall — die anderen drei sind mächtige Werkzeuge für spezifische Situationen.

- **SELECT** → tabellarische Variablenbindungen:
    - Alle Demo-Queries. Gibt Tabelle zurück: eine Spalte pro Variable, eine Zeile pro Match
    - Einsatz: Daten abfragen, anzeigen, in Anwendungen weiterverwenden
- **ASK** → Boolean-Prüfung:
    - `ASK { uni:AliceSchmidt a uni:Student . }` → `true` oder `false`
    - Kein Ergebnis-Datensatz, nur Ja/Nein
    - Einsatz: Validierung vor einer Verarbeitung, Assertions in Datenpipelines, "Existiert dieser Datenpunkt?"
- **CONSTRUCT** → neuen RDF-Graph erzeugen:
    - Query definiert ein Triple-Template: aus den Treffern werden neue Triples nach dem Template gebaut
    - Einsatz: Daten aus mehreren Quellen in einheitliches Format überführen, Teilgraph exportieren, Regeln materialisieren, Kontext für RAG-Pipelines aufbereiten
    - Gibt RDF zurück, keine Tabelle
- **DESCRIBE** → Beschreibung einer Ressource:
    - `DESCRIBE uni:Stuttgart` → Store gibt alles zurück, was er über diese URI weiß
    - Format nicht normiert, variiert je nach Store-Implementierung
    - Einsatz: schnelle Exploration ohne Schema zu kennen
- **AI-Relevanz:**
    - CONSTRUCT: strukturierten RDF-Graphen als Kontext für RAG — jede Aussage auf konkrete Triples rückführbar → Explainability
    - ASK: Konsistenz-Checks in automatisierten Wissensgraph-Pipelines
- **Visual:** 2x2-Grid — je eine Card pro Query-Typ mit Name, kurzem Code-Snippet und Einsatzfall

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
