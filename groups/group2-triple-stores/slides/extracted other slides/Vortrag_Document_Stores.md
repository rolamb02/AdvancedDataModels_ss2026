Advanced Data Models SoSe2026
Document Stores
Lars Wieck & Luca Raichle
April 2026

Agenda
01 Motivation 10 min
02 Konzeptionelles Modell 15 min
03 Datenstruktur 15 min
04 Abfragemodell 15 min
05 Architekturüberblick 15 min
06 Vergleich mit rel. Datenbanken 10 min
07 Praktische Demo 30 min
08 Challenge 20 min
09 KahootQuiz 10 min
10
Diskussion 10 min

Motivation

Schritt 1: Homogene Entitäten
Ein Online-Händler verkauft ausschließlich Bücher - alle Produkte teilen dieselben Attribute.
Tabelle: PRODUKTE
| ISBN | Titel | Autor | Verlag | Seiten | Preis |
| ---- | ----- | ----- | ------ | ------ | ----- |
978-0134685991 Effective Java Bloch Addison-Wesley 412 39,90 €
| 978-0132350884 | Clean Code | Martin | Pearson | 464 | 34,90 € |
| -------------- | ---------- | ------ | ------- | --- | ------- |
978-0135957059 Pragmatic Programmer Hunt / Thomas Addison-Wesley 352 29,90 €
978-0135957002 AdvancedData Models Esslingen Seyler Esslingen-Verlag 222 24,90 €
Sauberes Schema  ·  alle Felder gefüllt  ·  keine Redundanz  =>  relationales Modell ist optimal
…aber die Realität bleibt selten so einfach

Schritt 2: Erste Heterogenität
Das Sortiment wird um Musik-Alben erweitert. Schema-Erweiterung per ALTER TABLE → neue Spalten für Musik-
spezifische Attribute.
Tabelle: PRODUKTE  (mit neuen Spalten für Musik)
| ISBN | Titel | Autor | Seiten | Preis | Künstler | Album | Tracks Label |
| ---- | ----- | ----- | ------ | ----- | -------- | ----- | ------------ |
978-013… Effective Java Bloch 412 39,90 € NULL NULL NULL NULL
| 978-013… | Clean Code | Martin | 464  | 34,90 € | NULL       | NULL       | NULL NULL  |
| -------- | ---------- | ------ | ---- | ------- | ---------- | ---------- | ---------- |
| NULL     | NULL       | NULL   | NULL | 12,99 € | Beatles    | Abbey Road | 17 Apple   |
| NULL     | NULL       | NULL   | NULL | 14,99 € | Pink Floyd | The Wall   | 26 Harvest |
| NULL     | NULL       | NULL   | NULL | 11,99 € | Daft Punk  | Discovery  | 14 Virgin  |
Erste NULL-Werte: Attribute, die für manche Entitäten nicht existieren
SQL-Standard: NULL bedeutet „unbekannter Wert“, in diesem Fall aber „nicht definiert“
=>Fundamentale Verletzung

| Schritt 3: Sparse |     | Tabelle |     |     |     |     |     |     |     |     |
| ----------------- | --- | ------- | --- | --- | --- | --- | --- | --- | --- | --- |
Mit jeder weiteren Kategorie wächst die Tabelle in der Breite -jede Zeile nutzt aber nur einen Bruchteil der Spalten.
| Tabelle: PRODUKTE  — | 12 Spalten, jede Zeile füllt nur 2–3 davon |     |     |     |     |     |     |     |     |     |
| -------------------- | ------------------------------------------ | --- | --- | --- | --- | --- | --- | --- | --- | --- |
Energie-
ISBN Autor Seiten Künstler Album Tracks Regisseur FSK Watt Größe Material
klasse
978-013… Bloch 412 NULL NULL NULL NULL NULL NULL NULL NULL NULL
978-013… Martin 464 NULL NULL NULL NULL NULL NULL NULL NULL NULL
NULL NULL NULL Beatles Abbey Road 17 NULL NULL NULL NULL NULL NULL
NULL NULL NULL Pink Floyd The Wall 26 NULL NULL NULL NULL NULL NULL
| NULL | NULL | NULL NULL | NULL | NULL | Nolan | 12   | NULL  | NULL | NULL | NULL |
| ---- | ---- | --------- | ---- | ---- | ----- | ---- | ----- | ---- | ---- | ---- |
| NULL | NULL | NULL NULL | NULL | NULL | NULL  | NULL | 1.200 | A++  | NULL | NULL |
NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL M / Rot Baumwolle
Speicher-Overhead  ·  NULL-Mehrdeutigkeit  ·  Schema-Migration bei jeder neuen Kategorie

Wie löst man das?
Diese Situation ist bekannt und es gibt daher eine Art Standardrezept zur Behebung.
Attribute, die nur für eine Teilmenge der Entitäten gelten,
gehören in eine eigene Tabelle.
1 breite Tabelle 1 Basis + N Subtyp-Tabellen
→
Spezialisierung

