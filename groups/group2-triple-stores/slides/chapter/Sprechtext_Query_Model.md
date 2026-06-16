# Sprechtext – Kapitel: Query Model

Query model (15 min) – Introduce the query language (Cypher, SPARQL, ANN API, MongoDB queries, Redis commands, CQL, DuckDB SQL). Explain how queries differ from SQL.
---

## Folie 1: SPARQL – Pattern Matching statt Tabellen

---

### Kernpunkte

- **Der fundamentale Denkwechsel:** In SQL schreibe ich `FROM university JOIN city ON ...` — ich weiß genau, welche Tabellen existieren, und verknüpfe sie mit Schlüsseln. In SPARQL gibt es keine Tabellen. Ich beschreibe, wie das Gesuchte *aussieht* — und der Store findet alle Belegungen, die passen
- **Triple Pattern = Schablone:** Jedes Pattern ist ein RDF-Triple mit Variablen als Platzhalter
    - `?u a uni:University` → „Finde alles, das ein University-Typ ist"
    - `?u uni:location ?stadt` → „Hole dazu die Location-Ressource"
    - `?stadt uni:bundesland "Baden-Wuerttemberg"` → „Nur wenn die Location in BW liegt"
- **Geteilte Variablen verbinden Patterns:** `?u` taucht in zwei Patterns auf — das verbindet sie automatisch, ohne ein `JOIN`-Keyword. Analogie: Lückentext — alle Lücken mit demselben Namen müssen denselben Wert haben
- **SQL braucht eine Struktur, die man kennt. SPARQL braucht eine Beschreibung, die passt.**

 **Semantik-Kontext am SQL-Beispiel erklären:** Die `location_id = 42` im JOIN ist eine nackte Zahl — die Datenbank verknüpft damit Zeilen, aber sie weiß nicht, *was* 42 bedeutet. Das ist intern, proprietär, außerhalb der Datenbank bedeutungslos. Das Prädikat `uni:location` hingegen ist eine URI — sie verweist auf ein global definiertes, maschinenlesbares Konzept. Das Prädikat trägt Bedeutung. Und wenn man statt `uni:location` die standardisierte Property `schema:location` aus schema.org verwendet, versteht jeder Store weltweit dasselbe — ohne Absprache. *Das* ist der „Keine Semantik"-Badge beim SQL-Code und der „W3C-Standard"-Badge bei SPARQL in der Folie.


**Chain of Thought:**
> „Warum kein JOIN?" → weil die Verbindung *implizit* durch die geteilte Variable entsteht → weil der Graph selbst schon die Beziehungen trägt → kein Umweg über Fremdschlüssel-Tabellen nötig

---


## Folie 2: Query-Typen — SELECT · ASK · CONSTRUCT · DESCRIBE

---

### Kernpunkte

**SELECT** — tabellarische Variablenbindungen:
- Alle Demo-Queries verwenden SELECT. Gibt eine Tabelle zurück: eine Spalte pro Variable, eine Zeile pro Match
- Einsatz: Daten abfragen, anzeigen, in Anwendungen weiterverwenden

**ASK** — Boolean-Prüfung:
- `ASK { uni:AliceSchmidt a uni:Student . }` → `true` oder `false`
- Kein Ergebnis-Datensatz, nur Ja oder Nein
- Einsatz: Validierung vor einer Verarbeitung, Assertions in Datenpipelines, „Existiert dieser Datenpunkt überhaupt?"

**CONSTRUCT** — neuen RDF-Graph erzeugen:
- Query definiert ein Triple-Template: aus den Treffern werden neue Triples nach dem Template gebaut
- Einsatz: Daten aus mehreren Quellen in einheitliches Format überführen, Teilgraph exportieren, Regeln materialisieren, strukturierten Kontext für RAG-Pipelines aufbereiten
- Gibt RDF zurück, keine Tabelle


**Friend of a Friend** — ein standardisiertes RDF-Vokabular für Personen und soziale Netzwerke. W3C-spezifiziert, URI: `http://xmlns.com/foaf/0.1/`.

Typische Properties:
- `foaf:name` → Name einer Person
- `foaf:knows` → kennt eine andere Person
- `foaf:mbox` → E-Mail-Adresse
- `foaf:Person` → Klasse "Person"
- `foaf:memberOf` → Mitglied einer Organisation

