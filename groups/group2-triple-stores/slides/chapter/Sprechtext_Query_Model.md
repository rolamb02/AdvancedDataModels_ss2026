# Sprechtext – Kapitel: Query Model

---

## Folie 1: SPARQL als Pattern Matching – Grundidee

**Was zeigt die Folie?**
Gegenüberstellung: SQL fragt Tabellen ab → SPARQL matcht Muster im Graphen.

---

### Kernpunkte

- **Denkwechsel:** In SQL weiß ich, welche Tabelle ich will. In SPARQL beschreibe ich, wie das Gesuchte *aussieht* – der Store findet, was passt
- **Triple Pattern = Schablone:** Jedes Pattern ist wie ein RDF-Triple, nur mit Platzhaltern (Variablen mit `?`)
  - Beispiel: `?u a uni:University` → "Finde alles, was ein University-Typ ist"
  - Beispiel: `?u rdfs:label ?name` → "Hole dazu den Label-Wert"
- **Mehrere Patterns = Verknüpfung über geteilte Variablen** (kein JOIN-Keyword nötig!)
  - `?u` taucht in beiden auf → automatisch verbunden
  - Analogie: Wie ein Lückentextformular – alle Lücken mit demselben Namen müssen denselben Wert haben
- **Variablennamen sind egal** – `?u`, `?x`, `?baum` liefern dasselbe. Typ kommt aus dem Pattern (`?s a uni:Student`), nicht aus dem Namen

**Chain of Thought:**
> "Warum kein JOIN?" → weil Verbindung *implizit* durch geteilte Variable entsteht → weil der Graph selbst schon die Beziehungen trägt → kein Umweg über Fremdschlüssel-Tabellen

---

## Folie 2: SELECT, FILTER, OPTIONAL – Die Basics (Queries 1–3)

**Was zeigt die Folie?**
Query 1–3 aus der Demo als Einstieg: einfache Abfrage, Mehrfachbedingungen, konkreter URI-Filter.

---

### Kernpunkte

**SELECT + WHERE (Query 1):**
- `SELECT ?u ?name WHERE { ?u a uni:University . ?u rdfs:label ?name . }`
- Liest sich: "Für alle ?u, die University sind – gib mir Name und URI"
- Vergleich SQL: `SELECT id, name FROM university` – aber ohne vordefinierte Tabelle

**Mehrere Patterns kombinieren (Query 2):**
- Vier Patterns, zwei Variablen (`?u`, `?stadt`) – alle müssen gleichzeitig passen
- `?stadt uni:bundesland "Baden-Wuerttemberg"` → Filter über String-Literal direkt im Pattern
- SQL-Pendant wäre ein JOIN über zwei Tabellen – hier: einfach eine weitere Zeile im WHERE-Block

**Konkreter URI-Filter (Query 3):**
- `?s uni:studiesAt uni:UniStuttgart` – kein Platzhalter, feste URI als Bedingung
- Nützlich wenn man genau eine Entität als Ankerpunkt hat

**OPTIONAL (analog zu LEFT JOIN):**
- `OPTIONAL { ?p uni:fachgebiet ?fach . }` → Professoren *ohne* Fachgebiet bleiben im Ergebnis, `?fach` bleibt leer
- SQL LEFT JOIN: alle Zeilen der linken Tabelle, NULL wenn kein Match rechts
- **Wichtiger Unterschied in der Denkweise:** Im Graphen sind fehlende Fakten normal (Open World) – kein Fehler im Datensatz

**FILTER:**
- `FILTER(?semester >= 5)` → Einschränkung auf bereits gebundene Variablen
- Kommt *nach* den Pattern-Bindungen, nicht *statt* eines Patterns

---

## Folie 3: Der Aha-Moment – Queries 4 & 5 (Inferenz)

**Was zeigt die Folie?**
Query 4: 0 Treffer. Query 5: 7 Treffer. Gleiche Daten, anderes Wissen genutzt.

---

### Kernpunkte

**Query 4 – ohne Inferenz:**
- `?p a uni:Person` → 0 Ergebnisse
- Warum? Im Store steht nur `uni:AliceSchmidt a uni:Student` – nie explizit `a uni:Person`
- Der Store gibt nur zurück, was *wörtlich* drin steht

**Query 5 – mit Klassenhierarchie:**
- `?p a ?typ . ?typ rdfs:subClassOf* uni:Person .` → 7 Ergebnisse
- `rdfs:subClassOf*` = traversiere Klassenhierarchie (null oder mehr Schritte)
- Im Datensatz steht: `uni:Student rdfs:subClassOf uni:Person` → Alice ist Student → Alice *ist* Person (abgeleitet)

