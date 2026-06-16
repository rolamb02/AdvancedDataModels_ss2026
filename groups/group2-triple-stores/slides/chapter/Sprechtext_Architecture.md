# Sprechtext – Kapitel: Architecture

---

## Folie 1: Systemarchitektur – Was steckt in einem Triple Store?

**Was zeigt die Folie?**
Schematischer Aufbau eines Triple Stores: von der Datenhaltung bis zum SPARQL-Endpunkt.

---

### Kernpunkte

**Der rote Faden:** Wir wissen jetzt, wie Daten als Triples gespeichert sind (Data Structure) und wie man sie abfragt (Query Model). Die Frage ist jetzt: *Wie macht ein System das performant und intelligent?*

**Komponenten eines Triple Store (von unten nach oben):**

1. **Storage Layer** – wo und wie Triples physisch liegen (→ Folie 2)
2. **Index Layer** – SPO/POS/OSP-Indizes für schnelle Pattern-Lookups
3. **SPARQL Query Engine** – parst die Query, plant und führt sie aus
4. **Reasoner / Inference Engine** – leitet neue Triples ab (optional, konfigurierbar)
5. **SPARQL Endpoint** – HTTP-Interface, über das Clients Queries schicken

**Chain of Thought:**
> Eine Query kommt rein → Query Engine parst sie → zerlegt sie in Pattern-Lookups → geht in den Index → holt Kandidaten → führt Joins/Filter aus → gibt Ergebnis zurück
> Optionaler Umweg: vor oder nach dem Query der Reasoner ergänzt implizite Triples

**SPARQL-Endpunkt konkret:**
- Standard: HTTP POST/GET an `/query` mit SPARQL-String im Body
- Oxigraph: `http://localhost:7878/query`
- Gibt Ergebnis als JSON, CSV, XML zurück (konfigurierbar per `Accept`-Header)
- Das ist der "Türöffner" für externe Clients, RAG-Pipelines, Visualisierungstools

---

## Folie 2: Storage-Architekturen – Wie werden Triples gespeichert?

**Was zeigt die Folie?**
Drei Speichertypen: In-Memory, Native, Non-Native. Tradeoffs.

---

### Kernpunkte

**In-Memory Storage:**
- Alle Triples liegen im RAM → blitzschnelle Lookups, kein Festplatten-I/O
- Problem: kein Neustart überlebt (außer mit Snapshot/Dump)
- Einsatz: Prototypen, Tests, kleine Datasets – genau wie unsere Demo mit Oxigraph
- Konkret: Demo lädt die TTL-Datei beim Start in den Speicher → nach `docker stop` weg

**Native Storage:**
- Datenbankformat speziell für Triples/Graphen gebaut – kein Umweg über relationale Tabellen
- Beispiel Jena TDB2: speichert Triples in einem B+-Tree-Index-Format, optimiert für SPO-Lookups
- Vorteil: keine Übersetzungsschicht, direkter Zugriff auf die Graphstruktur
- Vergleich: wie ein Python-Dict vs. eine CSV-Datei – Dict ist nativ für Key-Lookup gebaut

**Non-Native Storage:**
- RDF-Daten auf relationale DB (PostgreSQL, Oracle) oder Dokumentenstore gemappt
- Vorteil: nutzt vorhandene Infrastruktur, ACID-Transaktionen, bekannte Backup-Prozesse
- Nachteil: jeder Query muss in SQL übersetzt werden → Overhead, suboptimal für tief vernetzte Daten
- Einsatz: Enterprise-Umgebungen, wo bestehende DB-Infrastruktur nicht ersetzt werden soll

**SPO-Indizes – warum mehrere?**
- Ein Triple `(S, P, O)` – je nach Query-Pattern suche ich von unterschiedlichen Seiten an:
  - `?s a uni:University` → ich suche nach Subjekten mit festem Prädikat → PO-Index
  - `uni:AliceSchmidt ?p ?o` → ich suche alle Aussagen über Alice → SP-Index
  - `?s ?p uni:Stuttgart` → ich suche alles, was Stuttgart als Objekt hat → O-Index
- Mehrere Indizes = Antwort auf jede Zugriffsrichtung in O(log n) statt linearem Scan

---

## Folie 3: SPARQL Query Engine & Reasoning

**Was zeigt die Folie?**
Wie wird eine Query ausgeführt? Wie funktioniert Inferenz im Store?

---

### Kernpunkte