In der Präsi taucht es in der CONSTRUCT-Query auf — dort wird `uni:`-Vokabular in `foaf:` übersetzt, um eigene Daten ins Standardformat zu bringen, das andere Systeme weltweit verstehen.


**DESCRIBE** — Beschreibung einer Ressource:
- `DESCRIBE uni:Stuttgart` → Store gibt alles zurück, was er über diese URI weiß
- Format nicht normiert, variiert je nach Store
- Einsatz: schnelle Exploration ohne Schema zu kennen

**AI-Relevanz:**
- CONSTRUCT: aufbereitete RDF-Graphen als Kontext für LLM-Antworten — jede Aussage auf konkrete Triples rückführbar → Explainability
- ASK: Konsistenz-Checks in automatisierten Wissensgraph-Pipelines


**Case-Sensitivity — wichtig für Fragen aus dem Publikum:**
- SPARQL-URIs sind vollständig **case-sensitiv**: `rdfs:label` und `rdfs:LABEL` sind *verschiedene URIs* — `rdfs:LABEL` expandiert zu `<...rdf-schema#LABEL>`, das nicht existiert → **0 Ergebnisse, kein Fehler**
- Gleiches gilt für nicht-existente Prädikate wie `rdfs:label1` — syntaktisch gültig, aber kein Triple im Store matcht → 0 Ergebnisse
- SPARQL wirft keinen Fehler für unbekannte Prädikate (Open World: fehlen = unbekannt, nicht falsch)
- Keywords wie `SELECT`, `WHERE`, `FILTER` sind hingegen **case-insensitiv**

**Query Optimizer — genauer:**
- Die Reihenfolge der Patterns im WHERE-Block ist dem Store überlassen — der Query Optimizer entscheidet
- Prinzip: Der Optimizer schätzt die **Selektivität** jedes Patterns — d.h. wie viele Triples dieses Muster matchen. Ein Pattern wie `?u a uni:University` liefert vielleicht 5 Treffer, `?s ?p ?o` tausende
- Er beginnt mit dem **selektivsten Pattern** (wenigste Treffer), weil das die Kandidatenmenge sofort klein hält. Alle folgenden Joins operieren dann auf diesem reduzierten Set — exakt wie ein SQL-Query-Planner JOIN-Reihenfolgen optimiert

---

## Folie 3: SELECT & WHERE – Anatomie einer SPARQL-Query

---

### Kernpunkte

**PREFIX — Namespace-Abkürzung:**
- `uni:University` steht für `<http://example.org/uni/University>`
- Vergleich: wie `import numpy as np` in Python — man lädt keine externe Datenbank, man gibt einem langen Pfad einen kurzen Namen
- Ohne PREFIX muss man überall die volle URI in spitzen Klammern schreiben — lesbar, aber mühsam

**SELECT + WHERE:**
- `SELECT ?u ?name` — welche Variablen als Spalten zurückgegeben werden
- `WHERE { ... }` — die Musterbedingungen; jede Zeile ist ein Triple Pattern
- Alle Patterns müssen gleichzeitig erfüllt sein (implizites AND)
- `ORDER BY`, `LIMIT`, `OFFSET` funktionieren wie in SQL

**Schlüsselkonzept Variablen:**
- Namen sind bedeutungslos: `?u`, `?x`, `?baum` liefern dasselbe Ergebnis
- Der Typ kommt aus dem Pattern (`?s a uni:University`), nicht aus dem Variablennamen
- Gleichnamige Variablen in verschiedenen Patterns müssen denselben Wert haben — das ist der implizite Join-Mechanismus

---

## Folie 4: FILTER · OPTIONAL · Property Paths

---

### Kernpunkte

**FILTER:**
- Schränkt bereits gebundene Variablen ein: `FILTER(?semester >= 5)`
- Kommt *nach* den Pattern-Bindungen — erst werden Matches gefunden, dann gefiltert. FILTER ersetzt kein Pattern
- Analog SQL WHERE, aber auf Graph-Muster-Ergebnissen

