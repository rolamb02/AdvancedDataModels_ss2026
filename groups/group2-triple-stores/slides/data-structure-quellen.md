# Data Structure – Quellenarbeit und Claim-Mapping

## Ziel dieser Datei
Diese Datei trennt bewusst Inhalte und Quellenlogik:
- `Slide Structure.md` bleibt praesentationstauglich.
- Hier dokumentieren wir, welche Aussage auf welcher Quelle basiert.

Stand: 2026-04-17
Methode: Quellenabgleich ueber NotebookLM MCP (Session zur physischen Speicherung) + Abgleich mit Repo-Stand.

## Arbeitsprinzip (konkret)
1. Pro Folienaussage genau einen Claim formulieren.
2. Pro Claim mindestens eine Primaerquelle hinterlegen.
3. Interne Planungsdokumente nur als Strukturquelle nutzen, nicht als Fachbeleg.
4. Wenn eine oft genannte Quelle nicht im Notebook enthalten ist, explizit als "nicht im Korpus" markieren.

## Claim-to-Source Mapping (Physische Speicherung)
| Claim-ID | Ziel-Folie | Aussage | Primaerquelle | Ergaenzende Quelle | Status |
|---|---|---|---|---|---|
| C1 | Folie 3 | RDF speichert Fakten als Triples (S-P-O), graphbasiert statt tabellarisch | [Q1] | [Q2] | verifiziert |
| C2 | Folie 3 | Triple Stores arbeiten physisch effizient mit ID-basierten Repräsentationen (Dictionary/Surrogat-Idee) | [Q4] | [Q3] | verifiziert |
| C3 | Folie 4 | Mehrere Index-Permutationen sind fuer unterschiedliche Query-Muster notwendig (SPO, POS, OSP, ...) | [Q3] | [Q5] | verifiziert |
| C4 | Folie 4 | Index-Mehrfachhaltung ist ein Speicher-Performance-Trade-off | [Q3] | [Q4] | verifiziert |
| C5 | Folie 5 | URIs/IRIs sichern globale Eindeutigkeit und ermoeglichen Linked-Data-Integration | [Q1] | [Q2] | verifiziert |
| C6 | Folie 5 (optional) | Named Graphs als Kontext/Provenienz-Ebene | [Q2] | [Q6] | verifiziert |

## Quellenverzeichnis
[Q1] W3C. RDF 1.1 Concepts and Abstract Syntax (2014). https://www.w3.org/TR/2014/REC-rdf11-concepts-20140225/

[Q2] W3C. RDF 1.1 Primer (2014). https://www.w3.org/TR/rdf11-primer/

[Q3] Gilbert, Elissa. Triplestores 101: Storing Data for Efficient Inferencing (Dataversity, 2016). https://www.dataversity.net/articles/triplestores-101-storing-data-efficient-inferencing/

[Q4] Meier, Andreas; Kaufmann, Michael. SQL- & NoSQL-Datenbanken. Springer, 2023. https://doi.org/10.1007/978-3-662-67092-7

[Q5] Interne Inhaltsgrundlage: `slides/final strucutre.md` (Architektur-Teil zu Index-Permutationen, fuer Didaktik/Tiefensteuerung).

[Q6] Interne Priorisierung: `slides/Priorisierte Gliederung Vinz.md` (Named Graphs als Prio-3-Erweiterung).

## Transparent dokumentierte Luecke
Hexastore und RDF-3X wurden in der NotebookLM-Abfrage als nicht explizit im aktuellen Quellenkorpus enthalten gemeldet.

Konsequenz fuer die Vorlesung:
- Entweder diese Begriffe weglassen.
- Oder als externe Zusatzliteratur markieren (nicht als "aus Korpus belegt" ausgeben).

## Nutzung in den Slides (empfohlen)
- Auf Inhaltsfolien nur kurze Marker wie `[Q1]`, `[Q3]` an den Kernclaims.
- Letzte Folie des Data-Structure-Blocks: "Quellen" mit 4-6 Eintraegen aus [Q1]-[Q4].
- Diese Datei als internes Arbeitsdokument im Repo behalten fuer Nachvollziehbarkeit und schnelle Updates.

## Ergaenzung 2026-04-17: Reasoning-Aha-Moment (Demo Query 4/5)
- Claim R1: Ohne inferenzfaehige Auswertung liefert eine Query auf Oberklasse (`uni:Person`) 0 Treffer, wenn Instanzen nur in Unterklassen typisiert sind.
- Claim R2: Mit hierarchischer Auswertung ueber `rdfs:subClassOf*` werden Instanzen aus Unterklassen korrekt als Treffer der Oberklasse zurueckgegeben.
- Didaktische Pointe fuer die Vorlesung: Ontologie + Inferenz unterscheiden Triple Stores grundlegend von "nur Graph + Query".

