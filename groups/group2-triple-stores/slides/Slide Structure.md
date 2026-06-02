
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

## Sektion: Query Model – Folienstruktur (kompakt)

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


Fragen: wir machen ja ne live demo später mit Oxigraph, aber wenn ich das ganze mti einer beliebig anderen software mache wie bspw. Apache Jena TDB with Fuseki server, sieht das immer gleich aus, auch mit dem SERVICE und so? nach w3c ist das ja immer gleich, weil sparql ja diesem standart folgt. gibt es dann überhaupt unterschiede in der abfrage? 
Was ist jetzt genau der unterschied zwsichen rdf und sparql? 
