# Sprechtext – Kapitel: Comparison (Einordnung & Abgrenzung)

---

## Folie 1: Triple Store vs. SQL – kurze Wiederholung

**Was zeigt die Folie?**
Eine kompakte Tabelle, die die wichtigsten Unterschiede zwischen SQL-Datenbanken und Triple Stores gegenüberstellt.

---

### Sprechtext


**Dateneinheit:** In SQL ist die grundlegende Einheit eine *Zeile in einer Tabelle*. Ein Student, eine Universität, ein Kurs – alles landet in Zeilen mit vordefinierten Spalten. Im Triple Store ist die Grundeinheit ein einzelnes Faktum: Subjekt – Prädikat – Objekt. Kein Zeilen-Denken, kein Spalten-Denken.

**Beziehungen – Joins vs. Kanten:** In SQL modelliert man Beziehungen über Fremdschlüssel und löst sie zur Abfragezeit per JOIN auf. Ein JOIN heißt: "Kombiniere Zeilen aus Tabelle A mit Zeilen aus Tabelle B, wo Bedingung X gilt." Beispiel: Finde alle Studenten, die Prüfung X geschrieben haben *und* an der Uni Stuttgart studieren – das wären zwei JOINs über drei Tabellen. Je mehr Beziehungen, desto teurer. Im Triple Store dagegen *ist* die Beziehung eine Kante im Graphen. `Student_Romi → studiert_an → Uni_Stuttgart` ist ein einzelnes Triple. Es gibt keine Laufzeit-Verknüpfung – die Kante ist schon da. SPARQL nutzt das aus, indem es Variablen teilt: `?student studiert_an ?uni . ?uni liegt_in Stuttgart` – das verbindet automatisch, ohne expliziten JOIN-Befehl.

**Was heißt "nativ" und "native Kante" konkret?**
"Nativ" bedeutet: das Datenbankformat *ist direkt darauf ausgelegt*, diese Struktur zu speichern – kein Umweg, keine Simulation. Eine "native Kante" im Property Graph heißt: die Kante zwischen zwei Knoten ist als eigenständiges Objekt im Speicher abgelegt, mit direkten Zeigern (Pointern) zu Quell- und Zielknoten. Neo4j speichert zum Beispiel jeden Knoten und jede Kante als festen Eintrag auf der Festplatte, und jede Kante enthält direkt die Speicheradressen ihrer beiden Knoten.

Konkret: Wenn ich in Neo4j `(Romi)-[:KENNT]->(Marten)` abspeichere, liegt im Speicher ein Kanten-Datensatz, der sagt: "Quell-Knoten ist an Adresse X, Ziel-Knoten ist an Adresse Y, Typ ist KENNT." Das ist eine native Kante – kein Join-Tabellen-Umweg, kein String-Lookup, sondern ein direkter Pointer. Im Triple Store ist `uni:Romi uni:kennt uni:Marten` auch eine Art Kante, aber technisch gespeichert als drei IDs in einer Tabellenzeile – die "Kante" ist implizit durch die Kombination von Subjekt und Objekt, nicht als eigenständiges Speicherobjekt mit Pointern.

**Schema:** SQL verlangt vorab definierte Spalten. Will man ein neues Attribut, braucht man `ALTER TABLE`. Im Triple Store fügt man einfach neue Triples hinzu – das Schema wächst organisch.

**Consistency**
**SQL:** Volle ACID-Garantien eingebaut — jede Transaktion ist atomar, konsistent, isoliert, dauerhaft. Das war von Anfang an zentrales Design-Ziel relationaler DBs.

**Triple Store:** Kommt auf die Implementierung an:
- Oxigraph (wie in der Demo): bietet Transaktionen, aber keine vollständige Isolation — concurrent writes können Konflikte erzeugen
- GraphDB, Stardog: bieten vollständiges ACID, aber mit Performance-Overhead
- Distributed Triple Stores (wie Virtuoso im Cluster): oft nur Eventually Consistent

**Warum ist das bei Triple Stores schwieriger?** Ein einzelner Vorgang ("Alice studiert jetzt an Uni B statt A") bedeutet: altes Triple löschen + neues Triple einfügen — zwei Operationen. In SQL ist das ein einziges UPDATE. Bei Millionen verteilter Triples ist atomare Konsistenz technisch aufwendiger.

**Sprechtext-Formulierung:** "SQL garantiert Konsistenz per Design — Triple Stores können das auch, aber es ist nicht überall Standard, und man muss gezielt den richtigen Store wählen."