**OPTIONAL:**
- `OPTIONAL { ?p uni:fachgebiet ?fach . }` — Professoren ohne Fachgebiet bleiben im Ergebnis, `?fach` bleibt einfach leer (unbound)
- SQL LEFT JOIN: alle Zeilen der linken Seite, NULL wenn kein Match rechts
- Hintergrund — **Open World Assumption**: im RDF-Modell bedeutet ein fehlendes Triple „unbekannt", nicht „falsch". Das ist eine bewusste Design-Entscheidung
- **Ohne OPTIONAL:** das Pattern muss vollständig matchen. Fehlt der Wert, fällt die ganze Zeile raus — kein Fehler, einfach kein Match. 0 Ergebnisse für diese Entität

**Property Paths:**
- Die Symbole kommen aus der Regex-Welt — wer Regex kennt, kann sie sofort lesen:
    - `|` = „oder": `(uni:studiesAt | uni:worksAt)` → „studiert an *oder* arbeitet an"
    - `*` = 0 oder mehr Schritte: `rdfs:subClassOf*` → „Klasse selbst oder beliebig viele Schritte hoch"
    - `+` = mindestens 1 Schritt: `rdfs:subClassOf+` → „direkte Superklasse und aufwärts, nicht die Klasse selbst"
    - `/` = Verkettung: erst Schritt A, dann Schritt B entlang der Kante
- Gilt nur für **Prädikate** in einem einzigen Triple Pattern — nicht für ganze WHERE-Blöcke

**`+` (mindestens 1 Schritt) vs. `*` (0 oder mehr Schritte):**

```sparql
-- * : findet Student selbst UND alle Oberklassen (Person)
?x rdfs:subClassOf* uni:Student

-- + : findet NUR die Oberklassen (Person), NICHT Student selbst
?x rdfs:subClassOf+ uni:Student
```

Praktisch: `rdfs:subClassOf+` wäre z.B. sinnvoll wenn du willst "welche Klassen stehen *über* Student" — ohne Student in der Ergebnismenge zu haben.

---

**`/` (Verkettung):**

```sparql
-- Ohne /: zwei separate Patterns
?person uni:studiesAt ?uni .
?uni uni:location ?city .

-- Mit /: ein einziger Property Path
?person uni:studiesAt/uni:location ?city .
```

`uni:studiesAt/uni:location` heißt: "gehe von Person über `studiesAt` zur Uni, dann von dort über `location` zur Stadt." Das ist reines Syntactic Sugar — kompakter, aber identisches Ergebnis.


- Für alternative *Muster* (z.B. Typ-Alternativen) braucht man `UNION`: `{ ?p a uni:Student } UNION { ?p a uni:Professor }`

- SQL kennt kein direktes Äquivalent — rekursive CTEs wären nötig

---

## Folie 5: Aggregation – COUNT, GROUP BY, ORDER BY

---

### Kernpunkte

**Die Query — Personen pro Universität (Query 6):**
- `SELECT ?uniname (COUNT(?person) AS ?anzahl)` + `GROUP BY ?uniname` + `ORDER BY DESC(?anzahl)`
- **Wichtige Unterscheidung:** `COUNT(?person)` *zählt* die Personen pro Gruppe — `GROUP BY ?uniname` *gruppiert* nach Universität. Die Gruppenbildung macht `GROUP BY`, nicht `COUNT`. Syntaktisch fast identisch zu SQL GROUP BY — konzeptuell anders, weil die Treffermenge nicht aus einem Tabellen-Scan, sondern aus Graph-Pattern-Matching stammt


**Was steckt drin:**
- `?typ rdfs:subClassOf* uni:Person` — findet alle Unterklassen von Person: Student, Professor, Staff. Mit `*` auch direkte Treffer (0 Schritte)
- `?person a ?typ` — findet die *Instanzen* dieser Klassen, nicht die Klassen selbst. Deshalb braucht es beide Patterns zusammen
- `(uni:studiesAt | uni:worksAt)` — Property Path Union: Personen egal ob Studierende oder Mitarbeitende

**Wichtige Abgrenzung:**
- **Aggregation** verdichtet vorhandene Treffer: COUNT, SUM, AVG, MIN, MAX
- **Inferenz** leitet neue Fakten ab: `Student subClassOf Person` → Alice ist Person
- Beides kommt hier vor — aber es sind grundlegend verschiedene Konzepte

---

## Folie 6: Der Aha-Moment – Inferenz (Query 4 vs. Query 5)

