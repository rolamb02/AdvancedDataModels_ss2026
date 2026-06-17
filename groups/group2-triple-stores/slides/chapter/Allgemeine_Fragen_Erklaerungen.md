# Allgemeine Fragen & Erklärungen

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
