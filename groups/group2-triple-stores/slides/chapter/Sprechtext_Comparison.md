# Sprechtext – Kapitel: Comparison (Einordnung & Abgrenzung)

---

## Folie 1: Triple Store vs. SQL – kurze Wiederholung


**Consistency**
**SQL:** Volle ACID-Garantien eingebaut — jede Transaktion ist atomar, konsistent, isoliert, dauerhaft. Das war von Anfang an zentrales Design-Ziel relationaler DBs.

**Triple Store:** Kommt auf die Implementierung an:
- Oxigraph (wie in der Demo): bietet Transaktionen, aber keine vollständige Isolation — concurrent writes können Konflikte erzeugen
- GraphDB, Stardog: bieten vollständiges ACID, aber mit Performance-Overhead
- Distributed Triple Stores (wie Virtuoso im Cluster): oft nur Eventually Consistent

**Warum ist das bei Triple Stores schwieriger?** Ein einzelner Vorgang ("Alice studiert jetzt an Uni B statt A") bedeutet: altes Triple löschen + neues Triple einfügen — zwei Operationen. In SQL ist das ein einziges UPDATE. Bei Millionen verteilter Triples ist atomare Konsistenz technisch aufwendiger.

**Interaktion**: Wer weiß für was ETL noch stand (Extract, Transform, Load)


---

## Folie 2: Triple Store vs. Property Graph – die wichtige Abgrenzung

**Was zeigt die Folie?**
Vergleichstabelle zwischen RDF Triple Stores und Property Graphs (z.B. Neo4j). Beide sind Graphmodelle – die Unterschiede sind aber fundamental.

---

### Sprechtext


**Standardisierung – was genau ist gemeint?**
Es geht um zwei Ebenen. Erstens: Cypher (Neo4j) definiert zwar Abfragesyntax – aber das ist ein herstellerspezifischer Standard, kein W3C-Standard. Verschiedene Property-Graph-Systeme sprechen verschiedene Dialekte. SPARQL hingegen ist W3C-standardisiert: jeder konforme Triple Store versteht dieselbe Abfragesprache. Zweitens – und das ist entscheidend: Es gibt standardisierte *Vokabulare*. RDFS, OWL, Dublin Core, Schema.org – das sind gemeinsam vereinbarte Bedeutungen für Prädikate und Klassen. `rdfs:subClassOf`, `owl:sameAs`, `dbo:birthPlace` – diese URIs haben weltweit eine definierte Bedeutung. Das ermöglicht semantische Interoperabilität zwischen verschiedenen Systemen, die dieselben Vokabulare nutzen. Property Graphs haben das nicht.



**Traversal-Performance – warum genau ist Property Graph technisch schneller? (mit Beispiel)**

Im **Property Graph (Neo4j)**:
Neo4j speichert jeden Knoten als festen Datensatz auf der Festplatte. Jeder Knoten enthält einen Pointer (eine direkte Speicheradresse) auf seine erste ausgehende Kante. Jede Kante enthält wiederum Pointer auf den nächsten Knoten *und* auf die nächste Kante desselben Knotens. Das ist eine verkettete Liste direkt im Speicher.

Wenn ich von "Romi" einen Hop mache:
1. Gehe zu Romis Knoteneintrag → lese Pointer auf erste Kante → O(1), ein Speicherzugriff.
2. Gehe zur Kante → lese Pointer auf Zielknoten → O(1), ein Speicherzugriff.
3. Nächste Kante von Romi: Kante enthält Pointer auf nächste Kante → O(1).

Jeder Hop ist also buchstäblich ein oder zwei Pointer-Sprünge im Speicher. Bei 4 Hops mit je 10 Freunden: 10 + 100 + 1000 + 10000 = ~11.110 Pointer-Sprünge. Kein Index-Lookup, kein Suchen.

Im **Triple Store (Oxigraph/Jena)**:
Es gibt keine physischen Pointer zwischen Triples. Stattdessen liegt eine Index-Tabelle vor (z.B. SPO-Index). Wenn ich von Romi einen Hop mache, muss der Store im Index nachschlagen: "Gib mir alle Triples, wo Subjekt = uni:Romi und Prädikat = uni:kennt." Das ist ein B-Tree- oder Hash-Index-Lookup – schnell, aber nicht O(1) wie ein Pointer, sondern O(log n) oder O(1) mit Hash, plus der Overhead des Index-Traversals. Für jeden einzelnen Knoten auf jeder Ebene wird ein neuer Index-Lookup ausgeführt.

Bei 4 Hops mit je 10 Freunden: dieselbe Anzahl an Lookups, aber jeder einzelne Lookup ist langsamer als ein Pointer-Sprung, weil Indizes im Vergleich zu direkten Speicheradressen teurer sind – besonders wenn der Graph größer wird und nicht mehr vollständig im RAM liegt.

**Fazit:** Property Graph ist bei tiefer Traversal in *einer* Datenbank schneller, weil die Graphstruktur direkt in der Speicherorganisation abgebildet ist – Pointer statt Index-Lookup. Triple Store ist dafür stärker bei semantischer Reichweite und externer Datenintegration, wo kein Property Graph mithalten kann.



**Warum brauche ich für dbo-Prädikate kein SERVICE, für das Stuttgart-Objekt aus DBpedia aber schon?**
 Prädikate sind nur Label/Namen – die kommen immer aus dem lokalen TTL-Präfix-Block. Objekte/Ressourcen können echte externe Datenobjekte sein, die nur auf fremden Servern liegen – dafür braucht man SERVICE.


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

Property Graphs werden zunehmend ebenfalls für Knowledge Graphs eingesetzt — Technologien wie Amazon Neptune oder Microsoft Azure Cosmos DB zeigen, dass die Grenze verschwimmt. Der entscheidende Unterschied: Triple Stores haben URI-basierte offene Identitäten (gut für externe Verlinkung), Property Graphs haben bessere Traversierungsperformance.


*Ende Kapitel Comparison*


https://www.youtube.com/watch?v=m_9_23jXPoE&t=16s


