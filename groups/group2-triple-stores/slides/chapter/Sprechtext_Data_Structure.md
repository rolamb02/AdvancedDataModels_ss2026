# Sprechtext – Kapitel: Data Structure

**Abgrenzung vorab:** Conceptual Model hat erklärt, *was* ein Triple ist.
Data Structure erklärt, *wie* Triples gespeichert werden — und warum diese Speicherform flexibler und performanter ist als Tabellen.

"Data structure (15 min) – Show how data are stored physically and logically. Discuss schema flexibility or constraints."

---

## Folie 1: Triple-basierte Speicherung – Weg von der Tabelle

### Kernpunkte

- **Das SQL-Problem:** Eine Tabelle `Universitäten` hat Spalten für Name, Stadt, Rektor, Gründungsjahr — ob ich die Daten habe oder nicht, die Spalte existiert. Fehlende Werte → NULL, NULL, NULL
- **RDF-Lösung:** Wissen wird in einzelne Fakten zerlegt: `Subjekt – Prädikat – Objekt`
  - Nur existierende Fakten werden als Triple gespeichert
  - Kein Gründungsdatum? → kein Triple. Kein Platz verschwendet, keine NULL
- **Beispiel (roter Faden):**
  - `uni:Stuttgart` → `uni:hasName` → `"Universität Stuttgart"`
  - `uni:Stuttgart` → `uni:locatedIn` → `dbr:Stuttgart`
  - Will ich später das Gründungsjahr hinzufügen? Einfach ein weiteres Triple anhängen — nichts bricht
- **Beziehungen direkt:** n:m-Verbindungen, die SQL über Join-Tabellen löst, entstehen hier natürlich durch gemeinsame URIs in Triples

**Chain of Thought:**
> SQL muss die Welt vorab in Rechtecke pressen → Fehlstellen → NULLs → Schmerz.
> RDF speichert nur, was tatsächlich gilt → kein Schmerz, kein Platzverschwendung.

---

## Folie 2: Schema-Flexibilität – Dynamisches Wachstum

### Kernpunkte

- **SQL: ALTER TABLE** — jedes neue Attribut erfordert eine Schema-Änderung. Das kann laufende Anwendungen unterbrechen, erfordert Migrations-Skripte, Review, Downtime
- **RDF: einfach ein neues Triple anhängen**
  - Ein AI-Agent findet heraus, dass Prof. Müller an Quantencomputing forscht?
  - `uni:ProfMueller` → `uni:forschtAn` → `uni:Quantencomputing` — fertig
  - Niemand musste vorher wissen, dass dieses Attribut relevant wird
- **Besonders relevant für AI-Pipelines (RAG):**
  - Heterogene, sich ständig ändernde Quellen — RDF bricht nicht, wenn neue Datentypen auftauchen
  - Neues Konzept einfach als neue Klasse definieren und sofort verlinken
- **Trade-off fair benennen:** Weniger Schema-Kontrolle kann auch heißen: weniger Daten-Konsistenzgarantien. RDF ist "Schema-light", nicht "Schema-frei"

---

## Folie 3: Physische Speicherung I – Triple Table und Dictionary-Encoding

### Kernpunkte

- **Logisch** sehen wir Subject–Predicate–Object als URIs und Strings
- **Physisch** liegen 3 Integer-IDs pro Triple vor — keine langen URI-Strings im Datenbankkern
- **Dictionary-Encoding:**
  - Separate Struktur mappt `ID → URI oder Literal`
  - Beispiel: `101 → dbr:Stuttgart`, `502 → dbo:location`, `601 → dbr:UniStuttgart`
  - Das physische Triple ist dann nur noch `(601, 502, 101)`
- **Warum das wichtig ist:**
  - Integer-Vergleiche sind drastisch schneller als String-Vergleiche
  - Eine URI wie `http://dbpedia.org/resource/Stuttgart` taucht in tausenden Triples auf — wird aber nur *einmal* im Dictionary gespeichert
- **Trade-off:** Zusätzlicher Dictionary-Lookup bei jedem Lese-/Schreibvorgang — dafür deutlich bessere Query-Performance bei großen Graphen