---

### Kernpunkte

**Das Setup:**
- Im Store steht: `uni:Student rdfs:subClassOf uni:Person`, ebenso für Professor und Staff
- Alice ist als `uni:Student` gespeichert — *nie* explizit als `uni:Person`

**Query 4 — ohne Klassenhierarchie → 0 Ergebnisse:**
- `SELECT ?p WHERE { ?p a uni:Person . }`
- Store gibt nur zurück, was *wörtlich* drin steht. Kein `alice a uni:Person`-Triple → keine Treffer
- Genau wie SQL: keine impliziten Ableitungen

**Query 5 — mit Klassenhierarchie → 7 Ergebnisse:**
- `SELECT ?p WHERE { ?p a ?typ . ?typ rdfs:subClassOf* uni:Person . }`
- Zwei Patterns: erst Individuum → Klasse (`?p a ?typ`), dann Klassenhierarchie traversieren
- Warum zwei Patterns? `?p rdfs:subClassOf* uni:Person` allein würde nur *Klassen* finden (Student, Professor) — nicht *Instanzen* (Alice, Bob)

**Chain of Thought:**
> Store weiß: `Student rdfs:subClassOf Person` → Alice ist Student → also *gilt*: Alice ist Person
> SQL gibt zurück, was *steht*. SPARQL + Ontologie gibt zurück, was *gilt*

**Abgrenzung Traversal vs. Inferenz:**
- **Traversal (hier):** bewegt sich entlang *existierender* `subClassOf`-Kanten — echte gespeicherte Triples
- **Inferenz/Entailment (kommt in Architecture):** Store leitet *neue* Triples ab und materialisiert sie — `Alice a Person` existiert dann explizit im Store

**Property Graph-Vergleich:**
- Property Graphs: direkte Speicher-Pointer zwischen Knoten → Traversal-Schritt = Pointer-Lookup. Sehr schnell bei tiefer, struktureller Navigation in einer Datenbank
- RDF: Index-Lookup pro Schritt — bei rein struktureller Traversal etwas langsamer
- RDF gewinnt beim *semantischen* Traversal: `rdfs:subClassOf*` nutzt Ontologie-Wissen. Property Graph kennt Klassenhierarchien nicht nativ — müsste manuell modelliert und durchlaufen werden

---

## Folie 7: Federated Queries – Das Web of Data

---

### Kernpunkte

**SERVICE-Pattern (Query 7):**
- `SERVICE <https://dbpedia.org/sparql> { ?dbCity dbo:abstract ?description . FILTER (lang(?description) = "de") }`
- Der SERVICE-Block geht live an den externen Endpoint — Antwort kommt zurück und wird mit lokalen Daten gejoint
- Keine Datenkopie, kein Import, kein ETL

**Verbindung über owl:sameAs:**
- `uni:Stuttgart owl:sameAs dbr:Stuttgart` — verknüpft lokale URI mit globaler DBpedia-URI
- Der Store weiß: beide Bezeichner meinen dieselbe Entität → Bindeglied zwischen lokalem Store und DBpedia

**Warum das nur mit W3C SPARQL geht:**
- Oxigraph, DBpedia, Wikidata, GraphDB, Amazon Neptune — alle sprechen denselben Standard
- Neo4j Cypher oder MongoDB können nicht gegen externe Endpoints queren — keine gemeinsame Sprache
- W3C-Standardisierung bedeutet konkret: ein Query-Mechanismus, viele Datenquellen weltweit. Das sieht man hier in Aktion

**Ausgabeformate:** JSON (APIs, RAG-Pipelines), CSV (Tabellenanalyse), RDF/XML (CONSTRUCT-Export)

**Demo-Hinweis:** Query 7 ist internetabhängig — kann langsam sein oder fehlschlagen. Screenshot-Fallback bereithalten.

---


## Kapitel-Takeaway

> SPARQL fragt keine Tabellen ab — es matcht Bedeutungsstrukturen im Graphen.
> Der Mehrwert in fünf Stufen: Patterns statt Tabellen (F1–2) → FILTER/OPTIONAL/Paths (F3) → Aggregation (F4) → Klassenhierarchie-Traversal als Aha-Moment (F5) → globale Datenintegration live (F6) → vier Query-Formen für vier Aufgaben (F7).