**Query Execution Pipeline:**
- Parse: SPARQL-String → Abstract Syntax Tree
- Plan: Welche Patterns werden in welcher Reihenfolge ausgewertet? (Join-Ordering)
- Execute: Pattern-Lookups im Index → Zwischenergebnisse → Join über geteilte Variablen
- Filter: FILTER-Bedingungen auf gebundene Variablen anwenden
- Project: nur SELECT-Variablen ausgeben

**Warum Join-Ordering wichtig ist (Beispiel):**
- Query: `?s a uni:Student . ?s uni:studiesAt uni:UniStuttgart . ?s rdfs:label ?name`
- Schlechte Reihenfolge: erst alle Labels holen (viele) → dann filtern
- Gute Reihenfolge: erst `studiesAt UniStuttgart` (selektiv, wenige Treffer) → dann Label holen
- Guter Query Planner macht das automatisch → relevanter für große Datensätze

**Reasoning / Inference Engine:**

- **Forward Chaining (Materialization):**
  - Store wendet Regeln auf alle Daten an und speichert abgeleitete Triples vorab
  - Beispiel: `Student rdfs:subClassOf Person` → materialisiere `Alice a Person` beim Laden
  - Vorteil: Query-Antwort schnell (abgeleitete Fakten schon da)
  - Nachteil: mehr Speicher, Neuberechnung bei Datenänderung

- **Backward Chaining (Query-time Reasoning):**
  - Ableitungen werden erst bei Abfrage berechnet, nichts vorab gespeichert
  - Vorteil: weniger Speicher, immer aktuell
  - Nachteil: längere Query-Laufzeit

- **Entailment Regimes** = formales Regelwerk, das festlegt, welche Ableitungen gelten:
  - Simple: nur explizite Triples
  - RDFS: `subClassOf`, `domain`, `range` – unser Demo-Aha-Moment (Q4 → Q5)
  - OWL: Äquivalenzen, Restriktionen, Rollenverkettungen – mächtig, aber rechenintensiv
  - Chain of Thought: je mehr Regeln, desto mehr implizites Wissen, desto teurer die Ausführung

**Verbindung zu Query Model:**
- Query 5 nutzt `rdfs:subClassOf*` als Property-Path-Traversal – das ist *nicht* Entailment
- Echter RDFS-Entailment würde `Alice a Person` bereits *materialisiert* liefern, auch bei `?p a uni:Person`
- Oxigraph in unserer Demo: kein automatisches Entailment → deshalb Query 4 = 0 Treffer

---

## Folie 4: Deployment & Systeme

**Was zeigt die Folie?**
Single-Node vs. verteilte Deployments. Konkrete Systeme im Überblick.

---

### Kernpunkte

**Deployment-Optionen:**
- **Single Node / Embedded:** Triple Store läuft im selben Prozess wie die Anwendung (z. B. Jena TDB lokal). Einfach, kein Netzwerk-Overhead. Für kleine Datasets und Entwicklung.
- **Client-Server:** Store läuft als eigenständiger Prozess/Container, Clients sprechen HTTP. Unser Demo-Setup: Oxigraph in Docker, Clients per curl/Browser. Typisch für Produktion.
- **Verteilte/Cluster-Setups:** Mehrere Store-Knoten, Replikation/Sharding. Nötig bei Milliarden Triples oder hoher Query-Last. Komplexer, aber horizontal skalierbar.

**Konkrete Systeme:**

| System | Besonderheit |
|---|---|
| **Apache Jena Fuseki** | Java/JVM, weit verbreitet, gutes Ökosystem, RDFS-Reasoning eingebaut |
| **GraphDB** (Ontotext) | Enterprise-Feature-Set, OWL-Reasoning, gut für Produktion |
| **Oxigraph** | Rust, leichtgewichtig, kein JVM, unser Demo-System |
| **Blazegraph** | Früher Wikidata-Backend, performant, aber kaum noch aktiv gepflegt |
| **Virtuoso** | Hybrid (relational + RDF), sehr performant, DBpedia läuft darauf |

**Warum Oxigraph für die Demo?**
- Kein JVM → startet sofort, kein `java -Xmx4g` etc.
- Docker-Image klein (~20 MB)
- SPARQL 1.1 konform, einfaches HTTP-Interface
- Nachteil: kein eingebautes RDFS/OWL-Reasoning → gut für Demo, weil wir Inferenz *explizit* über Property Paths zeigen

**Skalierung & Performance (kurz):**
- Hauptflaschenhals: Join-Explosion bei vielen Triple-Patterns
- Caching: häufige Queries und Teilpläne können gecacht werden
- Für sehr große Daten: Sharding nach Subjekt-URI oder Named Graph

---

## Kapitel-Takeaway

