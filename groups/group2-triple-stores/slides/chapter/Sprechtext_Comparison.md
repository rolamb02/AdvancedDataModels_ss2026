# Spickzettel – Kapitel: Comparison

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
