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

### Interaktive Live-Queries im gleichen WLAN/LAN

Ziel: Studierende sollen auf dieselbe Oxigraph-Web-UI zugreifen können.

1. Docker-Setup bleibt unverändert (Oxigraph bindet bereits auf `0.0.0.0:7878`).
2. Auf Windows einmalig Port 7878 freigeben (PowerShell als Admin):

```powershell
New-NetFirewallRule -DisplayName "Oxigraph 7878" -Direction Inbound -LocalPort 7878 -Protocol TCP -Action Allow
```

3. Eigene IPv4-Adresse ermitteln (`ipconfig`) und an die Gruppe teilen:
    - Web-UI: `http://<DEINE_IPV4>:7878`
    - Query-Endpoint: `http://<DEINE_IPV4>:7878/query`
4. Optional im Script LAN-Hinweis anzeigen:

```bash
OXIGRAPH_LAN_HOST=192.168.x.x bash run_demo.sh
```

**Read-only-Regel für die Übung (empfohlen):**
- Nur `SELECT`-Queries in der Web-UI.
- Keine `INSERT`/`DELETE`/`UPDATE` und keine Schreibzugriffe auf `/store`.

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

### Was ist JVM? 
**JVM (Java Virtual Machine)** ist eine Laufzeitumgebung, die Java-Programme ausführt. Sie übersetzt Bytecode in Maschinencode und verwaltet Speicher automatisch. Jena Fuseki benötigt die JVM, was bedeutet: größerer RAM-Verbrauch, längere Startzeit und zusätzliche Abhängigkeiten — unpraktisch für eine spontane Live-Demo auf verschiedenen Laptops im Seminar.

### Warum braucht Jena die JVM und Oxigraph nicht?
Jena ist in Java geschrieben und benötigt die JVM, um ausgeführt zu werden. Oxigraph hingegen ist in Rust geschrieben, einer Sprache, die direkt in Maschinencode kompiliert wird. Dadurch benötigt Oxigraph keine zusätzliche Laufzeitumgebung und ist leichtergewichtig, schneller startbereit und verbraucht weniger Ressourcen — ideal für eine Live-Demo in einem Seminar.

### Was passiert also genau, wenn ich den Docker-Container starte?
1. Docker lädt das Oxigraph-Image und startet einen Container.
2. Oxigraph initialisiert seinen internen Speicher und öffnet den SPARQL-Endpoint auf Port 7878.
3. Die Web-UI ist unter `http://localhost:7878` erreichbar
4. Das `run_demo.sh`-Script lädt den Turtle-Datensatz in den Store und führt die SPARQL-Queries nacheinander aus, wobei die Ergebnisse formatiert im Terminal ausgegeben werden.

### Kann ich nicht einfach Docker Image mit Jena und JVM starten? 
Theoretisch ja, es gibt offizielle Jena Docker-Images. Aber in der Praxis ist die JVM-Startzeit und der Ressourcenverbrauch deutlich höher als bei Oxigraph. Für eine 30-minütige Live-Demo, bei der wir schnell zwischen verschiedenen Laptops wechseln, ist Oxigraph zuverlässiger und benutzerfreundlicher. Jena könnte auf manchen Systemen langsamer starten oder mehr RAM benötigen, was die Demo stören könnte.

### Wäre nach dem Starten der Workflow der gleiche, also dass ich über Web-UI oder `curl` SPARQL-Queries an den Endpoint schicke?
Ja, der Workflow wäre grundsätzlich ähnlich. Nach dem Starten des Jena Fuseki Docker-Containers könntest du ebenfalls über die Web-UI oder `curl` SPARQL-Queries an den Endpoint schicken. Allerdings könnte die Performance und Benutzererfahrung variieren, da Jena mehr Ressourcen benötigt und länger zum Starten braucht. Oxigraph bietet eine schnellere und leichtere Alternative, die für eine Live-Demo in einem Seminar besser geeignet ist.

### Was passiert genau wenn ich Oxipraph als Docker-Container starte? Was genau ist Oxigraph, was macht es und wie könnte ich das noch starten außer mit Docker?
Oxigraph ist ein Triplestore, der RDF-Daten speichert und SPARQL-Abfragen ermöglicht. Wenn du den Docker-Container startest, wird Oxigraph in einer isolierten Umgebung ausgeführt, die alle notwendigen Abhängigkeiten enthält. Es öffnet einen SPARQL-Endpoint auf Port 7878, über den du Queries senden kannst. Alternativ könntest du Oxigraph auch direkt auf deinem System installieren, indem du die ausführbaren Dateien von der offiziellen Website herunterlädst oder es aus dem Quellcode kompilierst. Allerdings ist die Docker-Variante einfacher und schneller für eine Live-Demo, da sie keine manuelle Installation oder Konfiguration erfordert.

---

## Architektur — Überblick

```
┌─────────────────────────────────────────────────────────────────┐
│  DEIN LAPTOP                                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  DOCKER CONTAINER (isolierte Umgebung)                  │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  OXIGRAPH (Triplestore – Rust-Programm)           │  │  │
│  │  │  - Lädt RDF-Daten                                 │  │  │
│  │  │  - Speichert in `/data` im Container              │  │  │
│  │  │  - Exportiert HTTP-API auf Port 7878              │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│         ↑                                                        │
│         │ Volume-Mounten (Persistenz)                          │
│         ↓                                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  DOCKER VOLUME `oxigraph_data`                           │  │
│  │  (RDF-Daten bleiben auch nach Container-Neustart)        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  MEIN SYSTEM (außer Docker)                              │  │
│  │  - Browser (Web-UI unter http://localhost:7878)          │  │
│  │  - Terminal (curl-Befehle)                               │  │
│  │  - Dateien (universitaeten.ttl, run_demo.sh)             │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Was passiert beim Start von `docker-compose up -d`?

1. **Docker lädt das Oxigraph-Image** (Programm-Vorlage aus der Registry)
2. **Docker startet einen Container** (isolierte Ausführungsumgebung)
3. **Oxigraph-Programm lädt** und startet auf Port 7878
4. **Der Volume wird gemountet**: Das physische Verzeichnis auf deinem Laptop wird als `/data` im Container sichtbar
5. **Oxigraph speichert alle Daten** in diesem gemounteten Verzeichnis → **bleiben persistent**, auch nach Container-Stop
6. **HTTP-API läuft**: `http://localhost:7878` wird verfügbar

