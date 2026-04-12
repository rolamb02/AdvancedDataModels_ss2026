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

**Warum diese Query als Einstieg gut ist:**
Hier sieht man den Kern von SPARQL in seiner einfachsten Form: zwei Muster, die über dieselbe Variable `?u` zusammengehören. Erst wird der Typ gesucht, dann wird der Name derselben Ressource gelesen.

---

### Query 2 – Unis in Baden-Württemberg

```sparql
SELECT ?uniname ?stadtname
WHERE {
    ?u  a            uni:University .
    ?u  rdfs:label   ?uniname .
    ?u  uni:location ?stadt .
    ?stadt rdfs:label    ?stadtname .
    ?stadt uni:bundesland "Baden-W\u00FCrttemberg" .
}
```

**Was passiert:** Fünf Triple-Muster müssen gleichzeitig erfüllt sein.
`?u` und `?stadt` sind Verknüpfungsvariablen:
- `?u a uni:University` findet zunächst alle Universitäten.
- `?u rdfs:label ?uniname` liest den Namen der Universität.
- `?u uni:location ?stadt` verknüpft die Universität mit ihrer Stadt.
- `?stadt rdfs:label ?stadtname` liest den Städtenamen.
- `?stadt uni:bundesland "Baden-W\u00FCrttemberg"` filtert auf Städte in Baden-Württemberg.

In SQL wäre das ein JOIN über zwei Tabellen. Hier ist es einfach
ein weiteres Triple-Muster — kein JOIN-Keyword, kein ON.

**Ergebnis:** UniStuttgart + KIT (beide in BW).

**Warum die Query vorher 0 liefern konnte:**
Der Datensatz war korrekt, aber der direkt geschriebene Umlautwert konnte in Windows/Git-Bash je nach Encoding falsch interpretiert werden. Die Unicode-Escape-Schreibweise ist robuster und semantisch identisch.

**Merke:**
Die Datenbank war also nicht leer und die Query war nicht logisch falsch. Das Problem lag an der Literal-Schreibweise im Zusammenspiel mit der Shell/Encoding-Kette.

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

**Worauf man beim Erklären achten kann:**
Diese Query zeigt, dass ein konkreter URI-Wert wie `uni:UniStuttgart` als harter Filter wirkt. Gleichzeitig zeigt sie, dass SPARQL keine implizite Bedeutung aus Variablennamen ableitet: `?s` ist nur ein Platzhalter, kein Datentyp.

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

**Warum 0 hier korrekt ist:**
Im Datensatz gibt es zwar Professoren und Studenten, aber niemand ist explizit als `uni:Person` gespeichert. Ohne Inferencing sucht der Store nur nach exakt diesem Typ und findet deshalb nichts.

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

**Merksatz:**
`rdfs:subClassOf*` bedeutet "null oder mehr Schritte". Damit werden auch indirekte Unterklassen mitgenommen, also nicht nur `AcademicPerson`, sondern auch `Professor` und `Student`.

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

**Warum nur 3 Zeilen erscheinen:**
FUBerlin hat in diesem Datensatz keine zugeordneten Personen. Die Query gibt nur Gruppen aus, die mindestens ein Matching haben. Ein explizites `0` für FUBerlin würde einen anderen Query-Ansatz mit `OPTIONAL` oder einer separaten Uniliste brauchen.

**Didaktischer Fokus:**
Hier kann man gut zeigen, dass SPARQL nicht nur filtern kann, sondern auch aggregieren. Genau wie bei SQL wird erst gesammelt, dann gruppiert und anschließend gezählt.

---

### Query 7 – Federated Query (Optional)

```sparql
SELECT ?uniname ?description
WHERE {
    # Lokal: Unis in BW
    ?u a uni:University .
    ?u rdfs:label ?uniname .
    ?u uni:location ?stadt .
    ?stadt uni:bundesland "Baden-W\u00FCrttemberg" .

    # Von DBpedia: Beschreibung der Uni Stuttgart
    SERVICE <https://dbpedia.org/sparql> {
        dbr:Stuttgart dbo:description ?description .
        FILTER (lang(?description) = "en")
    }
}
```