**Semantik – was heißt das?** Semantik bedeutet *Bedeutung*. In SQL weiß die Datenbank nicht, was "Professor" bedeutet – sie weiß nur, dass es einen Wert in einer Spalte gibt. Ein Triple Store mit RDFS oder OWL *versteht* Bedeutungsebenen. Wenn ich definiere, dass `Professor` eine Unterklasse von `Person` ist (`rdfs:subClassOf`), kann das System *schlussfolgern*, dass jeder Professor automatisch auch eine Person ist – ohne dass ich das nochmal explizit eintragen muss. Das nennt sich Inferenz. Wichtig: Inferenz ist **nicht** dasselbe wie Traversal – dazu mehr bei Folie 2.

**Datenintegration:** In SQL ist das aufwändig – man braucht ETL-Prozesse (Extract, Transform, Load), also manuelle Pipelines, die Daten aus externen Quellen bereinigen und ins eigene Schema überführen. Im Triple Store nutzen wir URIs als globale Identifier. Eine URI wie `http://dbpedia.org/resource/Stuttgart` meint weltweit dasselbe, egal ob meine Datenbank oder DBpedia sie benutzt. Über `SERVICE` in SPARQL kann ich dann live gegen externe SPARQL-Endpunkte abfragen – das ist Federation. URI + SERVICE = Datenintegration ohne ETL-Pipeline.

**Interaktion**: Wer weiß für was ETL noch stand
Lückentext

**Sobald Vernetzung und Semantik wichtig werden – was genau heißt das?**
*Vernetzung:* Wenn Entities nicht isoliert existieren, sondern in Beziehung zueinander stehen – und diese Beziehungen selbst abgefragt, navigiert oder erweitert werden müssen. Beispiel: "Welche Professoren forschen an Themen, die mit dem Fachgebiet einer Kooperationsuni zusammenhängen?" – das sind mehrere verknüpfte Entitäten. SQL braucht dafür komplexe mehrstufige JOINs. Triple Stores navigieren das nativ.
*Semantik:* Sobald das System selbst verstehen soll, was Begriffe bedeuten, wie Klassen zusammenhängen, und was implizit gilt – also Inferenz gefragt ist.

**Takeaway:** SQL ist die richtige Wahl für strukturierte, stabile, transaktionale Daten. Triple Stores gewinnen, sobald Vernetzung über Quellen hinweg und semantisches Schlussfolgern gefragt sind.

---

## Folie 2: Triple Store vs. Property Graph – die wichtige Abgrenzung

**Was zeigt die Folie?**
Vergleichstabelle zwischen RDF Triple Stores und Property Graphs (z.B. Neo4j). Beide sind Graphmodelle – die Unterschiede sind aber fundamental.

---

### Sprechtext


**Standardisierung – was genau ist gemeint?**
Es geht um zwei Ebenen. Erstens: Cypher (Neo4j) definiert zwar Abfragesyntax – aber das ist ein herstellerspezifischer Standard, kein W3C-Standard. Verschiedene Property-Graph-Systeme sprechen verschiedene Dialekte. SPARQL hingegen ist W3C-standardisiert: jeder konforme Triple Store versteht dieselbe Abfragesprache. Zweitens – und das ist entscheidend: Es gibt standardisierte *Vokabulare*. RDFS, OWL, Dublin Core, Schema.org – das sind gemeinsam vereinbarte Bedeutungen für Prädikate und Klassen. `rdfs:subClassOf`, `owl:sameAs`, `dbo:birthPlace` – diese URIs haben weltweit eine definierte Bedeutung. Das ermöglicht semantische Interoperabilität zwischen verschiedenen Systemen, die dieselben Vokabulare nutzen. Property Graphs haben das nicht.

**Inferenz vs. Traversal – das ist NICHT dasselbe:**
Das ist ein häufiges Missverständnis, daher klar trennen:

- **Traversal** = ich bewege mich entlang *bereits existierender* Kanten im Graph. `rdfs:subClassOf*` in einem Property Path traversiert alle subClassOf-Kanten, die tatsächlich im Store liegen. `*` = null oder mehr Schritte, `+` = mindestens ein Schritt. Das ist reines Navigieren auf dem, was da ist.
- **Inferenz** = der Store *leitet neue Fakten ab*, die nicht explizit gespeichert wurden. Wenn definiert ist `Professor rdfs:subClassOf Person` und im Store liegt `Prof_Müller rdf:type Professor`, dann *inferiert* der Store: `Prof_Müller rdf:type Person` – auch wenn dieses Triple nie eingetragen wurde. Das sind *neue, abgeleitete Triples*, die zur Laufzeit oder vorab materialisiert werden.

Traversal fragt: "Was existiert schon?" – Inferenz sagt: "Was gilt logisch außerdem, auch wenn es nicht steht?" Property Graphs können beides nicht automatisch – das muss man manuell in die Applikation bauen.