**Wichtig:** Das Docker-Image ist nur die Vorlage. Das **tatsächliche Programm läuft im Speicher des Containers**. Wenn du den Container stoppst (`docker-compose down`), läuft das Programm nicht mehr — aber die Daten bleiben auf der Festplatte (im Volume).

---

## Datenfluss — Upload und Abfrage

### Szenario 1: Daten laden (Upload)

```
1. run_demo.sh oder curl-Befehl
   curl -X PUT http://localhost:7878/store?default \
        -H "Content-Type: text/turtle" \
        --data-binary @universitaeten.ttl
   
                          ↓
                          
2. Dein System sendet HTTP-Request an den lokalen Port 7878
   
                          ↓
                          
3. Docker leitet Request → Oxigraph im Container
   
                          ↓
                          
4. Oxigraph parst Turtle-Datei als RDF-Triples
   (Subjekt-Prädikat-Objekt)
   
                          ↓
                          
5. Oxigraph speichert Triples im Memory + schreibt auf Festplatte
   (in den gemounteten Volume unter /data)
   
                          ↓
                          
6. HTTP 200 OK zurück: Daten gespeichert ✓
```

**Resultat:** Alle Triples liegen jetzt im laufenden Oxigraph-Prozess.
Wenn man den Container neu startet, lädt Oxigraph sie wieder vom Volume.

---

### Szenario 2: Daten abfragen (Query)

```
1. Web-UI Browser oder curl
   curl -G http://localhost:7878/query \
        --data-urlencode "query=SELECT ?u WHERE { ?u a uni:University }"
   
                          ↓
                          
2. Dein System sendet HTTP-GET an Port 7878
   
                          ↓
                          
3. Docker leitet Request → Oxigraph im Container
   
                          ↓
                          
4. Oxigraph parst SPARQL-Query
   "Finde alle Ressourcen vom Typ uni:University"
   
                          ↓
                          
5. Oxigraph durchsucht alle Triples im Speicher
   nach Matches
   
                          ↓
                          
6. Oxigraph antwortet mit JSON oder XML
   (SPARQL-Ergebnisformat)
   
                          ↓
                          
7. Browser zeigt Tabelle oder Terminal zeigt Ergebnisse
```

**Resultat:** Schnelle Antwort (alles im RAM).
Keine Änderung an Datenspeicher.

---

### Web-UI vs. curl: Was ist der Unterschied?

- **Web-UI** (`http://localhost:7878`): Graphischer SPARQL-Editor im Browser. Nur für Abfragen geeignet.
- **curl**: Kommandozeile. Kann sowohl Upload (`PUT /store`) als auch Abfrage (`GET /query`) machen.
- Für die Demo: Zuerst Daten via `curl` laden (in `run_demo.sh`), dann Abfragen in Web-UI zeigen.

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

**Geht Inferenz nur mit `rdfs:subClassOf`?**
Nein, Inferenz kann auch über andere Prädikate wie `rdfs:subPropertyOf` oder benutzerdefinierte Regeln erfolgen. In diesem Beispiel nutzen wir `rdfs:subClassOf*`, um die Klassenhierarchie zu traversieren, aber es gibt viele Möglichkeiten,wie Inferenz in SPARQL funktionieren kann, abhängig von der Ontologie und den definierten Regeln. 

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
SELECT ?uniname ?stadtname ?description
WHERE {
    # Lokal: Unis in BW
    ?u a uni:University .
    ?u rdfs:label ?uniname .
    ?u uni:location ?stadt .
    ?stadt uni:bundesland "Baden-W\u00FCrttemberg" .
    ?stadt rdfs:label ?stadtname .
    ?stadt owl:sameAs ?dbCity .

    # Von DBpedia: Beschreibung zur verlinkten Stadt-Ressource
    SERVICE <https://dbpedia.org/sparql> {
        ?dbCity dbo:abstract ?description .
        FILTER (lang(?description) = "de")
    }
}
```

**Was passiert:** `SERVICE` delegiert einen Teil der Query an den
DBpedia-Endpunkt. Der lokale Store kombiniert beide Ergebnisse automatisch.

Der entscheidende Linked-Data-Schritt ist `owl:sameAs`:
Unsere lokale Ressource `uni:Stuttgart` ist explizit auf `dbr:Stuttgart` gemappt.
Dadurch wird nicht "geschummelt" (hart codierter DBpedia-Knoten), sondern sauber
über eine semantische Identitätsverknüpfung zwischen lokalem und globalem Wissen gejoint.

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

**Alternative (frühere Demo-Variante, ebenfalls gültig):**
Diese kompakte Query war in einer älteren Fassung enthalten. Sie fragt den DBpedia-Knoten der University of Stuttgart direkt ab und liefert typischerweise englische Abstracts.

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

Diese Variante ist didaktisch einfacher, aber weniger Linked-Data-streng als die `owl:sameAs`-Variante oben.

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
- [ ] Port 7878 in Windows-Firewall freigegeben (falls LAN-Interaktion geplant)
- [ ] Zugriff von einem zweiten Gerät getestet (`http://<DEINE_IPV4>:7878`)
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
