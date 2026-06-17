# Important Todos:

Foliendesign:

- more AI related stuff hinzufügen? - Vinz
- Sorechtexte designen

Theorie:
- Entailment, equivalence and inconsistency wiederholen

Comparison: 
- Oxigraph (wie in der Demo): bietet Transaktionen, aber keine vollständige Isolation — concurrent writes können Konflikte erzeugen - bitte das genauer ausführen und wie ist es bei Jena fusenki? 
- im Sprechtext wird amazon neptune genannt als kg mit property graph, in der präsi ist das glaub teilweise als tripelstore aufgelistet. bitte überprüfe und verifzieren mit notebook lm



- Slides final wrapup:

  - Foliennummern oben links anpassen!
- nochmal andere Datenbanken im Vergleich analyiseren,Vorbereitung auf Fragen von Prof

  - Vergleich Property Graph: https://neo4j.com/blog/knowledge-graph/rdf-vs-property-graphs-knowledge-graphs/
  - Schwachstellen von unserem System
  - Selbstbeziehung möglich in TS?
  - Abgrenzung konkret zu Cypher
  - warum für oxigraph entschieden?

Die 1,0-Lücken (priorisiert)

1. AI-Bezug vorhanden, aber verstreut & ohne Höhepunkt — größter Hebel.
   Der report rahmt alles als „data modeling = cornerstone of AI engineering". Ihr habt gute Touches (CONSTRUCT als RAG-Kontext [1931], Architecture-AI-Folie [2526], federated [2290]). Aber es fehlt der eine starke Moment:

- Kein expliziter Triple Store vs. Vector DB für RAG — genau das schlägt §7 als Debatte vor.
- Kein Explainability/Halluzinations-Argument: Triples = nachvollziehbare Quelle vs. Blackbox-Embeddings. Das ist im AI-Kurs euer stärkstes „warum jetzt relevant".
  → Die geplante AI-Folie in Motivation sollte genau das setzen und als Synthese-Folie am Ende wiederkommen (GraphRAG, §11 nennt es als Extension).

2. Synthese / Cross-Model fehlt (Rubric „Reflection & synthesis" 10%, Woche 9).
   Comparison vergleicht nur SQL & Property Graph. Der Kurs will „how to combine models in AI pipelines". Eine Folie: Triple Store + Vector DB im selben RAG-Stack (Triples = Fakten/Explainability, Vektoren = Fuzzy-Retrieval). Das trennt 1,0 von 1,3.
3. Discussion-Slot (§6.9, 10 min) hat keine Folie.
   Quiz ≠ offene Diskussion. Eine Abschluss-Folie mit 2-3 Fragen („Wann KEIN Triple Store?", „Triple Store oder Vector DB für euer RAG?") schließt den Slot und liefert die Synthese aus Punkt 2 gleichzeitig.
4. Reflexion-Deliverable fehlt (Rubric 10%, §9.10).
   Keine reflection.md im Gruppenordner. 1-2 Seiten: Trade-offs, Verbindung zu anderen Modellen, future directions. Nach der Präsi nachreichbar — aber einplanen.

Mittel
5. Interactive Activity ist passiv. MC-Quiz erfüllt die 10%, ist aber rezeptiv. §7 bevorzugt hands-on „live query challenge" — Publikum schreibt/führt selbst eine SPARQL gegen euren laufenden Oxigraph (Umgebung habt ihr!). Schon eine Mini-Query („findet alle Studenten der TUM") hebt das von gut auf stark.

6. Demo-Q7 braucht Internet (Wikidata). Single Point of Failure live. Fallback-Screenshot bereithalten, vorher ansagen.
7. Timing-Risiko Conceptual: 13 Folien für 15 min. Named Graphs (2 Folien) ist prio-schwächer als der Inferenz-Kern — erster Straffungskandidat bei Zeitnot.

Kurz: inhaltlich/handwerklich seid ihr auf 1,0-Niveau. Was fehlt, ist fast ausschließlich die AI-Klammer (Punkte 1-3) plus zwei Deliverable-Formalitäten (4, 5). Punkte 2+3+1 lassen sich in einer einzigen Abschluss/Synthese-Folie bündeln — bester ROI.

# Ideen

- wie gehts eigentlich weiter nach triplestores, ist das das Ende der Fahnenstange
- Forward and Backward chaining bei Architecture?

# Gedanken

## Relational DB

**Overall**
Kernfragen pro Kapitel definieren?

**Grundlagen**
Abgrenzung TS zu graph Datenbanken (Nachteil zu Property graph aufgreifen von Folie damals)
Schwachstellen von unserem System

**Datenmodell**
Datenmodell logische Sicht vs physische Sicht
Konkreter Durchlauf modellieren
Datenmodell am Beispiel von Oxigraph zeigen / live demo kombinieren?

**Queries**
Abfragemodell im Vergleich zu SQL modellieren
Selbstbeziehung möglich in TS?
Abgrenzung Cypher zu SPARQL
Arten von Graphenabfragen

**Architektur**
Durchgänginge Verknüpfung von Demo und Präsi - Beispiel veranschaulichen an Demo
Vorstellung von Programmen

**Vergleich**

## Data Lakes

wie habt ihr die folien gestaltet? mega desig!
sehr gute Präsi - wie seid ihr vorgegangen, wie lange habt ihr gebraucht?

**Motivation**
Bezug final zu ML / AI . warum wichtig? Grundlage für was? Verwendung?

---

## Key Value stores

**Motivation**
Geschichte mit Entstehung von DB als auch Tool welches später verwendet wird

**Real World Example**
Super interessant zum einbinden. Vielleicht au nen Real world / experimental example, wo AI unsere Datenbank nutzt oder es halt da verbindungen gibt

### Fragen

Property Graph:
vs. RDF: Metadaten dynamisch ergänzbar?