#  Data Structure

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
