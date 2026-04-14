
# Sektion 3: Data Structure – Das Fundament der Vernetzung

## Folie 1: Triple-basierte Speicherung – Weg von der Tabelle
**Kernbotschaft:** Triple-Stores speichern Fakten atomar und vermeiden das "NULL-Problem" relationaler Datenbanken.

*   **Das Problem der "breiten Tabelle" (SQL):**
    *   In SQL müssen Spalten vorab definiert werden. Fehlen Informationen (z. B. das Gründungsdatum einer Uni), entstehen "leere" Zellen (NULL-Werte).
    *   **Beispiel:** Eine Tabelle `Universitäten` mit Spalten für `Name`, `Stadt`, `Rektor`, `Gründungsjahr`. Viele Felder bleiben leer, wenn Daten unvollständig sind.
*   **Die Lösung: Vertikale Triple-Struktur:**
    *   Wissen wird in eine Liste einfacher Fakten zerlegt: **Subjekt – Prädikat – Objekt**.
    *   **Beispiel (Roter Faden):**
        1. `Uni_Stuttgart` -> `hat_Name` -> `"Universität Stuttgart"`.
        2. `Uni_Stuttgart` -> `liegt_in` -> `Stuttgart`.
        *(Kein Fakt zum Gründungsjahr? Dann existiert einfach kein Triple – kein Platz wird verschwendet.)*
*   **Vorteil:** Natürliche Abbildung vernetzter Daten ohne künstliche Tabellenstrukturen oder Join-Tabellen für n:m-Beziehungen.


---

## Folie 2: Schema-Flexibilität – Dynamisches Wachstum für AI-Pipelines
**Kernbotschaft:** Semantic Triple Stores sind "Schema-light" – das Wissen bestimmt die Struktur, nicht die Datenbank-Administration.

*   **Wachstum ohne "ALTER TABLE":**
    *   In SQL erfordert jedes neue Attribut (z. B. `Social_Media_Profil` für Professoren) eine Änderung des Tabellenschemas, was oft bestehende Anwendungen unterbricht.
    *   **Beispiel:** Ein AI-Agent findet neue Infos über Forschungsbereiche. In RDF hängen wir einfach ein neues Triple an: `Prof_Müller` -> `forscht_an` -> `Quantencomputing`.
*   **Vorteil für agile AI-Workflows:**
    *   AI-Systeme (z. B. RAG) müssen oft heterogene, sich ständig ändernde Quellen integrieren.
    *   RDF bricht nicht, wenn neue Datentypen auftauchen; es ist inhärent erweiterbar.
*   **Gegenüberstellung:**
    *   **SQL:** Starr, vordefiniert, Fokus auf Tabellen-Integrität.
    *   **RDF:** Flexibel, dynamisch, Fokus auf semantische Erweiterbarkeit.

---



---

## Folie 3: Datenintegration über URIs – Die globale Identität
**Kernbotschaft:** URIs machen Ressourcen weltweit eindeutig und ermöglichen die nahtlose Datenintegration.

*   **Vermeidung von Ambiguität:**
    *   Der Text "Stuttgart" ist mehrdeutig (Stadt, Nachname, String). Eine URI wie `http://dbpedia.org/resource/Stuttgart` ist global eindeutig.
*   **Ressourcen in verschiedenen Rollen:**
    *   Eine Ressource (URI) kann in einem Triple als **Subjekt** und in einem anderen als **Objekt** auftreten.
    *   **Beispiel:**
        1. `Stuttgart` (S) -> `liegt_in` -> `Baden-Württemberg` (O).
        2. `Uni_Stuttgart` (S) -> `liegt_in` -> `Stuttgart` (O).
    *   Dies erschließt automatisch die Kette: `Uni_Stuttgart` -> `Stuttgart` -> `Baden-Württemberg`.
*   **Datenintegration am Beispiel:**
    *   Interne Daten: `Meine_Uni` -> `kooperiert_mit` -> `http://dbpedia.org/resource/Stuttgart`.
    *   DBpedia-Daten: `http://dbpedia.org/resource/Stuttgart` -> `Einwohner` -> `600.000`.
    *   **Ergebnis:** Automatische Verschmelzung beider Quellen über die identische URI.

---

## Folie 4: Zusammenfassung – Von isolierten Fakten zur globalen Struktur
**Kernbotschaft (Roter Faden):** Die Kombination aus Triples, Flexibilität und URIs schafft eine skalierbare Wissensstruktur.

*   **Wissen vernetzen:**
    1.  **Atomisierung:** Daten in Triples zerlegen (einfach, stabil).
    2.  **Identifizierung:** Globale URIs nutzen (eindeutig, verknüpfbar).
    3.  **Flexibilität:** Wissen organisch wachsen lassen (keine starren Grenzen).
*   **Ergebnis:** Eine globale Wissensstruktur, die über Datenbankgrenzen hinweg maschinenlesbar und inferenzfähig bleibt.
*   *Überleitung zum nächsten Slot:* "Wie fragen wir dieses vernetzte Wissen nun effizient ab? -> SPARQL Query Model"