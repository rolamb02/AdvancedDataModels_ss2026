
---

# 🧱 Gesamtstruktur (mit Zeitmapping)

| Block | Inhalt                | Zeit   |
| ----- | --------------------- | ------ |
| 1     | Motivation            | 10 min |
| 2     | RDF Core Model        | 20 min |
| 3     | Semantik & Ontologien | 25 min |
| 4     | SPARQL                | 25 min |
| 5     | Architektur           | 15 min |
| 6     | Vergleich             | 10 min |
| 7     | Demo                  | 30 min |
| 8     | Interaktiv            | 20 min |
| 9     | Diskussion            | 10 min |

---

# 📊 Folienstruktur (konkret)

## 🔹 1. Motivation (3–4 Slides)

**Slide 1 — Titel**

* Triple Stores & RDF
* Kontext: AI / Knowledge Graphs / RAG

**Slide 2 — Problem**

* Relationale DB:

  * starres Schema
  * semantisch „blind“
* Beispiel:

  * gleiche Entität, verschiedene Namen

**Slide 3 — Pain Point**

* Joins vs. Beziehungen
* Keine Inferenz möglich

**Slide 4 — Zielbild**

* „Machine-readable knowledge“
* Übergang zu RDF

---

## 🔹 2. RDF Core Model (6–7 Slides)

**Slide 5 — Grundidee**

* Triple = Aussage
* (S, P, O)

**Slide 6 — Graph-Interpretation**

* RDF = gerichteter Graph

**Slide 7 — URIs**

* globale Identität
* Linked Data Prinzip

**Slide 8 — Literale vs Ressourcen**

* Werte vs Entitäten

**Slide 9 — Named Graphs (optional)**

* Kontextualisierung

**Slide 10 — Mini-Beispiel**

* Universitäten / Personen

👉 Wichtig:
→ durchgehendes Beispiel etablieren

---

## 🔹 3. Semantik & Ontologien (7–8 Slides)

**Slide 11 — Warum Semantik?**

* Daten vs Wissen

**Slide 12 — RDF Schema (RDFS)**

* Klassen
* Subclass
* Domain / Range

**Slide 13 — Beispiel**

* Professor ⊆ Person

**Slide 14 — Inferenz**

* explizit vs implizit

**Slide 15 — OWL (nur Überblick!)**

* expressive Regeln

**Slide 16 — Reasoning Demo (konzeptionell)**

* neue Fakten entstehen

**Slide 17 — Grenzen**

* Performance
* Komplexität

👉 Kritischer Punkt:
→ hier entsteht der „Aha-Moment“

---

## 🔹 4. SPARQL (6–7 Slides)

**Slide 18 — Query Paradigma**

* Pattern Matching statt Tabellen

**Slide 19 — Basic Query**

```sparql
SELECT ?x WHERE {
  ?x rdf:type University .
}
```

**Slide 20 — Joins als Graph Patterns**

* mehrere Triples kombinieren

**Slide 21 — FILTER / OPTIONAL**

* expressive Queries

**Slide 22 — Aggregationen**

* COUNT etc.

**Slide 23 — Federated Queries**

* mehrere Datenquellen

👉 Fokus:
→ Unterschied zu SQL klar machen

---

## 🔹 5. Architektur (3–4 Slides)

**Slide 24 — Triple Store intern**

* Indexe (SPO, POS etc.)
* Storage

**Slide 25 — Beispielsysteme**

* Apache Jena Fuseki
* GraphDB

**Slide 26 — Reasoning Engine**

* Materialization vs Query-time

---

## 🔹 6. Vergleich (2–3 Slides)

**Slide 27 — RDF vs Graph DB**

| Feature  | RDF    | Property Graph |
| -------- | ------ | -------------- |
| Semantik | stark  | schwach        |
| Standard | hoch   | gering         |
| Query    | SPARQL | Cypher         |

**Slide 28 — Wann nutzen?**

