# Aufgabe: Lokalen RDF-Fallback für ein SPARQL/Wikidata-Lehr-Notebook bauen

## Kontext

Ich habe ein interaktives Jupyter-Notebook für eine Universitätsvorlesung über RDF und SPARQL erstellt. Studierende lösen darin 8 Aufgaben (plus 2 Bonusaufgaben) zum Thema Fußball-WM, indem sie SPARQL-Queries gegen den öffentlichen Wikidata Query Service (WDQS) schreiben und ausführen. Die Anbindung läuft über Python mit `SPARQLWrapper` gegen `https://query.wikidata.org/sparql`.

Ich hänge zwei Dateien an:
1. **Das Studierenden-Notebook** (Aufgaben mit Gerüsten, aufklappbaren Hinweisen, Cheat Sheet)
2. **Die Musterlösung** (alle 8+2 Queries fertig gelöst, inkl. Retry-Logik mit Exponential Backoff)

## Das Problem

Seit einigen Tagen ist WDQS unzuverlässig erreichbar. Es kommt zu `HTTP Error 429: Aggressively rate-limiting to 1 req / min - this rule was created during active wdqs outage`. Das tritt **inkonsistent** auf – mal funktioniert ein einfacher Verbindungstest, mal scheitert bereits Aufgabe 1 (eine einzelne Property-Abfrage mit Label). Ein Retry-Mechanismus mit Backoff (20s/40s/80s/160s) wurde bereits eingebaut, hat das Problem aber nicht zuverlässig gelöst – auch nach mehreren Minuten Warten schlägt die Anfrage teils weiterhin fehl.

## Bereits ausprobierte und verworfene Lösungsansätze (bitte nicht wiederholen)

- **QLever als alternativer SPARQL-Endpoint**: getestet auf qlever.dev/wikidata, funktioniert nicht zuverlässig mit den vorhandenen Queries (vermutlich andere Datenaktualität/-struktur)
- **DBpedia als alternative Datenquelle**: Stichprobe zeigt unstrukturierte, aus Wikipedia-Infoboxen extrahierte Daten (z.B. Torschützenlisten als Wikitext-Markup statt klare RDF-Tripel) – nicht geeignet für sauberes Tripel-basiertes Lernen
- **`SERVICE wikibase:label` durch natives `rdfs:label` + `FILTER(LANG(...))` ersetzen**: Hypothese war, dass speziell der Wikidata-Label-Service besonders stark gedrosselt wird. Wurde in einer kompletten zweiten Musterlösungs-Version umgesetzt und getestet – **hat das Problem nicht gelöst**. Es scheitert weiterhin inkonsistent, auch ohne den Label-Service. Das deutet darauf hin, dass es sich um eine generelle WDQS-Überlastung handelt, nicht um ein spezifisches Problem des Label-Mechanismus.
- **CSV-Cache als Fallback** (vorab Ergebnisse speichern, bei Fehler aus Datei laden): bewusst verworfen, weil dabei **jede Query dasselbe vorab gespeicherte Ergebnis liefern würde – unabhängig davon, ob die Studierenden-Query korrekt, fehlerhaft, oder auf einem anderen (auch validen) Weg gelöst ist.** Das würde falsche Erfolgserlebnisse erzeugen und echte Fehler verschleiern. Diese Anforderung ist zentral: jede Lösung muss die **individuelle Studierenden-Query tatsächlich auswerten**, nicht nur irgendein plausibles Ergebnis zurückgeben.

## Die gewünschte Lösung

Baue einen **lokalen RDF-Graphen als Fallback-Datenquelle**, der dann verwendet wird, wenn die Live-Anfrage an Wikidata fehlschlägt (HTTP 429 oder Timeout, auch nach Retry-Versuchen). Konkret:

1. **Lokaler RDF-Datensatz (Turtle-Format)**: Stelle alle Daten zusammen, die für die 8 Aufgaben + 2 Bonusaufgaben nötig sind. Das umfasst (siehe Musterlösung für die exakten Properties/IDs):
   - Deutscher WM-Kader 2022 und 2018 (Spieler als `wd:Q5`-Instanzen, mit `wdt:P54` Vereinszugehörigkeit zur Nationalmannschaft `wd:Q43479`, `wdt:P1344` Turnierteilnahme, `wdt:P569` Geburtsdatum)
   - Frankreich- (`wd:Q83310`) und Brasilien-Kader (`wd:Q131490`) für WM 2022 (für den Vergleichs-Query)
   - Vereinszugehörigkeit der deutschen Spieler (`wdt:P54` zu ihrem Verein) und Land des jeweiligen Vereins (`wdt:P17`)
   - FC Bayern München (`wd:Q43310`) mit Land-Property für die Einstiegsaufgabe
   - Turniere: WM 2018 (`wd:Q2013870`), WM 2022 (`wd:Q2249631`), WM 2026 (`wd:Q2983968`, bewusst nur sehr wenige/keine Daten, das ist Teil der Bonusaufgabe)
   - Alle relevanten deutschen Labels (`rdfs:label` mit `@de`-Sprachtag) für Spieler, Vereine, Länder, Turniere, Teams
   - Verwende echte, korrekte Wikidata-Q-IDs und P-IDs (wie im Notebook bereits verwendet), damit die Struktur identisch zur echten Wikidata bleibt

