# Lokaler RDF-Fallback – Erklärung zum Gegenchecken

**Stand:** 17.06.2026 · **Engine:** `rdflib` (reines Python) · **Datei:** `dfb_wikidata_auszug.ttl`

---

## ⚠️ Wichtigster Befund zuerst: Die Q-IDs im Original-Notebook waren falsch

Geprüft gegen die kanonische **Wikidata REST-API** (`wbgetentities`, unabhängig vom ausgefallenen WDQS) **und** den QLever-Mirror. Fast alle IDs zeigten auf völlig fremde Objekte. Sie wurden im Notebook, in der Musterlösung **und** im lokalen Graphen korrigiert:

| Konzept | alt (falsch) | zeigte real auf | **neu (korrekt)** |
|---|---|---|---|
| FC Bayern München | `Q43310` | dt. Nationalmannschaft | **`Q15789`** |
| Deutsche Nationalmannschaft | `Q43479` | *Bouranton* (frz. Gemeinde) | **`Q43310`** |
| WM 2022 | `Q2249631` | *Sadık Yemni* (Person) | **`Q284163`** |
| WM 2018 | `Q2013870` | *Octavio Cisneros* (Person) | **`Q170645`** |
| WM 2026 | `Q2983968` | *St-Junien* (Kirche) | **`Q5020214`** |
| Frankreich | `Q83310` | *Hausmaus* | **`Q47774`** |
| Brasilien | `Q131490` | *Nothronychus* (Dino) | **`Q83459`** |
| WM 2014 | `Q79859` | ✓ korrekt | `Q79859` |
| Deutschland | `Q183` | ✓ korrekt | `Q183` |

**Folge:** Die alten Queries hätten *auch ohne 429* nie funktioniert (Aufgabe 2–7 → immer 0 Ergebnisse, weil `Q43479` = eine Gemeinde ist). Mit den korrigierten IDs laufen sie jetzt sowohl live (wo Daten existieren) als auch lokal.

---

## Wie der Fallback funktioniert

`run_query()` in der Setup-Zelle:

1. **Live zuerst:** Anfrage an `https://query.wikidata.org/sparql` mit Retry/Backoff bei `429` (20s → 40s → 80s).
2. **Fallback:** Bei 429-Erschöpfung, Timeout oder fehlendem Internet → automatisch derselbe Query gegen den lokalen `rdflib`-Graphen. Hinweis: *„⚠️ Wikidata aktuell nicht erreichbar – Ergebnis aus lokalem Datenauszug (Stand: 17.06.2026)."*
3. **`SERVICE wikibase:label`-Kompatibilität:** Der Block wird vor der lokalen Auswertung entfernt und durch `OPTIONAL { ?x rdfs:label ?xLabel . FILTER(LANGMATCHES(LANG(?xLabel),"de")) }` ersetzt — für jede `?xLabel`-Variable, deren `?x` tatsächlich vorkommt. Studierende ändern ihre Query **nicht**.
4. **Echte Auswertung:** Im Fallback wird die Query **wirklich** gegen den Graphen ausgeführt — falsche Studierenden-Queries liefern auch lokal leere/falsche Ergebnisse.

**Schalter `USE_LOCAL_ONLY`** (oben in der Setup-Zelle): `True` überspringt den Live-Teil komplett → garantiert konsistente Ergebnisse in der Vorlesung, falls WDQS instabil ist. Empfehlung: für die Live-Demo auf `True` stellen.

Der TTL-Datensatz ist **direkt in die Setup-Zelle eingebettet** (`TTL_DATA`). Das Notebook funktioniert damit komplett offline; die externe `.ttl`-Datei wird nicht benötigt (liegt nur als separates Deliverable bei).

---

## Was im lokalen Graphen steht

- **699 Tripel**, 65 Spieler, deutsche Labels (`@de`).
- **Quelle:** Wikidata REST-API (`wbgetentities`), echte Q-IDs, Geburtsdaten (`P569`) und Vereine (`P54` → `P17` Land) direkt aus Wikidata übernommen.
- **Kader (Teilnahme `P1344`):** DE 2022 (25), DE 2018 (22), Frankreich 2022 (14), Brasilien 2022 (14).
- **Vereine:** je Spieler bis zu 3 echte Profivereine mit Land (DE/EN→UK/ES/FR/IT/NL/AT/…). Reserve-/Jugend-/Nationalteams als „Verein" wurden herausgefiltert.
- **WM 2014** (`Q79859`) nur bei Neuer & Müller (für Bonus 2 „2014 ∧ 2018 ∧ 2022").
- **WM 2026** (`Q5020214`): nur die drei Nationalmannschaften als Teilnehmer + Trainer der DFB-Elf (Nagelsmann, `P286`) → bewusst dünn (Teil von Bonus 1).
- **FC Bayern** (`Q15789`) mit `P17` → Deutschland (für Aufgabe 1).
- Nationalmannschaften haben bewusst **kein** `P17`, damit Aufgabe 6 nur echte Vereine (nicht die Nationalelf) als „Verein" zeigt.

---

## Validierung (lokaler Modus) — alle Aufgaben getestet

| Aufgabe | Ergebnis | erwartet |
|---|---|---|
| 1 FC Bayern → Land | Deutschland (`Q183`) | ✓ |
| 2 WM-Kader 2022 | 25 Spieler | ~15–20 ✓ |
| 3 Alter, sortiert | Neuer 36, Müller 33 oben; Moukoko unten | ✓ |
| 4 DE/FR/BR Kadergröße | 25 / 14 / 14 | 15–26 ✓ |
| 5 WM-2018-Erfahrung | ✓-Markierung bei 2018-Spielern | ✓ |
| 6 Spieler→Verein→Land | 66 Zeilen, Länder DE/ES/FR/UK/IT/… | ✓ |
| 7 Ø-Alter 2018 vs 2022 | 27.2 / 27.1 | ~26–28 ✓ |
| Bonus 1 WM 2026 | 3 Teams, 0 dt. Spieler | dünn ✓ |
| Bonus 2 2014∧2018∧2022 | Neuer, Müller | ✓ |

---

## Punkte zum Gegenchecken / kleine Abweichungen

- **England → „Vereinigtes Königreich":** Englische Vereine tragen in Wikidata teils `P17` = UK (`Q145`), nicht England (`Q21`). Aufgabe 6 zeigt daher „Vereinigtes Königreich". Aufgabentext sagt „Länder *wie* …", passt also weiterhin.
- **Moukoko = 18, nicht 17:** `YEAR(2022) − YEAR(2004) = 18` (geboren 20.11.2004, WM-Start 20.11.2022). Er bleibt der Jüngste; nur die Zahl im „Erwartetes Ergebnis"-Text (17) ist eine Schätzung.
- **Live-Wikidata ist dünn:** Selbst mit korrekten IDs liefert WDQS für `P1344` nur sehr wenige Kader-Spieler (Wikidata ist unvollständig). Der lokale Auszug ist daher die **verlässlichere** Datenquelle für die Lehre → in der Vorlesung `USE_LOCAL_ONLY = True` empfohlen.

---

## Geänderte Dateien

- `dfb_wikidata_auszug.ttl` — lokaler Datensatz (Deliverable; im Notebook zusätzlich eingebettet)
- `DFB_Data_Lab_(1).ipynb` — Studierenden-Notebook: neue `run_query()`, korrigierte IDs, angepasstes Intro. Didaktik/Aufgaben/Hinweise/Cheat-Sheet-Struktur unverändert.
- `DFB_Data_Lab_Musterloesung (1).ipynb` — Musterlösung: gleiche `run_query()`, korrigierte IDs.
