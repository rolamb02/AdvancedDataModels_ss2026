# Sprechtext Roman — Gesamtübersicht

---
---

# 1 — DATA STRUCTURE

"Data structure (15 min) – Show how data are stored physically and logically. Discuss schema flexibility or constraints."

---

## Folie 2: Schema-Flexibilität – Dynamisches Wachstum

### Kernpunkte

- **SQL: ALTER TABLE** — jedes neue Attribut erfordert eine Schema-Änderung. Das kann laufende Anwendungen unterbrechen, erfordert Migrations-Skripte, Review, Downtime

- **Trade-off fair benennen:** Weniger Schema-Kontrolle kann auch heißen: weniger Daten-Konsistenzgarantien. RDF ist "Schema-light", nicht "Schema-frei"

---

## Folie 3: Physische Speicherung I – Triple Table und Dictionary-Encoding

### Kernpunkte

- **Logisch** Subject–Predicate–Object als URIs und Strings
- **Physisch** 3 Integer-IDs pro Triple vor 
- **Dictionary-Encoding:**
  - Separate Struktur mappt `ID → URI oder Literal`
  - Beispiel: `101 → dbr:Stuttgart`

---

## Folie 4: Physische Speicherung II – Index-Permutationen

- **Lösung: mehrere Index-Permutationen** 
  - Jede Permutation ist eine B-Tree-sortierte Kopie der Triple Table in anderer Reihenfolge
  - Passende Permutation → direkter Einstieg ohne Full-Scan

**In der Praxis — Permutationen nach System:**

| System | Indizes (Default) |
|---|---|
| **RDF-3X / Hexastore** | alle 6 (SPO, SOP, PSO, POS, OSP, OPS) |
| **Apache Jena TDB/TDB2** | 3 (SPO, POS, OSP), konfigurierbar |
| **Oxigraph** (eure Demo) | 6 Quad-Orderings mit Graph-Komponente |
| **RDF4J Native** | 2 (spoc, posc) standardmäßig |
| **Virtuoso** | 2 volle + 3 partielle |
| **Blazegraph** | 3 für Triples, 6 im Quad-Modus |

→ **Regel:** 3 Permutationen reichen, um alle Triple-Patterns als Präfix-Lookup zu bedienen. 6 sind das theoretische Maximum (Lehrbuch), aber produktiv meist optional. 

---

## Folie 6: Zusammenfassung – Von isolierten Fakten zur globalen Struktur

- **Ergebnis:** Eine Struktur, die sowohl *lokal* (Dictionary-Encoding, Indizes) effizient arbeitet als auch *global* (URI-Linking, Federation) vernetzt werden kann

---
---

# 2 — QUERY MODEL

Query model (15 min) – Introduce the query language (Cypher, SPARQL, ANN API, MongoDB queries, Redis commands, CQL, DuckDB SQL). Explain how queries differ from SQL.

---

## Folie 2: SELECT & WHERE – Anatomie einer SPARQL-Query

### Kernpunkte

**PREFIX — Namespace-Abkürzung:**

---

## Folie 3: Query-Typen — SELECT · ASK · CONSTRUCT · DESCRIBE

**ASK**

- Einsatz: Validierung vor einer Verarbeitung, Assertions in Datenpipelines, „Existiert dieser Datenpunkt überhaupt?"

**CONSTRUCT**

- Einsatz: Daten aus mehreren Quellen in einheitliches Format überführen, Teilgraph exportieren, Regeln materialisieren, strukturierten Kontext für RAG-Pipelines aufbereiten
- Gibt RDF zurück, keine Tabelle

**Friend of a Friend** — ein standardisiertes RDF-Vokabular für Personen und soziale Netzwerke. W3C-spezifiziert, URI: `http://xmlns.com/foaf/0.1/`.

Typische Properties:

- `foaf:name` → Name einer Person
- `foaf:knows` → kennt eine andere Person
- `foaf:mbox` → E-Mail-Adresse
- `foaf:Person` → Klasse "Person"
- `foaf:memberOf` → Mitglied einer Organisation

