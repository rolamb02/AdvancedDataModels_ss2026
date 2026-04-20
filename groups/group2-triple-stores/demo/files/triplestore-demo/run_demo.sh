#!/bin/bash
# =============================================================
# TRIPLESTORE DEMO – Ausführungs-Script
# Gruppe 2: Semantic Triple Stores / RDF + SPARQL
#
# Voraussetzung: Oxigraph läuft (docker-compose up -d)
# Benutzung:     bash run_demo.sh
# =============================================================

ENDPOINT="${OXIGRAPH_ENDPOINT:-http://localhost:7878}"
LAN_HOST="${OXIGRAPH_LAN_HOST:-}"
QUERY_DIR="./queries"
DATA_DIR="./data"

# Toggle for an explicit "what happens in the background" explanation block.
# Set to false if you want to skip this extra explanation during the live demo.
SHOW_BACKGROUND_EXPLANATION=true

# Python command detection for cross-platform compatibility (Linux/macOS/Git Bash on Windows)
can_run_python() {
    "$@" -c "import json" >/dev/null 2>&1
}

PYTHON_CMD=()
if command -v py >/dev/null 2>&1 && can_run_python py -3; then
    PYTHON_CMD=(py -3)
elif command -v python3 >/dev/null 2>&1 && can_run_python python3; then
    PYTHON_CMD=(python3)
elif command -v python >/dev/null 2>&1 && can_run_python python; then
    PYTHON_CMD=(python)
else
    echo ""
    echo "Fehler: Kein nutzbarer Python-Interpreter gefunden (py/python3/python)."
    echo "Installiere Python oder aktiviere die virtuelle Umgebung, in der Python verfügbar ist."
    exit 1
fi

# Farben für Terminal-Output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_access_hints() {
    echo -e "${BLUE}[INFO] Access URLs${NC}"
    echo "  Lokal (Presenter): $ENDPOINT"
    if [ -n "$LAN_HOST" ]; then
        echo "  LAN (Studierende): http://$LAN_HOST:7878"
    else
        echo "  LAN (Studierende): setze OXIGRAPH_LAN_HOST=<DEINE_IPV4>"
        echo "  Beispiel: OXIGRAPH_LAN_HOST=192.168.178.35 bash run_demo.sh"
    fi
    echo ""
}

# Hilfsfunktion: auf Enter warten
pause() {
    echo ""
    echo -e "${YELLOW}▶ Enter drücken für den nächsten Schritt...${NC}"
    read -r
    echo ""
}

# Hintergrund-Abschnitt: erklärt den technischen Ablauf der Demo in Klartext.
# Diese Ausgabe ist didaktisch gedacht und macht sichtbar, welche HTTP-Kommunikation
# das Script intern ausführt.
show_background_explanation() {
    echo -e "${BLUE}[HINTERGRUND] Was läuft technisch im Hintergrund?${NC}"
    echo ""
    echo "  1) SCHRITT 2 (Daten laden):"
    echo "     - HTTP PUT auf $ENDPOINT/store?default"
    echo "     - Content-Type: text/turtle"
    echo "     - Body: data/universitaeten.ttl"
    echo ""
    echo "  2) SCHRITT 3-8 (lokale Queries):"
    echo "     - Query-Datei wird eingelesen"
    echo "     - Kommentarzeilen (# ...) werden entfernt"
    echo "     - HTTP POST auf $ENDPOINT/query"
    echo "     - Content-Type: application/sparql-query"
    echo ""
    echo "  3) Ergebnisaufbereitung im Terminal:"
    echo "     - Oxigraph liefert SPARQL-JSON"
    echo "     - Ein kurzes Python-Snippet formatiert die Ausgabe lesbar"
    echo ""
    echo "  4) SCHRITT 9 (Federated Query):"
    echo "     - Lokaler Oxigraph sendet SERVICE-Teil an https://dbpedia.org/sparql"
    echo "     - Lokale und externe Ergebnisse werden zusammengeführt"
    echo ""
    echo "  5) Wichtige Demo-Faktoren:"
    echo "     - Internet nur für SCHRITT 9 erforderlich"
    echo "     - Schritte 1-8 funktionieren vollständig lokal"
    echo ""
}