**Traversal-Performance – warum genau ist Property Graph technisch schneller? (mit Beispiel)**
Das lässt sich gut anhand eines konkreten Szenarios erklären. Stell dir vor, wir suchen in einem sozialen Netzwerk alle Personen, die über maximal 4 Hops mit Romi verbunden sind. Also: Romis Freunde, deren Freunde, deren Freunde, deren Freunde.

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

**Kanten-Eigenschaften – ein fundamentaler Unterschied**
Im Property Graph kann eine Kante direkt eigene Properties haben. Beispiel: `Romi –[KENNT seit: 2020]→ Marten`. Das `seit: 2020` ist eine Property *an der Kante selbst*. Im Triple Store ist das nicht nativ möglich – eine Kante ist immer nur `Subjekt → Prädikat → Objekt`, ohne eigene Attribute. Will man zusätzliche Metadaten an einer Beziehung ausdrücken, muss man die Beziehung selbst zur Ressource machen und mit weiteren Triples beschreiben (Reifikation) – das funktioniert, ist aber deutlich umständlicher als native Kanten-Properties im Property Graph. Das ist ein echter Nachteil des Triple-Store-Modells für Anwendungsfälle, wo Kanten-Metadaten zentral sind.


**URIs, Linked Data, Federation – drei verschiedene Dinge:**
- **URIs** = das Konzept globaler, eindeutiger Identifier für Ressourcen. `http://dbpedia.org/resource/Stuttgart` ist weltweit eindeutig, kein String-Vergleich.
- **Linked Data** = das *Prinzip*, RDF-Daten unter diesen URIs öffentlich zu veröffentlichen, so dass andere sie abrufen und verlinken können. DBpedia, Wikidata, GeoNames – das sind Linked-Data-Quellen.
- **Federation** = der konkrete *Abfragemechanismus* in SPARQL: `SERVICE <endpunkt>` fragt live gegen einen externen SPARQL-Endpunkt ab und verbindet das Ergebnis mit lokalen Daten.

Drei Schichten: URIs = Identität, Linked Data = Veröffentlichungsprinzip, Federation = Abfragemechanismus. Property Graphs haben nichts davon nativ – eine Neo4j-Datenbank spricht nicht von selbst mit anderen Systemen.

**Warum brauche ich für dbo-Prädikate kein SERVICE, für das Stuttgart-Objekt aus DBpedia aber schon?**
Das ist eine sehr gute Frage, die den Kernunterschied zwischen Prädikaten und Objekten in RDF zeigt.

Wenn wir in unserer `universitaeten.ttl` schreiben:
```turtle
@prefix dbo: <http://dbpedia.org/ontology/> .
uni:UniStuttgart dbo:location uni:Stuttgart .
```
…dann *benutzen* wir `dbo:location` nur als Prädikat – als Namen für eine Beziehung. Wir laden dabei keine Daten von DBpedia. Das Prädikat ist einfach eine URI, die wir selbst in unserer TTL-Datei definiert haben (über den `@prefix`-Block am Anfang). Oxigraph weiß beim Laden der Datei: "Das Prädikat heißt `http://dbpedia.org/ontology/location`" – aber es fragt nirgends nach. Es ist wie eine Namenskonvention: ich nenne meine Beziehung so, wie DBpedia das auch tut, damit andere wissen was gemeint ist. Aber die Daten sind lokal.

Wenn wir dagegen wollen, dass `uni:Stuttgart` mit *echten Daten aus DBpedia* angereichert wird – also z.B. die Abstract-Beschreibung oder die Einwohnerzahl, die DBpedia selbst pflegt – dann liegt dieses Datum *nicht* in unserer Datenbank. Es liegt auf DBpedias Server. Dann brauchen wir `SERVICE`: Query 7 nutzt `owl:sameAs dbr:Stuttgart`, um zu sagen "unsere lokale `uni:Stuttgart`-Ressource ist dieselbe wie DBpedias `dbr:Stuttgart`", und dann holt `SERVICE <https://dbpedia.org/sparql> { ?dbCity dbo:abstract ?description }` live den Abstract von DBpedias Server ab.

Kurz: **Prädikate sind nur Label/Namen – die kommen immer aus dem lokalen TTL-Präfix-Block. Objekte/Ressourcen können echte externe Datenobjekte sein, die nur auf fremden Servern liegen – dafür braucht man SERVICE.**


---

## Folie 3: Wann nimmt man was? – Use-Case-Matrix

**Was zeigt die Folie?**
Eine Entscheidungsmatrix: 6 Anforderungsdimensionen gegen die drei Modelle (Relational, Property Graph, Triple Store) mit ✅ / ⚠️ / ❌.

---

### Sprechtext

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