**DESCRIBE** —

| | `DESCRIBE uni:Stuttgart` | `SELECT ?p ?o WHERE { uni:Stuttgart ?p ?o }` |
|---|---|---|
| **Rückgabeformat** | RDF-Graph | Tabelle (Variablenbindungen) |
| **Was zurückkommt** | Store-abhängig: kan auch eingehende Links, Blank Nodes, Metadaten enthalten | Nur *ausgehende* Kanten von Stuttgart |
| **Normiert?** | Nein — jeder Store entscheidet selbst | Ja, exakt definiert |


**AI-Relevanz:**

- CONSTRUCT: aufbereitete RDF-Graphen als Kontext für LLM-Antworten — jede Aussage auf konkrete Triples rückführbar → Explainability
- ASK: Konsistenz-Checks in automatisierten Wissensgraph-Pipelines

---

## Folie 5: FILTER · OPTIONAL · Property Paths


**FILTER:** - Kommt *nach* den Pattern-Bindungen

**OPTIONAL:**

- SQL LEFT JOIN: alle Zeilen der linken Seite, NULL wenn kein Match rechts
- Hintergrund — **Open World Assumption**: im RDF-Modell bedeutet ein fehlendes Triple „unbekannt", nicht „falsch". Das ist eine bewusste Design-Entscheidung

Closed World Assumption (SQL): Die Datenbank enthält alles Relevante. Was nicht drin steht, existiert nicht. Abfrage "Hat Max eine Email?" → kein Eintrag → Antwort: Nein.

Open World Assumption (RDF): Die Datenbank ist ein Ausschnitt des Weltwissens. Was nicht drin steht, ist unbekannt — nicht falsch. Abfrage "Hat Max eine Email?" → kein Triple gefunden → Antwort: Wir wissen es nicht.

Warum das eine bewusste Design-Entscheidung ist: RDF wurde für das Web entworfen. Im Web sind Informationen über eine Entität über viele verschiedene Server verteilt — Wikidata weiß andere Dinge über Stuttgart als DBpedia. Kein System hat das vollständige Weltwissen. Es wäre falsch zu sagen: "Stuttgart hat keine Einwohnerzahl" nur weil dieser Store sie nicht gespeichert hat.

Praktische Konsequenz: Das ist der Grund warum SPARQL OPTIONAL und FILTER NOT EXISTS so wichtig sind. In RDF kannst du nie sicher sein, ob etwas "nicht existiert" oder ob die Information einfach fehlt — deshalb musst du explizit nach Abwesenheit fragen, wenn du sie brauchst.

**Property Paths:**

```sparql
-- * : findet Student selbst UND alle Oberklassen (Person)
?x rdfs:subClassOf* uni:Student

-- + : findet NUR die Oberklassen (Person), NICHT Student selbst
?x rdfs:subClassOf+ uni:Student
```

```sparql
-- Ohne /: zwei separate Patterns
?person uni:studiesAt ?uni .
?uni uni:location ?city .

-- Mit /: ein einziger Property Path
?person uni:studiesAt/uni:location ?city .
```

---

## Folie 6: Inferenz

### Kernpunkte

**Das Setup** -  `uni:Student rdfs:subClassOf uni:Person`, ebenso für Professor und Staff

- Alice ist als `uni:Student` gespeichert — *nie* explizit als `uni:Person`

**Abgrenzung Traversal vs. Inferenz:**

- **Traversal (hier):** bewegt sich entlang *existierender* `subClassOf`-Kanten — echte gespeicherte Triples
- **Inferenz/Entailment (kommt in Architecture):** Store leitet *neue* Triples ab und materialisiert sie — `Alice a Person` existiert dann explizit im Store

---
---

# 3 — COMPARISON

---

## Folie 1: Triple Store vs. SQL – Consistency / ACID