# Hilfsfunktion: SPARQL-Query ausführen und JSON formatieren
run_query() {
    local file=$1
    local query
    # Remove comment lines before sending to avoid shell/encoding edge cases
    # in environments where special characters in comments are problematic.
    query=$(sed '/^[[:space:]]*#/d' "$file")

    # Send raw SPARQL via POST. This is more robust than URL query parameters
    # for longer queries and special characters.
    curl -s "$ENDPOINT/query" \
        -H "Content-Type: application/sparql-query; charset=utf-8" \
        -H "Accept: application/sparql-results+json" \
        --data-binary "$query" \
        | "${PYTHON_CMD[@]}" -c "
import sys, json
data = json.load(sys.stdin)
vars = data['head']['vars']
bindings = data['results']['bindings']
print(f'  Spalten: {vars}')
print(f'  Ergebnisse: {len(bindings)}')
print()
for b in bindings:
    row = []
    for v in vars:
        val = b.get(v, {}).get('value', '-')
        # URI kürzen für bessere Lesbarkeit
        if val.startswith('http://example.org/uni/'):
            val = 'uni:' + val[len('http://example.org/uni/'):]
        elif val.startswith('http://www.w3.org/'):
            val = 'rdfs:...'
        row.append(f'{v}={val}')
    print('  → ' + ' | '.join(row))
"
}

# =============================================================
echo ""
echo -e "${BOLD}=============================================================${NC}"
echo -e "${BOLD}  TRIPLESTORE DEMO – RDF + SPARQL${NC}"
echo -e "${BOLD}  Gruppe 2 | Universität Stuttgart${NC}"
echo -e "${BOLD}=============================================================${NC}"
echo ""
print_access_hints

# =============================================================
echo -e "${BLUE}[SCHRITT 1] Verbindung zu Oxigraph prüfen${NC}"
# =============================================================
# Lightweight health check: returns HTTP 200 if query endpoint is ready.
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$ENDPOINT/query?query=SELECT+%2A+WHERE+%7B%7D+LIMIT+1")
if [ "$STATUS" = "200" ]; then
    echo -e "  ${GREEN}✓ Oxigraph läuft auf $ENDPOINT${NC}"
else
    echo -e "  ${RED}✗ Oxigraph nicht erreichbar. Bitte zuerst starten:${NC}"
    echo -e "  ${YELLOW}  docker-compose up -d${NC}"
    exit 1
fi
pause

# =============================================================
echo -e "${BLUE}[SCHRITT 2] Daten laden${NC}"
# =============================================================
echo "  Lade universitaeten.ttl in den Triplestore..."
# Put data explicitly into the default graph so all demo queries work without
# GRAPH clauses.
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X PUT "$ENDPOINT/store?default" \
    -H "Content-Type: text/turtle" \
    --data-binary @"$DATA_DIR/universitaeten.ttl")

# Treat all 2xx responses as success (e.g., 200 OK, 201 Created, 204 No Content)
if [[ "$HTTP_CODE" =~ ^2[0-9][0-9]$ ]]; then
    echo -e "  ${GREEN}✓ Daten erfolgreich geladen (HTTP $HTTP_CODE)${NC}"
    echo -e "  ${YELLOW}→ Endpoint: $ENDPOINT${NC}"
    echo -e "  ${YELLOW}→ Daten: $DATA_DIR/universitaeten.ttl${NC}"
    echo -e "  response: $HTTP_CODE${NC}"
else
    echo -e "  ${RED}✗ Fehler beim Laden (HTTP $HTTP_CODE)${NC}"
    exit 1
fi
echo ""
echo "  Was wurde geladen?"
echo "  • 1 Ontologie (Klassen-Hierarchie: Person → AcademicPerson → Professor/Student)"
echo "  • 4 Städte (Stuttgart, Karlsruhe, München, Berlin)"
echo "  • 4 Universitäten (UniStuttgart, KIT, TUM, FU Berlin)"
echo "  • 3 Professoren + 4 Studenten"
echo ""
echo -e "  ${YELLOW}→ Web-UI: $ENDPOINT (SPARQL Editor direkt im Browser)${NC}"
pause

# Optional didactic block that explains the internal communication flow.
if [ "$SHOW_BACKGROUND_EXPLANATION" = true ]; then
    show_background_explanation
    pause
fi

# =============================================================
echo -e "${BLUE}[SCHRITT 3] Query 1 – Alle Universitäten${NC}"
echo -e "${BOLD}Zeigt: PREFIX, SELECT, WHERE, einfache Variable${NC}"
# =============================================================
echo ""
cat "$QUERY_DIR/01_alle_universitaeten.sparql" | grep -v "^#" | sed 's/^/  /'
echo ""
echo -e "${GREEN}Ergebnis:${NC}"
run_query "$QUERY_DIR/01_alle_universitaeten.sparql"
pause

# =============================================================
echo -e "${BLUE}[SCHRITT 4] Query 2 – Unis in Baden-Württemberg${NC}"
echo -e "${BOLD}Zeigt: Mehrere Triple-Muster kombinieren (kein JOIN-Keyword nötig!)${NC}"
# =============================================================
echo ""
cat "$QUERY_DIR/02_unis_in_bw.sparql" | grep -v "^#" | sed 's/^/  /'
echo ""
echo -e "${GREEN}Ergebnis:${NC}"
run_query "$QUERY_DIR/02_unis_in_bw.sparql"
pause