**Warum zwei Patterns statt einem?**
- `?p rdfs:subClassOf* uni:Person` würde nur *Klassen* finden (Student, Professor)
- Um *Instanzen* zu finden: erst `?p a ?typ` (Individuum → Klasse), dann Klassenhierarchie traversieren

**Chain of Thought:**
> Store weiß: `Student rdfs:subClassOf Person` → Alice ist Student → also gilt: Alice ist Person
> → Das ist der fundamentale Unterschied zu SQL: SQL gibt nur zurück, was steht. SPARQL + Ontologie gibt zurück, was *gilt*

**Einordnung Inferenz vs. Traversal:**
- **Traversal (hier):** bewegt sich entlang *existierender* `subClassOf`-Kanten – das sind echte gespeicherte Triples
- **Inferenz/Entailment (stärker):** Store leitet *neue* Triples ab, die nie eingetragen wurden – z. B. automatisch `Alice a Person` materialisieren. Mehr dazu in Architecture.

---

## Folie 4: Aggregation & Federation – Queries 6 & 7

**Was zeigt die Folie?**
Query 6: Zählen pro Uni. Query 7: Live-Abfrage gegen DBpedia.

---

### Kernpunkte

**Aggregation (Query 6):**
- `COUNT(?person)` + `GROUP BY ?uniname` → Anzahl Personen pro Uni, absteigend sortiert
- Syntaktisch ähnlich zu SQL GROUP BY
- Treffermenge entsteht aber durch Klassenhierarchie-Traversal (`rdfs:subClassOf* uni:Person`)
- `(uni:studiesAt | uni:worksAt)` = Property Path Union → "studiert an ODER arbeitet an"
- **Abgrenzung:** Aggregation *verdichtet* vorhandene Treffer → Inferenz *leitet neue Fakten ab* – zwei verschiedene Konzepte

**Federated Query (Query 7):**
- `SERVICE <https://dbpedia.org/sparql> { ?dbCity dbo:abstract ?description . }`
- Delegiert Subteil der Abfrage live an externen SPARQL-Endpunkt
- Verbindung über `owl:sameAs` → `uni:Stuttgart` = `dbr:Stuttgart` (Identitätslink)
- Ich mische lokale Daten (meine Unis) mit Live-Daten aus dem Web – ohne ETL, ohne Datenkopie

**Chain of Thought:**
> Ich habe lokale Daten über Stuttgarter Unis → will Beschreibung der Stadt → liegt bei DBpedia → `owl:sameAs` verknüpft Identitäten → `SERVICE` delegiert Subteil live nach draußen → Ergebnis kommt zurück und wird mit lokalem Ergebnis gejoint
> → Datenintegration ohne Datenbankkopierei

**Praxis-Hinweis für Demo:**
- Query 7 ist internetabhängig – kann langsam sein oder fehlschlagen
- Screenshot-Fallback bereithalten

---

## Folie 5: Weitere Features & Einordnung (kurz)

### Kernpunkte

**Query-Typen im Überblick:**
- `SELECT` – tabellarische Variablenbindungen (alle Demo-Queries)
- `ASK` – Ja/Nein: `ASK { uni:AliceSchmidt a uni:Student . }` → true/false
- `CONSTRUCT` – erzeugt neuen RDF-Graph aus Treffern, z. B. für Export oder Regel-Materialisierung
- `DESCRIBE` – Store-definierte Beschreibung einer Ressource; nicht normiert, gut für Exploration

**UNION:**
- Alternative Muster: `{ ?p a uni:Student . } UNION { ?p a uni:Professor . }`
- Nützlich wenn zwei Typen denselben Verarbeitungsweg durchlaufen sollen

**Entailment Regimes (kurz, Details in Architecture):**
- Simple: nur explizite Triples
- RDFS: `subClassOf`, `domain`, `range` werden ausgewertet
- OWL: reichere Ableitungen, teurer in der Laufzeit

**AI-Relevanz:**
- SPARQL als Retrieval-Schicht für RAG: faktenbasiert, erklärbar (welches Triple führte zu welcher Aussage)
- `rdfs:subClassOf*` findet implizit verwandte Konzepte → semantische Suche über Klassenhierarchien
- Jede Antwort auf konkrete Triples rückführbar → Explainability

---

## Kapitel-Takeaway

> SPARQL fragt keine Tabellen ab – es matcht Bedeutungsstrukturen im Graphen.
> Der Mehrwert zeigt sich in drei Stufen: einfache Muster (Q1–3) → Klassenhierarchie-Traversal (Q4/5 Aha-Moment) → globale Datenintegration (Q7).