2. **Engine**: Nutze `rdflib` (reines Python, keine Server-/Docker-Abhängigkeit, läuft in Standard-Colab-Umgebung ohne Zusatzinstallation außer `pip install rdflib`).

3. **`SERVICE wikibase:label`-Kompatibilität**: Die bestehenden Queries (sowohl im Aufgaben- als auch im Lösungs-Notebook) verwenden durchgängig:
   ```sparql
   SERVICE wikibase:label {
     bd:serviceParam wikibase:language "de,en" .
   }
   ```
   `rdflib` unterstützt dieses Wikidata-spezifische Konstrukt nicht nativ. Baue eine **Vorverarbeitung**, die diesen Block aus der Query-Zeichenkette erkennt und entfernt/transformiert, bevor die Query an `rdflib` übergeben wird – UND die dafür sorgt, dass die erwarteten `?xLabel`-Variablen (Wikidata-Konvention: `?item` → automatisch `?itemLabel`) trotzdem mit den korrekten deutschen Labels aus dem lokalen Graphen befüllt werden. Die Studierenden sollen ihre Query **nicht ändern müssen** – die Transformation muss transparent im Hintergrund passieren.

4. **Erweiterte `run_query()`-Funktion**:
   - Versucht zuerst die Live-Anfrage gegen `https://query.wikidata.org/sparql` (mit bestehender Retry-Logik)
   - Bei endgültigem Fehlschlag (nach allen Retry-Versuchen): automatischer, transparenter Wechsel auf den lokalen `rdflib`-Graphen mit derselben Query (nach Label-Service-Transformation)
   - Gibt bei Fallback-Nutzung einen klaren, freundlichen Hinweis aus, z.B.: `"⚠️ Wikidata aktuell nicht erreichbar – Ergebnis aus lokalem Datenauszug (Stand: [Datum einsetzen])"`
   - **Kritisch wichtig**: Die Query wird im Fallback-Fall **tatsächlich gegen den lokalen Graphen ausgewertet** (nicht nur eine vorgefertigte Antwort zurückgegeben). Eine fehlerhafte Studierenden-Query muss auch im Fallback-Modus zu einem leeren/falschen Ergebnis führen; eine korrekte, aber anders aufgebaute Query muss zu einem entsprechend korrekten (ggf. anders sortierten/strukturierten) Ergebnis führen. Das ist die zentrale, nicht verhandelbare Anforderung an diese Lösung.

5. **Konsistenzprüfung**: Teste nach dem Bau, dass alle 8+2 Musterlösungs-Queries (aus dem angehängten Lösungs-Notebook) im lokalen Fallback-Modus **korrekte, plausible Ergebnisse** liefern, die inhaltlich den erwarteten Ergebnissen aus den "📊 Erwartetes Ergebnis"-Abschnitten im Aufgaben-Notebook entsprechen.

6. **Textanpassung im Intro**: Passe die Einleitung im Studierenden-Notebook minimal an, sodass ehrlich kommuniziert wird, dass die Datenbasis "ein Auszug aus Wikidata" ist, statt unbedingt "live" zu behaupten – ohne den motivierenden WM-Bezug oder das Szenario zu verlieren.

## Output

Liefere:
- Eine `.ttl`-Datei mit dem lokalen RDF-Datensatz
- Das aktualisierte Studierenden-Notebook (`.ipynb`) mit erweiterter `run_query()`-Funktion und angepasstem Intro-Text, sonst identisch zur angehängten Version
- Die aktualisierte Musterlösung (`.ipynb`) mit derselben `run_query()`-Funktion
- Eine kurze Erklärung, welche Daten im lokalen Graphen enthalten sind und woher die Werte stammen (damit ich das vor der Vorlesung gegenchecken kann)

## Wichtige Rahmenbedingungen

- Die Vorlesung findet in Kürze statt – die Lösung muss **garantiert funktionieren**, auch komplett offline/ohne Internetzugang zu Wikidata
- Zielumgebung: Google Colab, Studierende öffnen das Notebook über einen Link und arbeiten in eigener Kopie (kein gemeinsamer Account, kein Login)
- Ändere an der didaktischen Struktur (Aufgabentexte, Hinweise, Cheat Sheet, Schwierigkeitsprogression) nichts – nur die Datenanbindung/`run_query()`-Funktion und den Intro-Text