* RDF:

  * Knowledge Graphs
  * Interoperabilität
* Nicht für:

  * High-performance traversal

---

## 🔹 7. Demo (separate Slides + Live)

**Slide 29 — Setup**

* Jena Fuseki

**Slide 30 — Dataset**

* Mini Ontology (Universitäten)

**Live:**

* Daten laden
* SPARQL Queries
* optional: Reasoning aktivieren

---

## 🔹 8. Interaktive Übung (2 Slides)

**Slide 31 — Aufgabe**

* „Finde alle Professoren in Deutschland“

**Slide 32 — Erweiterung**

* mit Inferenz:

  * Professor → Person

---

## 🔹 9. Diskussion (1–2 Slides)

**Slide 33 — Leitfragen**

* Wann ist RDF Overkill?
* RDF vs Vector DB für RAG?

---

## 🔹 10. Backup / Advanced (optional)

**Slide 34 — RDF in AI**

* Knowledge Graph RAG

**Slide 35 — Kritik**

* Komplexität
* geringe Adoption außerhalb Semantic Web

---

# 🧠 Didaktische Bewertung (kritisch)

### Was gut funktioniert:

* klare Progression:
  **Problem → Modell → Semantik → Query → Praxis**
* durchgehendes Beispiel verhindert Kontextwechsel

### Risiko:

* Ontologien zu abstrakt
* SPARQL zu syntaktisch

👉 Gegenmaßnahme:

* immer zurück zum Beispiel springen

---

# ⚙️ Nächster sinnvoller Schritt

Wenn du weitermachen willst:

1. **Konkretes Demo-Setup (Docker + Dataset)**
2. **1:1 Slide Content (inkl. Grafiken/Diagrammen)**
3. **Interaktive Aufgabe sauber ausarbeiten (mit Lösung)**

Sag einfach, was du brauchst.

---

Verstanden. Ich optimiere deine Struktur **innerhalb der vorgegebenen Requirements**, aber schärfe gezielt die Punkte, die typischerweise bewertet werden:
👉 **Semantik klar sichtbar**,
👉 **AI-Bezug durchgezogen**,
👉 **Abgrenzung sauber**,
👉 **Interaktiv konkret**.

---

# 🧱 Überarbeitete Folienstruktur (bewertungsoptimiert)

## ⏱️ Zeit bleibt exakt im Rahmen (~140 min Content)

---

# 🔹 1. Motivation (10 min) — *unverändert, aber geschärft*

**Slides (3–4):**

* Problem: Relationale Modelle können **Bedeutung nicht modellieren**
* Beispiel: gleiche Entität, verschiedene Kontexte
* AI-Brücke:

  * Knowledge Graphs
  * RAG mit strukturiertem Wissen

👉 **Explizit formulieren:**

> „Wir brauchen nicht nur Daten — wir brauchen *Bedeutung + Kontext*“

---

# 🔹 2. RDF Core Model (15 min)

**Slides (5–7):**

* Triple als atomare Aussage
* Graph-Repräsentation
* URIs (globale Identität)
* Literale vs Ressourcen

👉 Wichtig:

* durchgehendes Beispiel (z. B. Uni + Personen)

---

# 🔹 3. Semantics & Ontologies (15 min) ⚠️ *NEU KLARER BLOCK*

**Slides (6–7):**

* RDFS:

  * Klassen
  * Subclass
  * Domain/Range
* Inferenz:

  * explizit vs implizit
* Mini-Beispiel:

  * Professor ⊆ Person → automatische Ableitung

👉 **Didaktischer Kern:**

* Das ist der Unterschied zu:

  * Graph DB
  * SQL

👉 **AI-Verbindung:**

* strukturierte Wissensrepräsentation
* Grundlage für Knowledge Graph Reasoning

---

# 🔹 4. Data Structure (15 min)

**Slides (3–4):**

* Triple-Indizes (SPO, POS, …)
* Speicherung als Graph / Tabellenintern
* Named Graphs (optional)

