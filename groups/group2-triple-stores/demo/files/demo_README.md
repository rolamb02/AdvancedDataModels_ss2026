# Triplestore Demo – README

**Gruppe 2: Semantic Triple Stores / RDF + SPARQL**  
Tool: Oxigraph · Datensatz: Deutsche Universitäten (custom)

---

## Schnellstart (vor der Präsentation ausführen)

```bash
# 1. Oxigraph starten
docker-compose up -d

# 2. Prüfen ob er läuft
open http://localhost:7878

# 3. Demo ausführen
bash run_demo.sh
```

---

## Verzeichnisstruktur

```
triplestore-demo/
├── docker-compose.yml          # Oxigraph Container
├── run_demo.sh                 # Automatisches Demo-Script
├── data/
│   └── universitaeten.ttl      # Der gesamte Datensatz (Turtle-Format)
└── queries/
    ├── 01_alle_universitaeten.sparql
    ├── 02_unis_in_bw.sparql
    ├── 03_studenten_uni_stuttgart.sparql
    ├── 04_personen_OHNE_inferenz.sparql   ← Aha-Moment Teil 1
    ├── 05_personen_MIT_inferenz.sparql    ← Aha-Moment Teil 2
    ├── 06_count_pro_uni.sparql
    └── 07_federated_dbpedia.sparql        ← Optional
```

---

## Was Oxigraph ist und warum wir es nutzen

Oxigraph ist ein Triplestore geschrieben in Rust. Er unterstützt:
- RDF 1.1 (Turtle, N-Triples, JSON-LD)
- SPARQL 1.1 (Queries, Updates, Graph Store Protocol)
- Eingebaute Web-UI mit SPARQL-Editor

Warum nicht Jena Fuseki: Jena ist mächtiger (vollständiges OWL-Reasoning),
aber braucht JVM und ist komplexer aufzusetzen. Für eine 30-Minuten-Live-Demo
auf verschiedenen Laptops ist Oxigraph zuverlässiger.

---

## Der Datensatz erklärt (universitaeten.ttl)

### Ontologie — das Herzstück

```turtle
uni:Person         a rdfs:Class .

uni:AcademicPerson rdfs:subClassOf uni:Person .

uni:Professor      rdfs:subClassOf uni:AcademicPerson .
uni:Student        rdfs:subClassOf uni:AcademicPerson .
```

Das bedeutet:
- Jeder Professor ist automatisch auch eine AcademicPerson
- Jede AcademicPerson ist automatisch auch eine Person
- Also: Jeder Professor ist automatisch auch eine Person (transitiv)
- Das steht NICHT explizit im Datensatz — der Store schlussfolgert es

### Instanzen

```
4 Städte:       Stuttgart, Karlsruhe, München, Berlin
4 Unis:         UniStuttgart, KIT, TUMünchen, FUBerlin
3 Professoren:  ProfMüller (Stuttgart), ProfSchneider (KIT), ProfWeber (TUM)
4 Studenten:    Alice + Bob (Stuttgart), Carla (KIT), David (TUM)
```

**Wichtig:** Niemand ist explizit als `uni:Person` eingetragen.
Alle sind entweder `uni:Professor` oder `uni:Student`. Das Setup für den Aha-Moment.

---

## Die Queries erklärt — was genau passiert

### Query 1 – Alle Universitäten

```sparql
SELECT ?u ?name
WHERE {
    ?u a uni:University .
    ?u rdfs:label ?name .
}
```

**Was passiert:** Der Store durchsucht alle Triples nach zwei Mustern:
1. `?u rdf:type uni:University` → findet alle 4 Universitäten
2. `?u rdfs:label ?name` → holt für jede den Namen

`?u` ist eine Variable — der Platzhalter für "was auch immer dort steht".
Der Name der Variable (`?u`, `?x`, `?baum`) ist komplett egal.

**Ergebnis:** 4 Zeilen — eine pro Universität.

---

### Query 2 – Unis in Baden-Württemberg