# =============================================================
echo -e "${BLUE}[SCHRITT 5] Query 3 – Studenten an der Uni Stuttgart${NC}"
echo -e "${BOLD}Zeigt: Konkreter URI als Filter + warum der Variablenname egal ist${NC}"
# =============================================================
echo ""
cat "$QUERY_DIR/03_studenten_uni_stuttgart.sparql" | grep -v "^#" | sed 's/^/  /'
echo ""
echo -e "${GREEN}Ergebnis:${NC}"
run_query "$QUERY_DIR/03_studenten_uni_stuttgart.sparql"
pause

# =============================================================
echo -e "${BLUE}[SCHRITT 6] Query 4 – OHNE Inferencing: Alle Personen${NC}"
echo -e "${BOLD}!!! AHA-MOMENT VORBEREITUNG: Was kommt raus? ${NC}"
# =============================================================
echo ""
echo "  Frage ans Publikum: Wie viele Ergebnisse erwartet ihr?"
echo "  (7 Personen im Datensatz: 3 Professoren + 4 Studenten)"
echo ""
cat "$QUERY_DIR/04_personen_OHNE_inferenz.sparql" | grep -v "^#" | sed 's/^/  /'
echo ""
echo -e "${GREEN}Ergebnis:${NC}"
run_query "$QUERY_DIR/04_personen_OHNE_inferenz.sparql"
echo ""
echo -e "  ${YELLOW}→ 0 Ergebnisse! Niemand ist explizit als uni:Person eingetragen.${NC}"
echo -e "  ${YELLOW}→ Der Store findet genau das, was explizit drin steht – nicht mehr.${NC}"
pause

# =============================================================
echo -e "${BLUE}[SCHRITT 7] Query 5 – MIT Inferencing: Alle Personen${NC}"
echo -e "${BOLD}!!! AHA-MOMENT: rdfs:subClassOf* traversiert die Klassen-Hierarchie${NC}"
# =============================================================
echo ""
echo "  Lösung: Property Path rdfs:subClassOf*"
echo "  Das * bedeutet: null oder mehr Schritte entlang rdfs:subClassOf"
echo "  Professor → AcademicPerson → Person ✓ (2 Schritte)"
echo "  Student   → AcademicPerson → Person ✓ (2 Schritte)"
echo ""
cat "$QUERY_DIR/05_personen_MIT_inferenz.sparql" | grep -v "^#" | sed 's/^/  /'
echo ""
echo -e "${GREEN}Ergebnis:${NC}"
run_query "$QUERY_DIR/05_personen_MIT_inferenz.sparql"
echo ""
echo -e "  ${GREEN}→ Alle 7 Personen! Obwohl niemand explizit als uni:Person eingetragen ist.${NC}"
pause

# =============================================================
echo -e "${BLUE}[SCHRITT 8] Query 6 – COUNT: Personen pro Universität${NC}"
echo -e "${BOLD}Zeigt: Aggregation (identisch zu SQL COUNT + GROUP BY)${NC}"
# =============================================================
echo ""
cat "$QUERY_DIR/06_count_pro_uni.sparql" | grep -v "^#" | sed 's/^/  /'
echo ""
echo -e "${GREEN}Ergebnis:${NC}"
run_query "$QUERY_DIR/06_count_pro_uni.sparql"
pause

# =============================================================
echo -e "${BLUE}[SCHRITT 9 – OPTIONAL] Query 7 – Federated Query gegen DBpedia${NC}"
echo -e "${BOLD}Zeigt: Warum globale URIs so mächtig sind – zwei Stores, eine Anfrage${NC}"
# =============================================================
echo ""
echo -e "  ${YELLOW}Hinweis: Braucht Internetzugang. DBpedia kann langsam sein (~5s).${NC}"
echo -e "  ${YELLOW}Bei Verbindungsproblemen: Screenshot als Fallback zeigen.${NC}"
echo ""
echo "  Ausführen? (j/n)"
read -r answer
if [ "$answer" = "j" ] || [ "$answer" = "J" ]; then
    # Federated query: local endpoint performs a remote SERVICE call to DBpedia.
    cat "$QUERY_DIR/07_federated_dbpedia.sparql" | grep -v "^#" | sed 's/^/  /'
    echo ""
    echo -e "${GREEN}Ergebnis (kann einige Sekunden dauern):${NC}"
    run_query "$QUERY_DIR/07_federated_dbpedia.sparql"
else
    echo "  → Übersprungen."
fi

# =============================================================
echo ""
echo -e "${BOLD}=============================================================${NC}"
echo -e "${BOLD}  DEMO ABGESCHLOSSEN${NC}"
echo -e "${BOLD}=============================================================${NC}"
echo ""
echo "  Web-UI für eigene Queries: $ENDPOINT"
echo "  Nächster Schritt: Interaktive Übung (Query Challenge)"
echo ""
