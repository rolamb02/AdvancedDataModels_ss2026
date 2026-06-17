# Sprechtext – Kapitel: Query Model

Query model (15 min) – Introduce the query language (Cypher, SPARQL, ANN API, MongoDB queries, Redis commands, CQL, DuckDB SQL). Explain how queries differ from SQL.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Folie 2: SELECT & WHERE – Anatomie einer SPARQL-Query

---

### Kernpunkte

**PREFIX — Namespace-Abkürzung:**

---

## Folie 3: Query-Typen — SELECT · ASK · CONSTRUCT · DESCRIBE

**ASK**

- Einsatz: Validierung vor einer Verarbeitung, Assertions in Datenpipelines, „Existiert dieser Datenpunkt überhaupt?"

**CONSTRUCT**

- Einsatz: Daten aus mehreren Quellen in einheitliches Format überführen, Teilgraph exportieren, Regeln materialisieren, strukturierten Kontext für RAG-Pipelines aufbereiten
- Gibt RDF zurück, keine Tabelle

**Friend of a Friend** — ein standardisiertes RDF-Vokabular für Personen und soziale Netzwerke. W3C-spezifiziert, URI: `http://xmlns.com/foaf/0.1/`.

Typische Properties:

- `foaf:name` → Name einer Person
- `foaf:knows` → kennt eine andere Person
- `foaf:mbox` → E-Mail-Adresse
- `foaf:Person` → Klasse "Person"
- `foaf:memberOf` → Mitglied einer Organisation

**DESCRIBE** —

| | `DESCRIBE uni:Stuttgart` | `SELECT ?p ?o WHERE { uni:Stuttgart ?p ?o }` |
|---|---|---|
| **Rückgabeformat** | RDF-Graph | Tabelle (Variablenbindungen) |
| **Was zurückkommt** | Store-abhängig: kan auch eingehende Links, Blank Nodes, Metadaten enthalten | Nur *ausgehende* Kanten von Stuttgart |
| **Normiert?** | Nein — jeder Store entscheidet selbst | Ja, exakt definiert |


**AI-Relevanz:**

- CONSTRUCT: aufbereitete RDF-Graphen als Kontext für LLM-Antworten — jede Aussage auf konkrete Triples rückführbar → Explainability
- ASK: Konsistenz-Checks in automatisierten Wissensgraph-Pipelines

## Folie 5: FILTER · OPTIONAL · Property Paths


**FILTER:** - Kommt *nach* den Pattern-Bindungen

**OPTIONAL:**

- SQL LEFT JOIN: alle Zeilen der linken Seite, NULL wenn kein Match rechts
- Hintergrund — **Open World Assumption**: im RDF-Modell bedeutet ein fehlendes Triple „unbekannt", nicht „falsch". Das ist eine bewusste Design-Entscheidung

Closed World Assumption (SQL): Die Datenbank enthält alles Relevante. Was nicht drin steht, existiert nicht. Abfrage "Hat Max eine Email?" → kein Eintrag → Antwort: Nein.

Open World Assumption (RDF): Die Datenbank ist ein Ausschnitt des Weltwissens. Was nicht drin steht, ist unbekannt — nicht falsch. Abfrage "Hat Max eine Email?" → kein Triple gefunden → Antwort: Wir wissen es nicht.

Warum das eine bewusste Design-Entscheidung ist: RDF wurde für das Web entworfen. Im Web sind Informationen über eine Entität über viele verschiedene Server verteilt — Wikidata weiß andere Dinge über Stuttgart als DBpedia. Kein System hat das vollständige Weltwissen. Es wäre falsch zu sagen: "Stuttgart hat keine Einwohnerzahl" nur weil dieser Store sie nicht gespeichert hat.

Praktische Konsequenz: Das ist der Grund warum SPARQL OPTIONAL und FILTER NOT EXISTS so wichtig sind. In RDF kannst du nie sicher sein, ob etwas "nicht existiert" oder ob die Information einfach fehlt — deshalb musst du explizit nach Abwesenheit fragen, wenn du sie brauchst.

**Property Paths:**

```sparql
-- * : findet Student selbst UND alle Oberklassen (Person)
?x rdfs:subClassOf* uni:Student

-- + : findet NUR die Oberklassen (Person), NICHT Student selbst
?x rdfs:subClassOf+ uni:Student
```

```sparql
-- Ohne /: zwei separate Patterns
?person uni:studiesAt ?uni .
?uni uni:location ?city .

-- Mit /: ein einziger Property Path
?person uni:studiesAt/uni:location ?city .
```

---

## Folie 6: Inferenz

---

### Kernpunkte

**Das Setup** -  `uni:Student rdfs:subClassOf uni:Person`, ebenso für Professor und Staff

- Alice ist als `uni:Student` gespeichert — *nie* explizit als `uni:Person`

**Abgrenzung Traversal vs. Inferenz:**

- **Traversal (hier):** bewegt sich entlang *existierender* `subClassOf`-Kanten — echte gespeicherte Triples
- **Inferenz/Entailment (kommt in Architecture):** Store leitet *neue* Triples ab und materialisiert sie — `Alice a Person` existiert dann explizit im Store