```sparql
SELECT ?uniname ?stadtname
WHERE {
    ?u  a            uni:University .
    ?u  rdfs:label   ?uniname .
    ?u  uni:location ?stadt .
    ?stadt rdfs:label    ?stadtname .
    ?stadt uni:bundesland "Baden-Württemberg" .
}
```

**Was passiert:** 5 Triple-Muster müssen alle gleichzeitig erfüllt sein.
`?u` und `?stadt` sind dieselbe Variable in verschiedenen Rollen:
- `?u uni:location ?stadt` → verknüpft Uni mit ihrer Stadt
- `?stadt uni:bundesland "Baden-Württemberg"` → filtert nach Bundesland

In SQL wäre das ein JOIN über zwei Tabellen. Hier ist es einfach
ein weiteres Triple-Muster — kein JOIN-Keyword, kein ON.

**Ergebnis:** UniStuttgart + KIT (beide in BW).

---

### Query 3 – Studenten an der Uni Stuttgart

```sparql
SELECT ?name ?fach ?semester
WHERE {
    ?s a             uni:Student .
    ?s rdfs:label    ?name .
    ?s uni:studiesAt uni:UniStuttgart .
    ?s uni:studienfach ?fach .
    ?s uni:semester  ?semester .
}
```

**Was passiert:** `uni:UniStuttgart` ist hier keine Variable sondern
eine konkrete URI — das ist der Filter. Nur wer explizit
`uni:studiesAt uni:UniStuttgart` hat, wird gefunden.

**Wichtige Falle für das Publikum:**
`?s a uni:Student` muss dabei sein — ohne diese Zeile würden auch
Professoren, die an der Uni arbeiten, erscheinen.
Der Variablenname `?s` sagt dem Store nicht, dass es ein Student ist!

**Ergebnis:** Alice Schmidt + Bob Fischer.

---

### Query 4 – OHNE Inferencing (Aha-Moment Teil 1)

```sparql
SELECT ?person ?name
WHERE {
    ?person a        uni:Person .
    ?person rdfs:label ?name .
}
```

**Was passiert:** Der Store sucht Triples der Form `?person rdf:type uni:Person`.
Im Datensatz gibt es kein einziges solches Triple — alle sind entweder
`uni:Professor` oder `uni:Student`, aber niemand ist explizit `uni:Person`.

**Ergebnis: 0 Zeilen.**

Vorher ans Publikum fragen: "Wie viele Ergebnisse erwartet ihr?"
Die meisten sagen 7. Das ist der Aufbau des Aha-Moments.

---

### Query 5 – MIT Inferencing (Aha-Moment Teil 2)

```sparql
SELECT ?person ?name ?typ
WHERE {
    ?person a        ?typ .
    ?typ    rdfs:subClassOf* uni:Person .
    ?person rdfs:label ?name .
}
```

**Was passiert:** `rdfs:subClassOf*` ist ein SPARQL Property Path.
Das `*` bedeutet "null oder mehr Schritte entlang rdfs:subClassOf".

Der Store traversiert die Hierarchie:
```
uni:Professor → rdfs:subClassOf → uni:AcademicPerson
                                → rdfs:subClassOf → uni:Person ✓
uni:Student   → rdfs:subClassOf → uni:AcademicPerson
                                → rdfs:subClassOf → uni:Person ✓
```

Für jeden `?person` mit Typ `?typ` prüft der Store:
"Ist `?typ` ein Subtyp von `uni:Person` (in null oder mehr Schritten)?"

**Ergebnis: 7 Zeilen** — alle Professoren und Studenten,
obwohl niemand explizit als `uni:Person` eingetragen ist.

**Das erklären:** "Wir haben die Ontologie-Regel einmal definiert
(`Professor subClassOf AcademicPerson subClassOf Person`).
Ab jetzt gilt sie für alle neuen Einträge automatisch.
In SQL müssten wir das bei jedem INSERT manuell pflegen."

---

### Query 6 – COUNT pro Universität