Beleglage:
- [Q1] RDF 1.1 Concepts (Semantikmodell, Klassen/Typisierung).
- [Q2] RDF 1.1 Primer (RDFS-Klassenhierarchien und Ableitbarkeit).
- [Q3] Dataversity "Efficient Inferencing" (praktische Relevanz von Inferencing im Triplestore).

## Ergaenzung 2026-04-17: Query Model - Claim-Mapping
Ziel: Die Query-Model-Inhalte (Slot 4) sind analog zu Data Structure belegbar und mit Runtime-Truth konsistent.

| Claim-ID | Ziel-Slot | Aussage | Primaerquelle | Ergaenzende Quelle | Status |
|---|---|---|---|---|---|
| C-QM-01 | Query Model | SPARQL 1.1 ist W3C-Standard fuer RDF-Abfragen. | [Q7] | [Q9] | verifiziert |
| C-QM-02 | Query Model | SPARQL basiert auf Graph Pattern Matching mit Triple-Patterns und Variablen. | [Q8] | [Q9] | verifiziert |
| C-QM-03 | Query Model | Kernsyntax fuer Einstieg: PREFIX + SELECT + WHERE. | [Q8] | [Q9] | verifiziert |
| C-QM-04 | Query Model | FILTER schraenkt Bindungen ein, OPTIONAL bildet optionale Fakten (LEFT-JOIN-Analogie). | [Q8] | [Q9] | verifiziert |
| C-QM-05 | Query Model | Aggregationen (COUNT/GROUP BY/ORDER BY) sind in SPARQL verfuegbar. | [Q8] | [Q9] | verifiziert |
| C-QM-06 | Query Model | Property Paths (`*`, `+`, `|`, `/`) erlauben Pfad- und Hierarchieabfragen. | [Q8] | [Q11] | verifiziert |
| C-QM-07 | Query Model | Federated Query erfolgt ueber `SERVICE` gegen externe SPARQL-Endpunkte. | [Q10] | [Q11] | verifiziert |
| C-QM-08 | Query Model | Query-Typen neben SELECT: CONSTRUCT, ASK, DESCRIBE. | [Q8] | [Q9] | verifiziert |
| C-QM-09 | Query Model | Entailment-Regimes steuern, ob und wie RDFS/OWL-Schlussfolgerungen Query-Ergebnisse erweitern. | [Q12] | [Q7] | verifiziert |
| C-QM-10 | Query Model | Das Demo-Aha (Q4=0 vs Q5=7) folgt aus `rdfs:subClassOf*` ueber die Klassenhierarchie. | [Q11] | [Q9] | verifiziert |
| C-QM-11 | Query Model | Ergebnisformate fuer SELECT: JSON, CSV, TSV (u. a.). | [Q7] | [Q8] | verifiziert |
| C-QM-12 | Query Model | Query 7 integriert Linked Data ueber explizites Identity-Linking (`owl:sameAs`), nicht ueber Hardcoding allein. | [Q11] | [Q9] | verifiziert |

### Quellen (Query Model)
[Q7] W3C. SPARQL 1.1 Overview. https://www.w3.org/TR/sparql11-overview/

[Q8] W3C. SPARQL 1.1 Query Language. https://www.w3.org/TR/sparql11-query/

[Q9] Interne Inhaltsgrundlage: `slides/final strucutre.md` (Slot 4 Query Model, SQL-Abgrenzung, Feature-Set).

[Q10] W3C. SPARQL 1.1 Federated Query. https://www.w3.org/TR/sparql11-federated-query/

[Q11] Runtime Truth (Demo-Artefakte):
- `demo/files/triplestore-demo/data/universitaeten.ttl`
- `demo/files/triplestore-demo/queries/01_alle_universitaeten.sparql`
- `demo/files/triplestore-demo/queries/02_unis_in_bw.sparql`
- `demo/files/triplestore-demo/queries/03_studenten_uni_stuttgart.sparql`
- `demo/files/triplestore-demo/queries/04_personen_OHNE_inferenz.sparql`
- `demo/files/triplestore-demo/queries/05_personen_MIT_inferenz.sparql`
- `demo/files/triplestore-demo/queries/06_count_pro_uni.sparql`
- `demo/files/triplestore-demo/queries/07_federated_dbpedia.sparql`

[Q12] W3C. SPARQL 1.1 Entailment Regimes. https://www.w3.org/TR/sparql11-entailment/