**Chain of Thought:**
> Triple Store = nicht einfach "Text in einer Tabelle speichern". Die ID-Indirektion ist der Kern der Effizienz.

---

## Folie 4: Physische Speicherung II – Index-Permutationen

### Kernpunkte

- **Problem:** Ein SPARQL-Pattern kann von drei Seiten kommen:
  - Bekanntes Subject: `dbr:UniStuttgart ?p ?o` → brauche SPO-Index
  - Bekanntes Predicate + Object: `?s dbo:location dbr:Stuttgart` → brauche POS oder OPS
  - Bekanntes Object: `?s ?p dbr:Stuttgart` → brauche OSP
- **Lösung: mehrere Index-Permutationen** (typisch: SPO, SOP, PSO, POS, OSP, OPS)
  - Jede Permutation ist eine B-Tree-sortierte Kopie der Triple Table in anderer Reihenfolge
  - Passende Permutation → direkter Einstieg ohne Full-Scan
- **Trade-off klar benennen:**
  - Mehr Indizes → mehr Speicherbedarf (bis zu 6x)
  - Dafür: stabile Antwortzeiten für alle Query-Formen — unabhängig davon, welche Position die Variable hat

**Chain of Thought:**
> Ohne passendes Index würde jede SPARQL-Query alle Millionen Triples sequentiell prüfen.
> Mit passendem Index: direkter Einstieg → das ist der Unterschied zwischen Sekunden und Millisekunden.

---

## Folie 5: Datenintegration über URIs – Die globale Identität

### Kernpunkte

- **Problem der Ambiguität:** "Stuttgart" als String bedeutet Stadt, Nachname, Ortsname in einem Text — der Computer weiß es nicht
- **URI löst das:** `http://dbpedia.org/resource/Stuttgart` ist weltweit eindeutig. Keine zwei Dinge teilen diese URI
- **Ressourcen spielen mehrere Rollen:** Dieselbe URI kann in einem Triple Object und in einem anderen Subject sein
  - `dbr:UniStuttgart → locatedIn → dbr:Stuttgart`
  - `dbr:Stuttgart → locatedIn → dbr:Baden-Württemberg`
  - Damit gilt automatisch: Stuttgart liegt in BW — ohne weiteres Triple
- **Datenintegration über Quellgrenzen hinweg:**
  - Meine lokale DB: `uni:Stuttgart → kooperiertMit → dbr:Stuttgart`
  - DBpedia: `dbr:Stuttgart → Einwohner → 600.000`
  - Beide Quellen teilen dieselbe URI → automatische Verknüpfung, kein ETL nötig
- **Das ist der Kern von Linked Data:** Wer dieselbe URI verwendet, spricht über dieselbe Sache

**Chain of Thought:**
> URIs sind wie international standardisierte Produktcodes (EAN/GTIN). Wer denselben Code nutzt, meint dasselbe — egal aus welcher Datenbank.

---

## Folie 6: Zusammenfassung – Von isolierten Fakten zur globalen Struktur

### Kernpunkte

- **Drei Ebenen zusammen:**
  1. **Atomisierung:** Fakten in Triples zerlegen — einfach, stabil, NULL-frei
  2. **Identifizierung:** Globale URIs — eindeutig, verlinkbar, quellenübergreifend
  3. **Flexibilität:** Schema-light — Wissen wächst organisch, kein ALTER TABLE
- **Ergebnis:** Eine Struktur, die sowohl *lokal* (Dictionary-Encoding, Indizes) effizient arbeitet als auch *global* (URI-Linking, Federation) vernetzt werden kann
- **Überleitung:** Diese Struktur müssen wir jetzt abfragen können — dafür gibt es SPARQL

---

## Kapitel-Takeaway

> Data Structure ist nicht nur "Triples statt Tabellen".
> Es ist eine durchdachte Kombination aus atomarer Speicherung, ID-Indirektion, Mehrfach-Indexierung und globalem Identitätssystem — die genau dann gewinnt, wenn Daten vernetzt, heterogen und sich verändernd sind.