Schritt 4: Workaround Subtyp-Tabellen
? Eine ganz alltägliche Anfrage: (Wer ist der Urheber des Produkts)
Welche Produkte sind von „Beatles“?
| Schema |             |       | Notwendige SQL:                          |                   |        |
| ------ | ----------- | ----- | ---------------------------------------- | ----------------- | ------ |
|        | PRODUKTE    |       | SELECT                                   |                   |        |
|        | (id, preis) |       | p.id, p.preis, b.titel, a.titel, v.titel |                   |        |
|        |             |       | FROM produkte                            | p                 |        |
|        |             |       | LEFT JOIN buch  b ON b.produkt_id        |                   | = p.id |
|        |             |       | LEFT JOIN album                          | a ON a.produkt_id | = p.id |
| BUCH   | ALBUM       | VIDEO |                                          |                   |        |
titel, titel, titel, LEFT JOIN video v ON v.produkt_id = p.id
autor, seiten
|     | künstler, label | regisseur, fsk |     |     |     |
| --- | --------------- | -------------- | --- | --- | --- |
WHERE
|     |     |     | b.autor       | ILIKE '%Beatles%' |     |
| --- | --- | --- | ------------- | ----------------- | --- |
|     |     |     | OR a.künstler | ILIKE '%Beatles%' |     |
„Urheber“ heißt pro Typ anders: autor /
|          |             |     | OR v.regisseur | ILIKE '%Beatles%'; |     |
| -------- | ----------- | --- | -------------- | ------------------ | --- |
| künstler | / regisseur |     |                |                    |     |
Pro neuer Kategorie: ein neuer LEFT JOIN  +  ein neues OR  +  ein neuer Spaltenname

Das ist keine Theorie.
Ein sehr ähnliches Problem trat auch bei Amazon auf – von Relationalem
schrittweise zu flexibleren, verteilten Datenmodellen.
| 1995   | 1998    | 1999    | 2000+        | heute           |
| ------ | ------- | ------- | ------------ | --------------- |
| Bücher | + Musik | + Video | + Elektronik | Verteilte noSQL |
|        |         |         | + tausende   | Systeme wie     |
|        |         |         | Kategorien   | DynamoDB        |
Jede Produkterweiterung stellte das Datenmodell vor dieselben Probleme:
Relationales Datenmodell nicht mehr tragbar
Heterogene, evolutionäre Entitäten brauchen ein Datenmodell, das das nativ unterstützt.
→  Document Stores

Schritt zurück: Warum NoSQL?
Wir haben einen Treiber gesehen. NoSQL als Bewegung hatte einen zweiten.
1 2
Flexibilität Skalierung
• Heterogene, sich entwickelnde Entitäten - wie • Web-Plattformen mit Millionen Nutzern
wir gerade gezeigt haben produzieren enorme Datenmengen
• Festes Schema vor dem Speichern vs. • RDBMS skalieren primär vertikal (mehr Zeilen) -
dynamische Datenmodelle in der Realität stärkere Maschine/Festplatte
• Horizontal über viele Server: dafür braucht es
ein anderes Datenmodell (JOINS zu langsam)
Ende 2000er: NoSQL-Bewegung als Antwort auf beide Treiber gleichzeitig

Warum Document Stores im Speziellen?
NoSQL ist eine Familie. Vier große Untertypen, jeder für ein anderes Problem.
★
| Key-Value | Document | Wide-Column | Graph |
| --------- | -------- | ----------- | ----- |
einfache Schlüssel-Wert-Paare schema-flexible tabellenartig mit Beziehungen erster Klasse
|                         | JSON-Dokumente | dynamischen Spalten   |     |
| ----------------------- | -------------- | --------------------- | --- |
| z.B. Redis, Memcached   |                | z.B. Neo4j, Neptune   |     |
| z.B. MongoDB, Couchbase |                | z.B. Cassandra, HBase |     |
Document Store
Speichert Daten als strukturierte, JSON-ähnliche Dokumente - verschachtelbar, schema-flexibel und nah an der
Objektstruktur der Anwendung.
→  Wie das konkret aussieht, behandeln wir im nächsten Kapitel.

Wo werden Document Stores eingesetzt?
Überall, wo Daten viele Felder haben, oft variabel und tief geschachtelt sind.
E-Commerce Content Management
Produkte mit kategorie-spezifischen Eigenschaften -wie unser Artikel, Blog-Posts, Medien-Inhalte mit variablen Feldern: Tags,
Bücher-/Musik-/Video-Beispiel. Amazon (DynamoDB), Otto eingebettete Medien, Kommentar-Bäume.
(MongoDB).
User Profiles KI & ML-Pipelines
Optionale Attribute, die mit der Zeit dazukommen - Trainingsdaten, Features, Modell-Metadaten und Logs -meist
Präferenzen, Verknüpfungen mit Diensten, Verhaltens- semi-strukturiert, oft pro Run/pro Modell unterschiedlich.
Metadaten.

Konzeptionelles Modell