**ACID** = **A**tomicity · **C**onsistency · **I**solation · **D**urability

| | SQL | Triple Store |
|---|---|---|
| **Atomicity** | 1 UPDATE = 1 atomare Op | Update = delete + insert (2 Ops) → schwieriger atomar |
| **Consistency** | Constraints & Triggers erzwingen gültigen Zustand | implementierungsabhängig |
| **Isolation** | Serializable Standard in den meisten Engines | Oxigraph: Repeatable Read; Jena TDB2: Serializable |
| **Durability** | jahrzehnte-erprobt | gegeben, aber je nach Impl. |

**Triple Store implementierungsabhängig:**
- **Oxigraph:** Repeatable-Read-Isolation, nur 1 Writer gleichzeitig (kein concurrent write)
- **GraphDB / Stardog:** vollständiges ACID, aber Performance-Overhead
- **Distributed (Virtuoso Cluster):** oft nur Eventually Consistent (CAP-Theorem)

**Kernproblem:** 1 Update ("Alice wechselt Uni") = 2 Ops (delete + insert); SQL = 1 UPDATE → bei Millionen verteilter Triples aufwendiger atomar zu halten

**Interaktion:** ETL = Extract, Transform, Load

---

## Folie 2: Triple Store vs. Property Graph

**Standardisierung:**
- Cypher (Neo4j) = herstellerspezifisch, kein W3C-Standard, verschiedene Dialekte
- SPARQL = W3C-Standard → alle konformen Stores sprechen dieselbe Abfragesprache
- Standardisierte Vokabulare: RDFS, OWL, Dublin Core, Schema.org
  - `rdfs:subClassOf`, `owl:sameAs`, `dbo:birthPlace` = global definierte Bedeutungen
  - → semantische Interoperabilität zwischen Systemen, die dieselben Vokabulare nutzen
- Property Graphs: kein Vokabular-Standard

**Traversal-Performance Property Graph (Neo4j):**
- Knoten = fester Datensatz mit Pointer auf 1. ausgehende Kante
- Kante = Pointer auf Zielknoten + Pointer auf nächste Kante desselben Knotens (verkettete Liste im Speicher)
- Beispiel "Romi":
  - Hop 1: Knoteneintrag → Pointer → 1. Kante → Zielknoten = O(1), 2 Speicherzugriffe
  - Nächste Kante: Kante enthält Pointer auf nächste Kante → O(1)
  - 4 Hops × 10 Freunde/Level: 10 + 100 + 1.000 + 10.000 = **~11.110 Pointer-Sprünge**, kein Index-Lookup

**Traversal-Performance Triple Store (Oxigraph/Jena):**
- Keine physischen Pointer → SPO-Index (B-Tree oder Hash)
- Pro Hop: Index-Lookup "alle Triples wo Subj = uni:Romi, Pred = uni:kennt" → O(log n) oder O(1)+Overhead
- 4 Hops × 10 Freunde: gleiche Anzahl Lookups, aber jeder Lookup teurer als Pointer-Sprung
- Größerer Graph → nicht mehr vollständig im RAM → noch langsamer

**Fazit:** Property Graph = pointer-native → schneller bei tiefer Traversal; Triple Store → stärker bei semantischer Reichweite + externer Datenintegration

**SERVICE-Frage (dbo-Prädikat vs. Stuttgart-Objekt):**
- Prädikate = Labels aus lokalem Präfix-Block → kein SERVICE nötig
- Objekte/Ressourcen können echte externe Datenobjekte sein → SERVICE nötig

---

## Folie 3: Wann nimmt man was? – Use-Case-Matrix

Diese Matrix ist als schnelle Orientierungshilfe gedacht. Kein Modell gewinnt immer.

**Stabile, strukturierte Daten → SQL ✅:** Bestelldatenbanken, ERP, Finanzbuchhaltung – viele gleichartige Datensätze mit festem Schema. Property Graph und Triple Store können zwar, aber überdimensioniert und unintuitiver