**Was passiert:** `SERVICE` delegiert einen Teil der Query an den
DBpedia-Endpunkt. Der lokale Store kombiniert beide Ergebnisse automatisch.

Das funktioniert, weil beide denselben URI-Standard nutzen.
`dbr:Stuttgart` ist in DBpedia die korrekte, case-sensitive Ressource für die Stadt Stuttgart. URIs sind immer exakt und unterscheiden Groß- und Kleinschreibung.

**Erklärung für Publikum:** "Das ist die Stärke von Linked Data.
Wir brauchen nicht alle Daten der Welt selbst zu speichern.
Wir verlinken einfach auf andere Triplestores."

**Fallback:** Screenshot vorab erstellen falls DBpedia langsam ist.

**Wichtiger Praxis-Hinweis:**
Diese Query ist bewusst optional. Wenn DBpedia nicht erreichbar ist, das Netz blockiert, oder die Antwort sehr langsam ist, ist das kein Defekt im lokalen Datensatz. In der Live-Demo sollte man deshalb immer einen vorbereiteten Screenshot oder eine Alternative parat haben.

**Warum sie in manchen Umgebungen 0 liefern kann:**
Der lokale Teil ist korrekt, aber der `SERVICE`-Aufruf hängt von einem externen SPARQL-Endpunkt ab. Wenn dieser nicht antwortet, die Netzwerkkonfiguration restriktiv ist oder die URI falsch geschrieben ist, bricht die Query in der Praxis leicht weg.

**Wichtiger Praxis-Hinweis:**
Im DBpedia-Web-Editor müssen die Prefixe entweder oben definiert sein oder vollständig ausgeschrieben werden. Für den Test im Browser also am besten zuerst diese Prefixe setzen:

```sparql
PREFIX dbr: <http://dbpedia.org/resource/>
PREFIX dbo: <http://dbpedia.org/ontology/>
```

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

### Was im Hintergrund passiert (Kommunikationsfluss)

Der Demo-Ablauf wirkt interaktiv, ist technisch aber ein klarer Request-Flow:

1. `run_demo.sh` prüft den Endpoint mit einem kleinen Test-Query gegen `http://localhost:7878/query`.
2. Das Turtle-File wird mit `PUT /store?default` in den Default-Graph geladen.
3. Für jede Query-Datei:
    - Datei wird gelesen.
    - Kommentarzeilen werden entfernt.
    - Query wird per `POST /query` als `application/sparql-query` gesendet.
4. Oxigraph liefert SPARQL-JSON zurück.
5. Ein eingebettetes Python-Snippet formatiert das JSON als terminalfreundliche Tabelle.
6. Bei Query 7 führt Oxigraph intern den `SERVICE`-Teil gegen `https://dbpedia.org/sparql` aus und kombiniert lokale + externe Teilergebnisse.

**Wichtig für die Präsentation:**
- Schritte 1-8 funktionieren komplett lokal (kein Internet nötig).
- Nur Query 7 braucht Internet und einen erreichbaren DBpedia-Endpunkt.
- Wenn Query 7 ausfällt, ist das oft ein externes Netz-/Endpoint-Thema und kein Fehler im lokalen Datensatz.

**Daten laden via curl (manuell):**
```bash
curl -X PUT "http://localhost:7878/store?default" \
  -H "Content-Type: text/turtle" \
  --data-binary @data/universitaeten.ttl
```

**Warum das hier wichtig ist:**
Die Demo lädt die Turtle-Datei in den Default-Graph. Nur dann funktionieren die Queries ohne `GRAPH`-Klausel genau so, wie sie im Script und in der Präsentation erklärt werden.

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