Key-Value als Fundament
Wir brauchen ein flexibles Datenmodell. Bauen wir es auf - vom kleinsten Baustein her.
Das Modell Was das kann, und was nicht
✓ Blitzschnell & horizontal skalierbar
"user:42" → Black Box
Caches, Sessions -Redis, Memcached, DynamoDB
✓ Minimales API
Schlüssel Wert
get(key) und put(key, val) - mehr nicht.
✗ Keine Suche im Wert da Blackbox
„Alle Produkte von Beatles“: unmöglich direkt, nur mit jedem Wert
Der Wert ist für die DB ein undurchsichtiger Block,
laden
sie kann seinen Inhalt nicht interpretieren.
✗ Keine Abfrage nach Feldern
Wert bleibt ein undurchsichtiger Block.
Das reicht für Session-Caches. Nicht für unseren Produktkatalog.

Fortschritt: Dem Wert eine Struktur geben
Was passiert, wenn die DB den Inhalt des Werts interpretieren kann?
dieselbe Box, aber jetzt durchsichtig
{
+ Struktur
"_id": "u_42",
→
"user:42"
"name": "Alice",
"tier": "gold"
}
Gleicher Container -aber die DB sieht jetzt hinein und kann nach Feldern abfragen.
LÖSUNG FÜR DAS PROBLEM AUS KAPITEL 1
Jedes Produkt wird sein eigenes Dokument.
Bücher, Alben, Videos -jedes mit eigenen Feldern, alle in einer Collection. Ohne NULLs. Ohne JOINs.

Was ist ein Dokument?
Eine strukturierte Dateneinheit, die ein ganzes Anwendungsobjekt repräsentiert (Schritt für Schritt aufgebaut/erweiterbar)
{{{{ Bestandteile eines Dokuments
{
""""____iiiidddd"""":::: """"pppp____000000007777"""",,,,
"_id": "p_007"
""""kkkkaaaatttteeeeggggoooorrrriiiieeee"""":::: """"bbbbuuuucccchhhh"""",,,, _id
}
""""ttttiiiitttteeeellll"""":::: """"EEEEffffffffeeeeccccttttiiiivvvveeee JJJJaaaavvvvaaaa"""",,,,
Eindeutiger Identifikator innerhalb der Collection.
""""pppprrrreeeeiiiissss"""":::: 33339999....99990000,,,
}
"""aaauuutttooorrr"""::: {{{ Felder
"""nnnaaammmeee"""::: """JJJooossshhhuuuaaa BBBllloooccchhh""",,,
Name + Wert (String, Number, Boolean, ...).
"""lllaaannnddd"""::: """UUUSSSAAA"""
}}},,
} Verschachtelte Objekte
""ttaaggss"":: [ "[j"ajvaav"a," ," p"aptattetrenrsn"s]"],
Hierarchien wie z.B. autor.name.
}
"lager": [
{ "ort": "Berlin", "anzahl": 12 }, Arrays
{ "ort": "Hamburg", "anzahl": 4 }
Listen primitiver Werte oder ganzer Sub-Objekte.
]
}
Ein Dokument repräsentiert ein ganzes Objekt -kein verteiltes Schema über mehrere Tabellen
„LocalityofReference“: Alles was zusammengehört liegt physisch auf dem Speicher beieinander