**Tiefe Graphnavigation → Property Graph ✅:** Wie erklärt: pointer-native Traversal, nativ für Graphnavigation gebaut. Triple Store ist ⚠️ – geht, aber langsamer. SQL ist ❌ – rekursive Abfragen in SQL (WITH RECURSIVE) sind umständlich und nicht für Graphnavigation optimiert.
- eBay: Neo4j für Recommendation Engine
- PayPal: Neo4j für Fraud Detection
- ICIJ: Neo4j zur Analyse der Panama Papers

**Semantik & Inferenz → Triple Store ✅:** 
- UniProt: SPARQL-Endpoint mit 190 Mrd. Triples für Proteinforschung
- NHS/Medizin: SNOMED CT & ICD-10 als OWL-Ontologien mit automatischer Inferenz
- Open PHACTS (EU): RDF-Integration von DrugBank, ChEMBL, UniProt für Wirkstoffforschung

**Offene Datenintegration → Triple Store ✅:** 
- BBC: RDF-Verlinkung von Nachrichtenartikeln mit Archivmaterial via DBpedia
- New York Times: Publikation von Personen/Orten/Organisationen als Linked Open Data
- Open PHACTS: Federated SPARQL über mehrere Pharmadatenbanken ohne ETL-Pipeline

**Einfacher Einstieg / Tooling:**
- SQL ✅: längste Geschichte, breiteste Entwickler-Community, beste Tool-Unterstützung.
- Property Graph ✅: Neo4j hat gutes Tooling, Cypher ist intuitiver als SPARQL, gute Visualisierung.
- Triple Store ⚠️: Tooling existiert (GraphDB, Oxigraph, Jena Fuseki), aber die Einstiegshürde ist höher – RDF-Denken, URI-Handling, Präfixe, SPARQL-Syntax. Das ist ehrlich und kein Nachteil, den man verstecken sollte.
- MySQL/PostgreSQL: Standard in nahezu jeder Web-App (Django, Rails, etc.)
- Neo4j Browser/Bloom: Visuelles Tooling für Graphexploration
- SQLite: Embedded in Python, iOS, Android — kein Setup nötig

**Knowledge Graphs → Triple Store ✅:**
- Google Knowledge Graph: 500 Mrd. Fakten, 5 Mrd. Entitäten
- Wikidata/DBpedia: Offene RDF-Knowledge-Graphs über Wikipedia-Daten
- Siemens: RDF/OWL Knowledge Graph in Produktion mit Dutzenden Mrd. Triples

**Die großen Knowledge Graphs der Welt sind RDF-basiert.** Google's Knowledge Graph ist intern ebenfalls auf RDF-ähnlichen Strukturen aufgebaut. Ein Property Graph kann auf diese Daten nicht nativ zugreifen – er hat weder URIs als globale Identifier noch einen Federation-Mechanismus wie `SERVICE`. 

**Inferenz macht den Unterschied.** 

**Standardisierte Vokabulare ermöglichen semantische Interoperabilität.** Knowledge Graphs leben davon, dass verschiedene Quellen dieselben Begriffe meinen. `schema:Person`, `dbo:birthPlace`, `owl:sameAs` – das sind W3C-standardisierte Prädikate, die in Wikidata, DBpedia, Schema.org und eigenen Daten gleich bedeuten. 

Property Graphs werden zunehmend ebenfalls für Knowledge Graphs eingesetzt — Amazon Neptune (Multi-Model: RDF+SPARQL UND Property Graph+Gremlin) oder Microsoft Azure Cosmos DB zeigen, dass die Grenze verschwimmt. Der entscheidende Unterschied: Triple Stores haben URI-basierte offene Identitäten (gut für externe Verlinkung), Property Graphs haben bessere Traversierungsperformance.

---