👉 Wichtig:

* Brücke:

  * „Warum ist das trotz Einfachheit performant?“

---

# 🔹 5. Query Model – SPARQL (15 min)

**Slides (6–7):**

* Pattern Matching
* Basic Queries
* JOIN = mehrere Triple Patterns
* OPTIONAL / FILTER

👉 **Vergleich zu SQL explizit:**

* deklarativ vs pattern-based

👉 **AI-Bezug:**

* strukturierte Retrieval-Schicht (z. B. KG-RAG)

---

# 🔹 6. Architecture Overview (15 min)

**Slides (3–4):**

* Triple Store Aufbau
* Reasoning:

  * Materialization vs Query-Time
* Tools:

  * Jena Fuseki
  * GraphDB

👉 Kritischer Punkt:

* Reasoning kostet Performance

---

# 🔹 7. Comparison to Relational & Graph DB (10 min) ⚠️ *geschärft*

**Slides (2–3):**

### Tabelle (wichtig):

| Feature          | RDF      | Graph DB | Relational |
| ---------------- | -------- | -------- | ---------- |
| Semantik         | hoch     | gering   | gering     |
| Standardisierung | hoch     | mittel   | hoch       |
| Traversal        | mittel   | stark    | schwach    |
| Schema           | flexibel | flexibel | starr      |

👉 **Explizite Aussage:**

* RDF ≠ Graph DB

---

# 🔹 8. Practical Demo (30 min)

**Struktur:**

* Setup zeigen (kurz)
* Dataset (Mini-Ontologie!)
* Queries:

  * einfache Abfrage
  * komplexe Abfrage
* **Reasoning aktivieren → Unterschied zeigen**

👉 Bewertungskriterium:

* „zeigt echten Mehrwert des Modells“

---

# 🔹 9. Interactive Activity (20 min) ⚠️ *jetzt konkret*

## Aufgabe (klar definiert):

### Teil 1 (ohne Inferenz):

> Finde alle Personen in Deutschland

→ funktioniert nicht vollständig

### Teil 2 (mit Inferenz):

> Professor → Person

→ Ergebnis erweitert sich

👉 Ziel:

* Studierende sehen **konkreten Nutzen von Semantik**

---

## Alternative (falls Zeit):

* Mini-Schema entwerfen:

  * „Linked Knowledge für Uni-System“

---

# 🔹 10. Discussion (10 min)

**Leitfragen:**

* Wann ist RDF Overkill?
* RDF vs Vector DB für RAG?
* Warum geringe Industrie-Adoption?

👉 Erwartung:

* kritische Reflexion (wird bewertet!)

---

# 🧠 Was wurde konkret verbessert?

## 1. Semantik sichtbar gemacht

→ eigener Block (entscheidend für Bewertung)

## 2. AI-Bezug durchgezogen

→ nicht nur Motivation, sondern:

* Query
* Semantik
* Diskussion

## 3. Interaktiv konkretisiert

→ klare Aufgabe + Lernziel

## 4. Vergleich geschärft

→ explizit RDF vs Graph DB

---

# ⚖️ Realistische Bewertung

| Bereich               | Einschätzung      |
| --------------------- | ----------------- |
| Anforderungen erfüllt | ✅ sicher          |
| Tiefe                 | ✅ gut             |
| Didaktik              | ✅ gut             |
| Differenzierung       | ✅ deutlich besser |

---

# ❗ Kritischer Restpunkt

Ein Risiko bleibt:

* **Ontologien zu oberflächlich erklären**

👉 Wenn das passiert:
→ wirkt alles wie „Graph DB + SPARQL“

---

# 👉 Nächster sinnvoller Schritt

Wenn du weiter optimieren willst:

* konkrete **Demo inkl. Dataset + Queries**
* oder **2–3 starke Visual Slides (Semantik erklären)**

Das sind die größten Hebel für die Note.