Was kann ein Dokument repräsentieren?
Ein Dokument fasst ein vollständiges Anwendungsobjekt -egal aus welcher Domäne.
Produkt · E-Commerce Nutzerprofil · Identity
{ "_id": "p_007", "kategorie": "buch", { "_id": "u_42", "name": "Alice",
"titel": "Effective Java", "preis": 39.90, "email": "alice@test.de", "tier": "gold",
"lager": [{"ort":"Berlin","anzahl":12}] } "praeferenzen": {"sprache":"de"} }
Bestellung · Order Blog-Post · CMS
{ "_id": "b_889", "kunde_id": "u_42", { "_id": "a_215", "titel": "Doc Stores 101",
"items": [{"id":"p_007","stk":1}], "autor": "Alice", "tags": ["nosql","db"],
"summe": 39.90, "status": "versendet" } "kommentare": [{"von":“Peter","text":"…"}] }
Prinzip: 1 Anwendungsobjekt = 1 Dokument -egal ob Produkt, Nutzer, Bestellung oder Artikel
=>Die Datenbankstruktur passt sich der Anwendungslogik an, nicht umgekehrt

Tabelle vs. Collection
? Worin werden die Dokumente dann gespeichert?
Was im relationalen Modell die Tabelle ist, ist im Document Store die Collection -mit einem entscheidenden Unterschied.
Tabelle (relational) Collection (DocumentStore)
Festes Schema, alle Zeilen identisch strukturiert. Schema-flexibel: Dokumente unterschiedlich (z.B. Collection PRODUKTE)
id kategorie titel preis { _id:007, kategorie:"buch", titel:"Effective Java", autor:"Bloch",
isbn:"..." }
007 buch Effective Java 39.90
{ _id:012, kategorie:"album", titel:"Abbey Road",
012 buch Clean Code 34.90 künstler:"Beatles", tracks:17 }
018 buch Java Concur. 29.90 { _id:018, kategorie:"video", titel:"Inception", regisseur:"Nolan",
fsk:12 }
Jede Zeile muss das Schema erfüllen, also Datenbank erzwingt keine einheitliche Struktur,
Constraints auf Datenbankebene leicht neue Produkte/Kategorien einzufügen
ABER: Schema-Flexibilität != Schema-Losigkeit
(Schema Validation möglich)
Genau das löst unser Heterogenitäts-Problem aus Kapitel 1 -ohne NULLs, ohne JOINs.
=>Flexibilität wo sie gebraucht wird, Constraints wo sie sinnvoll sind.

Konzepte übersetzt: Relationale DB Document Store
Die meisten Begriffe haben ein direktes Pendant. Nur die Struktur dahinter ist anders.
RELATIONAL DOCUMENT STORE
Tabelle Behälter für Zeilen → Collection Behälter für Dokumente
Zeile feste Spalten, einheitlich → Dokument eigene Felder pro Eintrag
Spalte ein Datentyp pro Spalte → Feld beliebiger Typ, auch verschachtelt
Primärschlüssel eindeutige Zeilen-ID → _id eindeutige Dokument-ID
JOIN Tabellen über Fremdschlüssel → embedded oder referenziert
Festes Schema alle Zeilen identisch → Schema-flexibel pro Dokument unterschiedlich

Beziehungen modellieren - zwei Wege
Dieselbe Bestellung - zwei verschiedene Dokument-Strukturen
Embedded Referenced
Items leben in eigener Collection, Dokument speichert
Items leben im Bestell-Dokument
nur die Referenz
{ {
"_id": "b_889", "_id": "b_889",
"kunde": "u_42", "kunde": "u_42",
"items": [ "item_ids": [
{ "id": "p_007", "preis": 39.90 }, "p_007",
{ "id": "p_012", "preis": 34.90 } "p_012"
], ],
"summe": 74.80 "summe": 74.80
} }
Ein Read holt die ganze Bestellung. Items werden bei Bedarf nachgeladen (mehrere Reads)
Beide Strategien sind valide. Wann was verwendet werden soll ist eine grundlegende Design-Entscheidung. Gleich dazu mehr.

Datenstruktur

Wie werden Dokumente gespeichert?
Für den Menschen sieht ein Dokument wie JSON aus. Intern gespeichert & verarbeitet wird meist mit BSON
JSON (logisches Modell) BSON (technische Repräsentation)
{ • binäres Format statt Text
"_id": "b_889", • zusätzliche Datentypen, z. B. ObjectId, Date, Binary,
"kunde": "u_42", Decimal128
"items": [ • effizient für Parsing und interne Verarbeitung
{ "id": "p_007", "preis": 39.90 }, • nicht menschenlesbar, sondern für die Datenbank
{ "id": "p_012", "preis": 34.90 }
optimiert
],
"summe": 74.80
}
lesbar, textbasiert, gut für Menschen & APIs

Schema Flexibilität & Validierung
Schema Flexibilität Schema Validierung
Dokumente in derselben Collection dürfen sich unterscheiden Flexibilität heißt nicht Beliebigkeit
{ _id:007, kategorie:"buch", titel:"Effective Java", autor:"Bloch",
{
isbn:"..." }
"$jsonSchema": {
"required": ["title", "price"],
{ _id:012, kategorie:"album", titel:"Abbey Road", "properties": {
künstler:"Beatles", tracks:17 }
"title": { "bsonType": "string" },
"price": { "bsonType": "number" }
{ _id:018, kategorie:"video", titel:"Inception",regisseur:"Nolan", }
fsk:12 }
}
}
Validierungsregeln können Pflichtfelder und Datentypen absichern
Document Stores sind nicht schemafrei, sondern schema-flexibel. Validation liefert Guardrails.

Embedding Beispiel: Website mit Blogposts
{
"_id": "article_1001",
"title": "Why Document Stores Matter",
"slug": "why-document-stores-matter",
"content": "Document stores are useful when...",
"status": "published",
"publishedAt": "2026-04-23T10:00:00Z",
"tags": ["nosql", "document-store", "mongodb"],
"category": {
"name": "Databases", Nested Kategorie-Dokument
"slug": "databases"
},
Artikel-Dokument
"author": {
"_id": "author_42",
"name": "Alice Johnson", Nested Autor-Dokument
"email": "alice@example.com",
"bio": "Tech writer."
},
"comments": [
{
"_id": "comment_9001",
Array von nested Kommentar-
"userName": "Bob",
"text": "Great introduction!", Dokumenten
"createdAt": "2026-04-23T12:15:00Z"
},
...

Embedding Beispiel: Website mit Blogposts
PROS
{
"_id": "article_1001", • Alle Artikelinformationen in einer Query (keine JOIN-
"title": "Why Document Stores Matter",
Operationen)
"slug": "why-document-stores-matter",
"content": "Document stores are useful when...", • Zusammengehörige Daten können in einer atomaren
"status": "published",
Dokument-Operation gelesen und geändert werden
"publishedAt": "2026-04-23T10:00:00Z",
"tags": ["nosql", "document-store", "mongodb"],
"category": {
CONS
"name": "Databases",
"slug": "databases" • Dokumenten Größenlimit (16-MB bei MongoDB)
},
→ Unbounded Arrays besonders problematisch
"author": {
"_id": "author_42", (Bspw. Kommentare)
"name": "Alice Johnson", • Duplikation: Informationen über den Autor werden
"email": "alice@example.com",
"bio": "Tech writer." in jedem Blogpost gespeichert, den er hochlädt
}, → Autorinformationen ändern kann teuer
"comments": [
werden
{
"_id": "comment_9001", → Potential für Inkonsistenzen
"userName": "Bob",
"text": "Great introduction!",
"createdAt": "2026-04-23T12:15:00Z"
},
...

Embedding umdrehen (Access Pattern Driven)
Idee
{
Embedding kann in beide Richtungen erfolgen "_id": "author_42",
"name": "Alice Johnson",
Struktur richtet sich nach häufigsten Zugriffen
"email": "alice@example.com",
"bio": "Tech writer."
"articles": [
Beispiel
{
Oft: „alle Artikel eines Autors anzeigen“ "title": "Why Document Stores Matter",
"slug": "why-document-stores-matter",
→ Autor als Top-Level-Dokument
"content": "Document stores are useful when...",
...
Achtung! },
{
Gefährlich bei vielen Artikeln (Unbounded Array)
"title": "Title2",
"content": "...",
...
}
]
}

Referencing Beispiel: Website mit Blogposts
Artikel-Kollektion
{
"_id": "article_1001",
Autor-Kollektion
"title": "Why Document Stores Matter",
"slug": "why-document-stores-matter",
{ "content": "Document stores are useful when data is semi-
"_id": "author_42", structured and evolves over time...",
"name": "Alice Johnson", "status": "published",
"email": "alice@example.com", "publishedAt": "2026-04-23T10:00:00Z",
"bio": "Tech writer." "tagIds": ["tag_1", "tag_2", "tag_3"],
} "categoryId": "cat_10",
"authorId": "author_42"
}

Referencing Beispiel: Website mit Blogposts
PROS CONS
• Keine Duplikation der Autoreninfo • Collections brauchen JOIN, wenn Autoreninfo
→ Einfache updates, keine Inkonsistenzen benötigt wird
• Kleineres Artikel-Dokument → Langsam
→ Einfachere/schnellere Lesezugriffe, wenn wir • Hinzufügen eines neuen Artikels mit einem neuen
Autoreninfo nicht brauchen Autor benötigt mehrere Schreiboperationen
• gut für häufig wiederverwendete Daten, z. B. • dangling referencesmöglich, wenn referenzierte
Autoren, Kategorien, Tags Dokumente gelöscht werden

Entscheidungskriterien
| Embedding benutzen bei… | Referencing | benutzen bei… |
| ----------------------- | ----------- | ------------- |
| •                       | •           |               |
Daten werden immer zusammen gelesen Daten werden auch unabhängig genutzt
• Beziehung ist one-to-one oder one-to-few • Beziehung ist one-to-many oder many-to-
| • Daten sind klein und begrenzt | many |     |
| ------------------------------- | ---- | --- |
• Daten ändern sich selten unabhängig  • Daten können stark wachsen
| voneinander | • Du willst Redundanz vermeiden |     |
| ----------- | ------------------------------- | --- |
Bei Embedding vs. Referencingimmer „Access Pattern First“: Die Wahl wird aus Lese-und Schreibmustern abgeleitet.

Abfragemodell

[WFoieli efrnatgitte ml]an Dokumente ab? MQL statt SQL
Selbe Idee, andere Form: der Filter wird selbst zu einem Dokument.
| ? Aufgabe: Alle Bücher unter 40 € |     |     |     |
| --------------------------------- | --- | --- | --- |
SQL  (relational) MQL  (MongoDB Query Language)
| SELECT * FROM     | produkte | db.produkte.find({    |      |
| ----------------- | -------- | --------------------- | ---- |
| WHERE kategorie = | 'buch'   | "kategorie" : "buch", |      |
| AND preis <       | 40;      | "preis" : {"$lt":     | 40 } |
})
Das elegante Prinzip dahinter: Filter werden mit derselben JSON-Syntax beschrieben wie die Daten selbst.
Es gibt keine separate Query-Sprache zu lernen - nur JSON-Objekte mit speziellen Operator-Schlüsseln

[CFRoUliDen -tditieel ]vier Grundoperationen
Create, Read, Update, Delete -gleiche Operationen wie SQL, neue Syntax(Sprachenabhängig)
Create neues Dokument einfügen Read Dokumente nach Filter abrufen
| db.produkte.insert_one({      |           | db.produkte.find({               |           |
| ----------------------------- | --------- | -------------------------------- | --------- |
| "kategorie":                  | "buch",   | "kategorie" :                    | "album",  |
| "titel": "Refactoring",       |           | "künstler" :                     | "Beatles" |
| "preis": 42.00                |           | })                               |           |
| })                            |           | // auch findOne, find().limit(N) |           |
| Update                        |           | Delete                           |           |
| Felder ändern (Filter + $set) |           | Dokumente entfernen              |           |
| db.produkte.update_one(       |           | db.produkte.delete_one({         |           |
| {"_id": "p_007" },  // Filter |           | "_id": "p_018"                   |           |
| {"$set": {"preis":            | 35.00 } } | })                               |           |
| )                             |           | // auch deleteMany({...})        |           |

[FFilotleier-n&ti tVeel]rgleichsoperatoren
Mehr als nur Gleichheit -Bedingungen werden als Operator-Objekte ausgedrückt.
| OPERATOREN |          | BEDINGUNGEN KOMBINIEREN                      |
| ---------- | -------- | -------------------------------------------- |
| $eq        | gleich   | Alle Bücher zwischen 20 € und 50 €  -mit AND |
| $ne        | ungleich |                                              |
db.produkte.find({
"kategorie": "buch",
| $gt  $gte | größer  /  ≥ |     |
| --------- | ------------ | --- |
"preis": {
| $lt  $lte | kleiner  /  ≤ | "$gte": 20, "$lte": 50 |
| --------- | ------------- | ---------------------- |
}
| $in | Wert in Menge (Kategorie) |     |
| --- | ------------------------- | --- |
})
| $nin | Wert NICHT in Menge (Kategorie) |     |
| ---- | ------------------------------- | --- |
Mehrere Felder im selben Objekt =implizites AND.
| $and  $or | logisches UND / ODER |     |
| --------- | -------------------- | --- |
Für OR: { $or: [ {...}, {...} ] }

[AFuoflgieanbteit -esl]chreibt die Query
Übung: von der Umgangssprache zur MQL.
AUFGABE
"Gebt mir alle Alben, die NICHT von den Beatles sind und mindestens 15 Tracks haben."
Welche Collection? Welche Felder? Welche Operatoren?
LÖSUNG
db.produkte.find({
"kategorie": "album",
"künstler": {"$ne": "Beatles" },
"tracks": {"$gte": 15 }
})
$ne für „nicht gleich“, $gte für „mindestens“ -beide Bedingungen gelten gleichzeitig.

[DFootl-ieNnottiatetilo] n - Zugriff auf verschachtelte Felder
Innerhalb eines Dokuments kann man mit Punkten zum Zielfeld navigieren.
Dokument Zugriff per Dot-Notation
| {   | 1. Verschachteltes Objekt  -Autor aus USA |     |
| --- | ----------------------------------------- | --- |
"_id": "p_007",
|     | { "autor.land": "USA" | }   |
| --- | --------------------- | --- |
"kategorie": "buch",
"titel": "Effective Java",
| "autor": { | 2. Array von Objekten  -Lager in Berlin |     |
| ---------- | --------------------------------------- | --- |
"name": "Joshua Bloch",
{ "lager.ort": "Berlin" }
"land": "USA"
},
"lager": [
3. Array-Element  -Tag 'java' vorhanden
{"ort": "Berlin" },
| {"ort": "Hamburg" } | { "tags": "java" | }   |
| ------------------- | ---------------- | --- |
]
}
Die DB sieht IN das Dokument hinein -kein JOIN, keine Pfad-Tricks.

[AFuoflgieanbteit -evl]erschachtelt abfragen
Jetzt die Dot-Notation anwenden.
AUFGABE
"Findet alle Bestellungen von Kunde u_42, bei denen mindestens ein Item mehr als 50 € kostet."
Denkt an die Embedded-Variante: itemsist ein Array von Objekten
LÖSUNG
db.bestellungen.find({
"kunde": "u_42",
"items.preis": {"$gt": 50 }
})
"items.preis" prüft automatisch jedes Element des Arrays -reicht, wenn EINES die Bedingung erfüllt.

[AFgoglireengtaittieol]n Pipeline - wenn find() nicht reicht
Find() ist ideal für einfach Filter-Abfragen. Aber für komplexe Analysen (Gruppierungen, Summen, Durchschnitte, …)
braucht man etwas komplexeres: Aggregation Pipelines
Grundprinzip
Dokumente fließen durch geordnete Kette von Stages. Jede Kette: nimmt Ausgabe von vorherigem,
transformiert, reicht das Ergebnis weiter
| $match  |     | $group     |     | $sort     |     | $limit    |
| ------- | --- | ---------- | --- | --------- | --- | --------- |
|         | →   |            | →   |           | →   |           |
| FILTERN |     | GRUPPIEREN |     | SORTIEREN |     | BEGRENZEN |
nach Autor, dann
| nur Bücher |     |     |     | Umsatz absteigend |     | Top 5 |
| ---------- | --- | --- | --- | ----------------- | --- | ----- |
Aggregatfunktionen möglich
BEISPIEL  - Top 5 Autoren nach Gesamtumsatz
db.produkte.aggregate([
{"$match": {"kategorie": "buch" } },
{"$group": {"_id": "$autor.name", "umsatz": {"$sum": "$preis" } } },
{"$sort": {"umsatz": -1 } },
{"$limit": 5 }
])

[VFoollliteenxttistuecl]he - Text-Indizes & Atlas Search
Wie findet man Inhalte in Textspalten, schnell, treffsicher und mit Relevanz-Ranking?
| SQL  LIKE                   |     | Text-Index |     | Atlas Search  |
| --------------------------- | --- | ---------- | --- | ------------- |
| naiv, langsam, kein Ranking |     | MQL $text  |     | Apache Lucene |
• Zeichenweiser Substring-Match: findet „java“ auch  • Wortbasiert: „java programming“ findet Dokumente  • Fuzzy-Matching: „Effektiv Java“ (Tippfehler) findet
mitten im Wort mit beiden Begriffen -Reihenfolge egal trotzdem „Effective Java“
• Kein Ranking: Alle Treffer gleichwertig -kein Score • Stoppwörter ignoriert: „the“, „und“, „der“ werden  • Synonyme: Suche nach „Automobil“ findet auch
|     | automatisch herausgefiltert |     | Ergebnisse für „Auto“ |     |
| --- | --------------------------- | --- | --------------------- | --- |
• Kein Scoring: „Effective Java“ = Kommentar mit „java“ - • Term-Frequency-Scoring: Häufigere Treffer = höherer
gleiche Relevanz Score
db.produkte.aggregate([
• Full-Table-Scan: % am Anfang verhindert jeden Index -
{"$search": {
sehr langsam bei Millionen Zeilen
|     | db.produkte.find({   |          | "text": {"query": "java", "fuzzy": {}  |     |
| --- | -------------------- | -------- | -------------------------------------- | --- |
|     | "$text": {"$search": | "java" } | }                                      |     |
WHERE titel LIKE '%java%'
|     | })  |     | } } |     |
| --- | --- | --- | --- | --- |
])
Somit gibt es also die Möglichkeit „von Pattern-Match zur semantischen Suche“, ohne die DB zu wechseln.

Architekturüberblick

Wie skaliert ein Document Store?
| Single Node | Replica Set |     | Sharded | Cluster |     |
| ----------- | ----------- | --- | ------- | ------- | --- |
• einfach zu betreiben • Mehrere Kopien derselben Daten • Verteilt Daten über mehrere
• •
ein einzelner Knoten automatisches Failover Maschinen (Shards)
• Router leitet Queriesweiter
|     | Primary |     |     | Router |     |
| --- | ------- | --- | --- | ------ | --- |
DB
|     | Secondary | Secondary | Shard 1 | Shard 2 | Shard 3 |
| --- | --------- | --------- | ------- | ------- | ------- |
Single Point of Failure Ausfallsicherheit Datenmenge & Durchsatz

Query Routing: targeted vs. scatter-gather
Ob eine Anfrage billig oder teuer ist, hängt oft davon ab, ob sie den Shard Key enthält.
|       | Targeted    | Query |       | Scatter-Gather Query |                 |       |
| ----- | ----------- | ----- | ----- | -------------------- | --------------- | ----- |
|       | Query       |       |       |                      | Query           |       |
|       | user_id=123 |       |       |                      | status='active' |       |
|       | Router      |       |       |                      | Router          |       |
| Shard | Shard       |       | Shard | Shard                | Shard           | Shard |
Nur relevanter Shard
Alle Shardsmüssen antworten

Shard Keys
Der Shard Key entscheidet:
• wo ein Dokument gespeichert wird
• wie gleichmäßig Last verteilt wird
•
ob Queries gezielt geroutet werden können
Beispiel Shard Key: Alter der Autoren
|             | Shard1     | Shard2      | Shard3      | Shard4    |
| ----------- | ---------- | ----------- | ----------- | --------- |
|             | Alter 0-24 | Alter 25-49 | Alter 50-74 | Alter 75+ |
| Datenanzahl | mittel     | sehr voll   | mittel      | sehr leer |
Lastverteilung
Hängt von den Queriesab. Shard 2 wird aber vermutlich Hotspot.
Sinnvoll? Nein. Typische Blogposts Queriesfiltern nicht nach Autoren-Alter.

Shard Keys
Der Shard Key entscheidet:
• wo ein Dokument gespeichert wird
• wie gleichmäßig Last verteilt wird
• ob Queries gezielt geroutet werden können
Guter Shard Key Schlechter Shard Key
• hohe Kardinalität • wenige Werte, z. B. status
• gleichmäßige Verteilung • monotone Werte, z. B. createdAt
• häufigen in Queriesenthalten • selten gefilterte Felder
• vermeidet Hotspots • führt zu Hotspots oder Broadcast-Abfragen
Bsp.: hash(authorId)
Der Shard Key entscheidet, wie gut Datenverteilung und Query-Performance später skalieren

Indizes: Performance vs. Schreibaufwand
Indizes beschleunigen Reads, kosten aber Speicher, RAM und Schreibaufwand
Was bringt ein Index? Nachteile Document Store
Besonderheiten
• Dokumente schnell finden, ohne die • MehrSpeicher-&Ram-Verbrauch
gesamte Collection zu durchsuchen • JedesInsert&Updatemuss • NestedFelder & Arrays können
• SpeichertFeldwert→Verweisauf Indexstrukturaktualisieren auch indiziert werden!
Dokument
• KönnenIndexe„aufblasen“:
→Schnelle Reads →Langsamere Writes
tags: ["db", "nosql", "cloud"]
Arrays →viele Index-Einträge

CAP-Theorem-Einordnung
Partition Tolerance ist bei verteilten Systemen nicht optional
Consistency
Einordnung für Document Stores
CA CP • Document Stores sind verteilbar und daher auf Partition
Tolerance ausgelegt
Partition • Trade-off: Konsistenz vs. Verfügbarkeit
Availability
Tolerance • Konfigurierbar (Read- & Write-Concern, Replikation)
AP
CAP
1. Consistency
alle Clients sehen denselben aktuellen Stand
2. Availability
jede Anfrage erhält eine erfolgreiche Antwort
3. Partition Tolerance
System funktioniert trotz Netzwerkfehlern weiter

Atomarität auf Dokumentenebene
Ein Dokument / Embedded Mehrere Dokumente / Referenced
Items leben in eigener Collection, Dokument speichert
Items leben im Bestell-Dokument
nur die Referenz
| {                                  | {                |     |
| ---------------------------------- | ---------------- | --- |
| "_id": "b_889",                    | "_id": "b_889",  |     |
| "kunde": "u_42",                   | "kunde": "u_42", |     |
| "items": [                         | "item_ids": [    |     |
| { "id": "p_007", "preis": 39.90 }, | "p_007",         |     |
| { "id": "p_012", "preis": 34.90 }  | "p_012"          |     |
| ],                                 | ],               |     |
Atomar
| "summe": 74.80 | "summe": 74.80 | Kann inkonsistent werden |
| -------------- | -------------- | ------------------------ |
| }              | }              |                          |
Bestellung kann atomar verändert werden Keine automatische Atomarität
Dokumentgrenze ist wichtige Designentscheidung!

Open-Source- & Cloud-Alternativen
MongoDB FerretDB AppacheCouchDB
• Marktführer • Open-Source-Alternative • Apache Open Source
• Community Server(selfhosted)/ Atlas • PostgreSQL als Backend • HTTP/REST API
(managed) • Unterstützt MongoDB-ähnliche Treiber, • stark bei Replikation
• großesÖkosystem Tools und Query-Syntax • offline-/sync-freundlich
• SSPL(keine echte Open-Source-Lizenz)
Couchbase Cloud Angebote
• Distributed Document DB • MongoDB Atlas
• Community & Enterprise • Amazon DocumentDB
• Search / Analytics / Edge • Cloud Firestore
• Plattform-Ansatz

Vergleich mit relationalen Datenbanken

Kurzvergleich: SQL vs. Document Store
RELATIONAL DOCUMENT STORE
Tabellen, Zeilen, Spalten → Collections, Dokumente, Felder
Flache Struktur über mehrere Tabellen → JSON-/BSON-Dokumente mit Hierarchien
Festes Schema → Schema-flexibel mit optionaler Validierung
Normalisierung & JOINs → Embedded oder referenziert
Stark bei mehrtabelligenACID-Transaktionen → Atomar vor allem auf Dokumentenebene
Klassisch eher vertikal skaliert → Horizontales Skalieren über Sharding

Wann SQL, wann Document Store?
SQL wählen, wenn … Document Store wählen, wenn …
• Datenmodell stabil und stark strukturiert ist • Daten semi-strukturiert oder variabel sind
• Integrität, Constraints und Transaktionen • Objekte natürlich hierarchisch aufgebaut sind
zentral sind
• Daten häufig als Ganzes gelesen/geschrieben
• Beziehungen häufig über viele Entitäten werden
laufen
• Schema sich schnell weiterentwickelt
• viele flexible Ad-hoc-Analysen gebraucht
• horizontale Skalierung und hohe Schreib-/
werden
Leselastwichtig werden
• Daten oft aus mehreren Tabellen kombiniert
werden müssen

Access Pattern first
Wie sehen die Daten aus? Wie werden Daten gelesen? Wie werden Daten geändert?
Stabil und Tabellarisch viele Kombinationen über Entitäten  mehrere Entitäten müssen
| →SQL | →SQL | gemeinsam konsistent sein |
| ---- | ---- | ------------------------- |
→SQL
Variabel & Hierarchisch ganze Objekte auf einmal Änderungen bleiben meist
| →DocumentStore | →DocumentStore | innerhalb eines Dokuments |
| -------------- | -------------- | ------------------------- |
→DocumentStore

Typische Beispiele
RELATIONAL DOCUMENT STORE
Banking / Zahlungen starke ACID-Transaktionen, Konsistenz Produktkatalog heterogene Attribute je Kategorie
Buchhaltung / ERP klare Entitäten, Constraints, Integrität Webseiten Seiten, Content-Blöcke, Medien, Tags
Reporting / Controlling viele JOINS User Profile viele optionale (und wachsende) Felder
Support Tickets Kommentare, Anhänge, Status, Metadaten
→ Klassische Unternehmenssysteme → Flexible, objektzentrierte Anwendungen

Kurze Pause
Bis in
10 Minuten!

Praktische Demo

Decathlon Produktkatalog Digitalisierung

Challenge

Challenge
GOOD LUCK

Kahoot Quiz

Diskussion

Diskussion
Mögliche Orientierungsfragen/Diskussionsideen:
| Wie intuitiv | war MQL für euch | im Vergleich | zu SQL? |
| ------------ | ---------------- | ------------ | ------- |
?
| Was hat euch | am Datenmodell | überrascht? |     |
| ------------ | -------------- | ----------- | --- |
Wie seht ihr Schema-Flexibilität: hilfreiches Feature oder Gefahr?