> Ein Triple Store ist mehr als eine Datenbank – es ist ein System das Wissen speichert, indexiert, ableitet und exponiert.
> Die Wahl der Speicher-Architektur und des Reasoning-Modes entscheidet, wie viel implizites Wissen abfragbar ist und zu welchem Preis.
> Unser Demo-Stack (Oxigraph, In-Memory, kein Entailment) ist bewusst minimal – zeigt aber alle Kernkonzepte.

Systeme
https://www.google.com/search?q=oxigraph+vs+apache+jena+fuseki&sca_esv=215c4864aa272928&sxsrf=ANbL-n6YSMS_aCvW0WaB5gKVXwOTihRV3Q%3A1781531131982&ei=-wEwapC2ONSK9u8Pp_rVkAM&iflsig=AFdpzrgAAAAAajAQC7-OG60Fim3WerxozG3LIt9-oJWB&uact=5&sclient=gws-wiz&udm=50&fbs=ADc_l-YGrpJMQtvjQ6h14rj-dfIrH4mwN5r0Z1FZtFNB2w3Upe2HDPC6akWpYUJBWeXXRd1azDDD-oRDTkXhWfw1DDdzjdKakb3ZawuEGO-tTBjLJsheVAWWQSnasbvNq9p5Y5ri6Bmz1OdwKIvVoqsvP6Oe2ibOAXA792J37hHZ3Vg1tW3o_nD2z2phlQ93omKPojI3p3Qn&aep=10&ntc=1&mstk=AUtExfDZcA8Iyqqu7Li0AJmCX1oXW3Ftr1x9pfJ7cEZm8gznQsVCcIP0PeqBKO9K3cGXr0NgaDTzBTMn2-g3fMELFyxl3q54UJavCHWVtPxVrlEorUbWZncHtNBrtAn2NdFrWYk_8ejlFhkkWfhVQhh1Djv4os6LBwYSGltRaM2oEFmeEDnNBmQMqJwjX8KzlQjszEt-HRlTMwd4zzaUJVAvfgH66Cyh0doCI60CMx_RucJJUhVdi9tzmaIhKKCUoJUNvfCPKMTGn91G-72TD9WUIXtcDD3Spw5ndOl_0gaaFjNqta6wciD1irPQGR9jfMl0nbiJocbtvbhkyyulZT4JWZJttpDakHUoeS8s59XwJ1eno5AnkAiXBFM&aioh=3&csuir=1&cs=1&mtid=tQIwapqgEd_jxc8PwvHSwAI

https://www.google.com/search?q=rdf+cloud+option+amazon+neptune+vs+graphdb+&sca_esv=215c4864aa272928&sxsrf=ANbL-n5G0ID2UXcI9E-08pslwEtrhRf_vg%3A1781531469691&ei=TQMwavScJ76di-gPs-qFAQ&iflsig=AFdpzrgAAAAAajARXavCyRpNtrhiJ0sAmnr2T7JvGIBV&uact=5&sclient=gws-wiz&udm=50&fbs=ADc_l-YGrpJMQtvjQ6h14rj-dfIrH4mwN5r0Z1FZtFNB2w3Upe2HDPC6akWpYUJBWeXXRd0BtTsaeIMiSqrSSe4pv7ADcP9WHmHSnvgEp0DCuDaMFQVNHY0iYeRTPcXSUj7IStmoGS7kkoLRJW_n4Fi7HBwGTum-kk1a0wYDmtR7oYw-l5pJAOGDyQbBKQJYbyF4lFhS7wN2&aep=10&ntc=1&mstk=AUtExfCE35pbhu5CmHb_mOsBExQlB3KszeE6MVsCBxBeej_6vnmuhd6ppeaqLBtKx-LWLQhK7KePod4kS876cHMvOViRYSCVJhwGlsFQiscipzOvfA1EjrYzAaQhuvTQfaPjGKbpQYD9WQ7Kk0r2I3V2hiVR3Gk_JKWjMBQsTCDsK89ovWWM3-THxCBGObNppzxQMh2LfLUiM3mbdXkE9CFluSzx9ZjYYFiQAqtwagKl486g6yaMHW8bKJXD80I2c6PuL5SF1WGVD2En4pe9xd5fTiFdRTO21_vn4MQfB25zyf6C42P3YipBkKouC6XwoWWZM8rSrm9KJ8bMzHc7NKSszwHJFhmz8IqLKAbi4HDMJc2pfCjFJ7iByb4&aioh=3&csuir=1&cs=1&mtid=mgMwaobcO8m4i-gP1vLnoA0