*Quellen: [Oxigraph Architecture Wiki](https://github.com/oxigraph/oxigraph/wiki/Architecture) · [Jena TDB2 Docs](https://jena.apache.org/documentation/tdb2/) · [Neptune AWS Blog](https://aws.amazon.com/blogs/database/query-rdf-graphs-using-sparql-and-property-graphs-using-gremlin-with-the-amazon-athena-neptune-connector/)*

---
---

# 4 — ALLGEMEINE FRAGEN & ERKLÄRUNGEN

---

## RDF / RDFS / OWL / W3C — Überblick

### RDF — Fundament / Grammatik
- Datenmodell: alles als **Tripel** (Subjekt – Prädikat – Objekt)
- Globale Identifier: **IRIs** statt Text → weltweit eindeutig
- Kein starres Schema; neue Tripel jederzeit einhängbar
- Eigenes Basis-Vokabular mit Präfix `rdf:` (z.B. `rdf:type`, `rdf:Property`)
- **RDF = abstrakte Grammatik** (Struktur), kein Vokabular selbst

### RDFS (RDF Schema) — Basis-Vokabular / Struktur
- Erweiterung für RDF: beschreibt **Bedeutung** der Daten
- **Klassen & Hierarchien:** `rdfs:subClassOf`, `rdfs:Class`
  - `Student rdfs:subClassOf Person` → jeder Student = automatisch auch Person (ohne expliziten Datensatz)
- **Einschränkungen:** `rdfs:domain` (erlaubter Subjekt-Typ), `rdfs:range` (erlaubter Objekt-Typ)
- Zwei Ebenen:
  - **Instanz-Ebene:** `Alice rdf:type Student`
  - **Metadaten-Ebene:** `Student rdf:type rdfs:Class` → definiert Student als Klasse
- Basis-Inferenz: Schlüsse aus Klassenhierarchien (ohne alles explizit einzutragen)

### OWL (Web Ontology Language) — Komplexe Logik
- Baut auf RDFS auf; wesentlich mächtiger
- Kann ausdrücken:
  - Zwei Ressourcen sind identisch: `owl:sameAs`
  - Klassen schließen sich aus: disjoint
  - Eigenschaft ist Gegenteil einer anderen: inverse property
  - Komplexe Regeln: "Vollzeitstudent = Student mit ≥30 Credits"
- **Reasoner** klassifiziert automatisch: Alice hat 30 Credits → System schließt selbst, dass sie Vollzeitstudentin ist, ohne manuelle Markierung

### W3C (World Wide Web Consortium) — Standardisierungs-Schiedsrichter
- Gibt **Recommendations** (offizielle Web-Standards) heraus: RDF, RDFS, OWL, SPARQL
- Ohne W3C: jede Firma erfindet eigene Sprache (wie bei Neo4j mit Cypher)
- Mit W3C: SPARQL-Abfrage & Turtle-Datei funktionieren in GraphDB UND Jena **identisch**
- Standardisiert auch Serialisierungsformate: Turtle, JSON-LD, RDF/XML, N-Triples

---

## URI vs. IRI

| | URI | IRI |
|---|---|---|
| Zeichensatz | ASCII (begrenzt) | Unicode (vollständig, z.B. Umlaute, CJK) |
| Verhältnis | Teilmenge | Obermenge (jeder URI ist ein IRI) |

- Umgangssprachlich: "Link" — fachlich: IRI
- RDF-Dokumentation verwendet heute konsequent **IRI**

---

## Was W3C bei SPARQL festlegt

### Syntax & Aufbau
- Strikt definierte Reihenfolge: `PREFIX` → Query-Typ → `FROM` → `WHERE`
- Triple Patterns mit Variablen: `?person uni:kennt ?freund`
- Operatoren: `FILTER`, `OPTIONAL`, Aggregationen (`COUNT`, `SUM`), Pfadausdrücke (`+`, `*`, `/`)

### Query-Typen & Rückgaben
| Typ | Rückgabe |
|---|---|
| `SELECT` | Tabelle (Variablenbindungen) |
| `CONSTRUCT` | Neuer RDF-Graph (Triples nach Vorlage) |
| `ASK` | Boolean (true/false) |
| `DESCRIBE` | RDF-Graph — Inhalt **implementierungsabhängig** (Store entscheidet selbst, was "nützlich" ist) |

### Ausgabeformate
- SELECT: JSON, CSV, TSV, XML (SPARQL Results XML Format)
- CONSTRUCT / DESCRIBE: Turtle, JSON-LD, N-Triples, RDF/XML

### Weitere Festlegungen
- **RDF Concepts:** Was ein Triple ist, wie IRIs, Literale, Blank Nodes funktionieren
- **SPARQL 1.1 Protocol:** HTTP-Kommunikation mit SPARQL-Endpoint (wie eine Abfrage gesendet wird)
- **Inferenz-Regimes:** wie ein Reasoner auf RDFS/OWL-Definitionen reagieren soll

Gerne erkläre ich dir diese Konzepte im Kontext von RDF-Semantik und Triplestore-Architekturen basierend auf den Quellen.

### 1. Entailment, Equivalence und Inconsistency (Semantik)

Diese Begriffe beschreiben die logischen Beziehungen zwischen RDF-Graphen, wie sie in der RDF-Semantik-Spezifikation definiert sind.

*   **Entailment (Folgerung):** Ein RDF-Graph $A$ „folgt logisch“ aus einem Graphen $B$ (oder wird von diesem *entailed*), wenn jede mögliche Anordnung der Welt, die $A$ wahr macht, auch $B$ wahr macht. In der Praxis bedeutet das, dass durch Inferenzsysteme (Reasoner) **implizites Wissen aus explizit gespeicherten Fakten** abgeleitet werden kann. Ein Beispiel: Wenn ein Graph besagt, dass „Stuttgart in Baden-Württemberg liegt“ und eine Regel definiert, dass die „liegt in“-Beziehung transitiv ist, dann folgt daraus logisch, dass Stuttgart auch in Deutschland liegt, selbst wenn dies nicht explizit gespeichert ist.
*   **Equivalence (Äquivalenz):** Zwei RDF-Graphen $A$ und $B$ sind äquivalent, wenn sie **dieselbe Behauptung über die Welt** aufstellen. Formal ist dies der Fall, wenn $A$ logisch aus $B$ folgt und umgekehrt $B$ logisch aus $A$ folgt ($A$ entails $B$ und $B$ entails $A$).
*   **Inconsistency (Inkonsistenz):** Ein RDF-Graph ist inkonsistent, wenn er einen **internen Widerspruch** enthält. Es gibt dann keine mögliche Welt, in der die Aussagen des Graphen wahr sein könnten. Ein Beispiel hierfür wäre die Verwendung eines Literals, das nicht den definierten Datentyp-Beschränkungen entspricht (z. B. ein String-Wert für ein Integer-Feld).

### 2. Forward und Backward Chaining (Architektur)

Beim Design der Inferenzschicht (Reasoning) in der Architektur eines Triplestores gibt es zwei grundlegend verschiedene Ansätze, wie logische Schlussfolgerungen verarbeitet werden:

*   **Forward Chaining (Materialisierung):**
    *   **Zeitpunkt:** Die Regeln werden direkt **beim Laden der Daten** angewendet.
    *   **Prozess:** Der Reasoner leitet alle möglichen impliziten Triples ab und speichert diese dauerhaft in der Datenbank ab.
    *   **Vorteil:** Die Abfragegeschwindigkeit (**Query-Performance**) ist sehr hoch, da die Ergebnisse der Inferenz bereits als fertige Fakten vorliegen.
    *   **Nachteil:** Es wird deutlich **mehr Speicherplatz** benötigt, da die Anzahl der Triples durch die materialisierten Fakten stark ansteigen kann.

*   **Backward Chaining (Query-Time Reasoning):**
    *   **Zeitpunkt:** Die logischen Regeln werden erst **zum Zeitpunkt der Abfrage** angewendet.
    *   **Prozess:** Der Triplestore berechnet die impliziten Antworten „on-the-fly“, während die SPARQL-Anfrage verarbeitet wird.
    *   **Vorteil:** Es wird **weniger Speicherplatz** benötigt, da nur die expliziten Fakten physisch gespeichert werden.
    *   **Nachteil:** Die **Abfragen sind langsamer**, da der Rechenaufwand für die Inferenz bei jeder Anfrage neu anfällt.

Zusammenfassend lässt sich sagen, dass **Forward Chaining auf Geschwindigkeit bei Abfragen** optimiert ist, während **Backward Chaining die Speichereffizienz** in den Vordergrund stellt.

---

# Property Graph Vergleich
Basierend auf den Quellen lassen sich die von dir genannten Punkte wie folgt ausführen:

### 1. Vergleich Property Graph (PG) vs. Triple Store (TS/RDF)

Der Hauptunterschied liegt in der Struktur und dem Einsatzzweck:

*   **Datenmodell:** Ein **Property Graph** besteht aus Knoten und Kanten, wobei beide beliebige Attribute (Properties) als Schlüssel-Wert-Paare speichern können. In einem **Triple Store** werden Daten als Subjekt-Prädikat-Objekt-Tripel gespeichert. Kanten sind hier keine eigenständigen Objekte mit Attributen.
*   **Abfragemodell:** Property Graphen nutzen Sprachen wie **Cypher**, die auf **Pattern Matching** und effiziente Traversierung (das "Wandern" durch den Graphen) fokussiert sind. Triple Stores nutzen **SPARQL**, das für die Integration verteilter Datenquellen und **Inferencing** (logisches Schließen) optimiert ist.
*   **Philosophie:** Property Graphen sind wie ein "Whiteboard-Modell" – man speichert die Daten so, wie man sie zeichnet. Triple Stores folgen strikten Web-Standards (W3C) und nutzen URIs zur weltweit eindeutigen Identifikation von Konzepten.

### 2. Schwachstellen unseres Systems (Triple Store)

Triple Stores haben im Vergleich zu Property Graphen oder relationalen Systemen spezifische Nachteile:

*   **Fehlende Kanten-Attribute:** Es ist in Standard-RDF nicht möglich, eine Beziehung direkt mit Eigenschaften (z. B. "Seit wann besteht die Freundschaft?") zu versehen. Dies erfordert komplexe Umwege wie die **Reifikation** (Einführung eines Zwischenknotens), was das Modell aufbläht und schwerfällig macht.
*   **Performance bei tiefen Traversierungen:** Da Triple Stores oft über Tabellenindizes (SPO-Indizes) arbeiten, skaliert die Abfragegeschwindigkeit bei sehr vielen Verknüpfungen (Hops) schlechter als bei nativen Graph-DBs, die "indexfreie Nachbarschaft" (physische Zeiger zwischen Datensätzen) nutzen.
*   **Hoher Modellierungsaufwand:** Der Entwurf formaler Ontologien (Regelwerke für Inferencing) ist zeitintensiv und erfordert spezialisierte Fachkräfte.
*   **Gefahr von Endlosschleifen:** Bei komplexen Ontologien gibt es keine Garantie, dass eine SPARQL-Abfrage immer terminiert; sie könnte theoretisch unendlich lange laufen.

### 3. Selbstbeziehung möglich in Triple Stores?

**Ja, Selbstbeziehungen sind in Triple Stores problemlos möglich.**

*   **Strukturell:** Ein RDF-Tripel besteht aus einem Subjekt, einem Prädikat und einem Objekt. Es gibt keine Regel, die verbietet, dass **Subjekt und Objekt identisch** sind.
*   **Beispiel:** Eine Ressource (z. B. ein Unternehmen oder ein Bauteil) kann über ein Prädikat mit sich selbst verknüpft werden. In der Graphentheorie wird dies als "Self-loop" bezeichnet.
*   **Rekursion:** Dies ist besonders bei rekursiven Strukturen wichtig, etwa wenn ein Teil aus anderen Teilen besteht (`Part -> HAS -> Part`). In einem Triple Store kann man einfach ausdrücken: `URI_A relatesTo URI_A`. Das System verarbeitet dies als eine Kante, die am selben Knoten beginnt und endet.

Zusammenfassend: Triple Stores sind ideal für die **globale Datenvernetzung und Logik**, leiden aber unter **Verbositäts- und Performance-Nachteilen** gegenüber Property Graphen, wenn es um attribute-reiche Beziehungen geht.

---

# Oxigraph vs. Jena

## Warum Oxigraph für diese Demo?

### ✅ Für Oxigraph spricht:

- **Rust-basiert** — kein JVM nötig, keine Java-Installation Voraussetzung
- **~16 MB Docker-Image** vs. ~150–200+ MB bei Jena Fuseki (JVM-Overhead)
- **Sekunden-Start** — ideal für Laptop-Demos bei begrenzter Zeit
- **Web-UI vorhanden** — YASGUI-basierter SPARQL-Editor auf `localhost:7878` (wie Jena Fuseki auch)
- **SPARQL 1.1 vollständig** — inklusive Property Paths, Federated Query, SPARQL Update
- **Passt Kurs-Kriterium:** "open-source, Docker, unter wenigen Minuten lauffähig"
- **Performance bei Updates** — einer der schnellsten Stores für Insert/Delete

### ❌ Gegen Oxigraph (Jena wäre besser bei):

- **Kein eingebautes Reasoning** — Jena hat RDFS/OWL-Reasoner nativ; wir nutzen Workaround: SPARQL Property Paths (`rdfs:subClassOf*`)
  - **Aber:** Didaktisch sogar besser — zeigt, wie SPARQL selbst Traversal+Inferenz kombiniert
- **Kleineres Ökosystem** — Jena = Apache-Projekt mit großer Community; Oxigraph = jünger, weniger Doku
- **Nur Single-Node** — keine Cluster/HA-Unterstützung; Jena kann skalieren
- **Weniger Features** — keine SHACL-Validation, keine Lucene-Volltextsuche, keine Named-Graph-Admin-UI

### Kurz-Antwort für Prof:

> "Oxigraph wegen Footprint (16 MB, kein JVM) und Startup-Zeit — maximale Reproduzierbarkeit auf Studenten-Laptops. Den fehlenden Reasoner kompensieren wir mit SPARQL Property Paths, was didaktisch besser ist: explizite Traversal statt versteckte Inferenz."

---

## Was ist die JVM? (Java Virtual Machine)

### Definition
- **Laufzeitumgebung** für Java-Programme
- Java-Code wird nicht direkt zu Maschinencode kompiliert, sondern zu **Bytecode**
- Die JVM übersetzt diesen Bytecode zur Laufzeit (JIT = Just-in-Time Compilation) in Maschinencode für das Betriebssystem

### Warum "Virtual Machine"?
- **Abstraktion:** JVM simuliert einen universellen Computer
- Funktioniert auf **Windows, macOS, Linux** — "Write once, run anywhere"
- Java-Programm sieht immer dieselbe JVM, unabhängig vom OS

### Problem für diese Demo: Ressourcen-Overhead
- JVM braucht **200–300 MB RAM** nur zum Starten (bevor Jena lädt)
- Docker-Image mit JVM: **150+ MB** (vs. Oxigraph 16 MB = **10× kleiner**)
- Jena Fuseki = in Java geschrieben → braucht JVM → größer, langsamer, mehr Setup

### Deshalb Oxigraph
- Rust kompiliert direkt zu **nativem Maschinencode** → kein Zwischenschritt
- Kein Runtime-Overhead → schneller Start, kleinere Images
- Perfekt für Laptop-Demos ohne Performance-Ballast