```sparql
SELECT ?uniname (COUNT(?person) AS ?personenanzahl)
WHERE {
    ?person a        ?typ .
    ?typ    rdfs:subClassOf* uni:Person .
    ?person (uni:studiesAt | uni:worksAt) ?u .
    ?u      rdfs:label ?uniname .
}
GROUP BY ?uniname
ORDER BY DESC(?personenanzahl)
```

**Neu hier:**
- `(uni:studiesAt | uni:worksAt)` — UNION zweier Prädikate in einem Schritt
  (Studenten studieren, Professoren arbeiten — beides auf einmal abfragen)
- `COUNT(?person) AS ?personenanzahl` — Aggregation wie in SQL
- `GROUP BY` — Gruppierung wie in SQL

**Ergebnis:** TUM (2), UniStuttgart (3), KIT (2), FUBerlin (0).

---

### Query 7 – Federated Query (Optional)

```sparql
SELECT ?uniname ?abstract
WHERE {
    # Lokal: Unis in BW
    ?u a uni:University .
    ?u rdfs:label ?uniname .
    ?u uni:location ?stadt .
    ?stadt uni:bundesland "Baden-Württemberg" .

    # Von DBpedia: Beschreibung der Uni Stuttgart
    SERVICE <https://dbpedia.org/sparql> {
        dbr:University_of_Stuttgart dbo:abstract ?abstract .
        FILTER (lang(?abstract) = "en")
    }
}
```

**Was passiert:** `SERVICE` delegiert einen Teil der Query an den
DBpedia-Endpunkt. Der lokale Store kombiniert beide Ergebnisse automatisch.

Das funktioniert, weil beide denselben URI-Standard nutzen.
`dbr:University_of_Stuttgart` ist in DBpedia und lokal dieselbe Entität.

**Erklärung für Publikum:** "Das ist die Stärke von Linked Data.
Wir brauchen nicht alle Daten der Welt selbst zu speichern.
Wir verlinken einfach auf andere Triplestores."

**Fallback:** Screenshot vorab erstellen falls DBpedia langsam ist.

---

## Live-Demo in der Präsentation — Ablauf

| Zeitpunkt | Aktion | Dauer |
|---|---|---|
| 0:00 | Docker läuft bereits, Oxigraph Web-UI zeigen | 2 min |
| 0:02 | Datensatz erklären (Turtle-File kurz zeigen) | 3 min |
| 0:05 | `run_demo.sh` starten — Daten laden | 1 min |
| 0:06 | Queries 1–3 durchgehen | 7 min |
| 0:13 | Query 4: "Wie viele erwartet ihr?" → 0 Ergebnisse | 4 min |
| 0:17 | Query 5: Inferencing erklärt + live | 5 min |
| 0:22 | Query 6: COUNT live | 3 min |
| 0:25 | Query 7: Federated (optional) | 3 min |
| 0:28 | Web-UI zeigen — Publikum kann selbst tippen | 2 min |

---

## Vorbereitung Checkliste

- [ ] Docker installiert und läuft
- [ ] `docker-compose up -d` ausgeführt
- [ ] `http://localhost:7878` öffnet sich im Browser
- [ ] `bash run_demo.sh` einmal vollständig durchgetestet
- [ ] Fallback-Screenshot von Query 7 (DBpedia) gespeichert
- [ ] Für Interaktive Übung: Query 4 und 5 als Aufgabe vorbereitet

---

## Technische Details

**Daten laden via curl (manuell):**
```bash
curl -X POST http://localhost:7878/store \
  -H "Content-Type: text/turtle" \
  --data-binary @data/universitaeten.ttl
```

**Query direkt via curl:**
```bash
curl -G http://localhost:7878/query \
  --data-urlencode "query=SELECT ?s WHERE { ?s a <http://example.org/uni/University> }" \
  -H "Accept: application/sparql-results+json"
```

**Daten löschen (für Neustart):**
```bash
curl -X DELETE http://localhost:7878/store
```
