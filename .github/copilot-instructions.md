# Copilot Instructions For This Repository

## Scope And Priority
- This repository contains multiple seminar groups, but for Roman only Group 2 is relevant.
- Focus all analysis, writing, and edits on these areas unless the user explicitly asks otherwise:
  - groups/group2-triple-stores/
  - README.md
  - report.md
  - CLAUDE.md
  - next task_Romi.txt
- Ignore unrelated group folders by default:
  - groups/group1-graph-databases/ through groups/group7-data-lakes/ (except group2)
  - groups/schedule.md

## Working Language And Style
- Default to German for explanations and slide text.
- Keep technical terms in their standard form where useful (RDF, SPARQL, Reasoning, Property Path, Linked Data).
- Be concise, but didactically precise. Explain why, not only what.

## Source-Of-Truth Order
When files disagree, use this precedence:
1. Runtime truth (actual runnable demo artifacts):
   - groups/group2-triple-stores/demo/files/triplestore-demo/data/universitaeten.ttl
   - groups/group2-triple-stores/demo/files/triplestore-demo/queries/*.sparql
   - groups/group2-triple-stores/demo/files/triplestore-demo/run_demo.sh
2. Priority and depth planning:
   - groups/group2-triple-stores/slides/Priorisierte Gliederung Vinz.md
3. Content baseline and decisions:
   - groups/group2-triple-stores/slides/final strucutre.md
4. Demo narrative and presenter notes:
   - groups/group2-triple-stores/demo/files/demo_README.md
5. Repository navigation constraints:
   - CLAUDE.md

## Hard Constraints For Group-2 Content
- Maintain the central red thread:
  - Wissen vernetzen: von isolierten Fakten zur globalen Wissensstruktur.
- Always keep ontology and inferencing as a core differentiator. Do not present RDF as only Graph DB + SPARQL.
- Keep the core aha moment intact:
  - Query 4 (without inferencing): 0 results
  - Query 5 (with rdfs:subClassOf*): 7 results
- If discussing Query 7 (federated query), frame it as Linked Data integration via explicit identity linking (owl:sameAs), not as a hardcoded shortcut.
- Keep the hybrid URI strategy (local uni: resources plus targeted links to global URIs). Do not rewrite the whole dataset to DBpedia URIs unless explicitly requested.

## Chapter-Level Guidance (Presentation)
- Motivation (10 min):
  - Relational pain points (rigid schema, semantic blindness, join complexity)
  - RDF value proposition
  - AI relevance (RAG, semantic search, explainability)
- Conceptual Model (15 min):
  - RDF triples, graph model, URIs, literals, blank nodes
  - Keep model concepts clear and example-driven
- Data Structure / Semantics split:
  - Semantics, ontology, and inferencing must be clearly taught and not skipped.
  - Physical indexing details (SPO/POS/etc.) belong in architecture/performance discussion unless user explicitly wants them in data structure.
- Query Model (15 min):
  - SPARQL pattern matching, SELECT/WHERE, FILTER, OPTIONAL, aggregation, federated queries
  - Always explain SPARQL vs SQL mental model
- Architecture (15 min):
  - Triple store components, SPARQL endpoint, reasoning modes, storage/indexing model
  - Mention single-node vs distributed briefly unless deep dive requested
- Comparison (10 min):
  - Explicitly distinguish RDF triple stores, property graph DBs, and relational systems

## Demo Guardrails (Must Preserve)
- Default demo stack: Oxigraph in Docker on port 7878.
- Data load must target default graph for the prepared queries:
  - Use PUT /store?default
  - Avoid plain POST /store for this demo flow
- Keep Query 2 robust across Windows shell/editor setups:
  - Use Baden-W\u00FCrttemberg in SPARQL where encoding issues may occur
- Query 7 is optional and internet-dependent:
  - Always mention possible timeout/failure and keep a screenshot fallback
- For script/tooling suggestions on Windows + Git Bash:
  - Consider python command portability (py -3, python3, python)

## Editing Conventions
- Prefer minimal changes in existing files.
- Preserve established filenames and structure, including legacy naming (for example final strucutre.md) unless the user explicitly asks to rename.
- Do not introduce changes in unrelated groups.

## Expected Output Quality
- For conceptual answers, always include:
  - clear distinction to SQL and property graphs
  - one concrete example from the university demo domain
  - one practical implication for AI workflows
- For slide support, structure by priority levels (Prio 1 first, then Prio 2/3 as time permits).
- For technical troubleshooting, first validate endpoint, graph loading mode, and query encoding before proposing major refactors.
