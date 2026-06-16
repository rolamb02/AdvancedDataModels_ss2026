DATA LAKES
Tom & Micha | ADM SS26

Agenda
Motivation
1.
Konzeptionelles Modell
2.
DatenStruktur
3.
Abfragemodell
4.
Architektur
5.
Vergleich zu relationalen Datenbanken
6.
Demo
7.
Aufgaben
8.
Abschluss
9.

1. Motivation
| Problem-Szenario | Historie | Bezug zu AI/ML  |
| ---------------- | -------- | --------------- |

2. Konzeptionelles Modell
| Write  | Read | Struktur | Analogie |
| ------ | ---- | -------- | -------- |

Schema-on-Write
Schema wird vor dem Laden der Daten festgelegt → Daten müssen passend transformiert werden
BEVOR sie ins System gelangen
• Struktur und Verwendung der Daten vorab definiert
• ETL als Standardvorgehen
• Jegliche Arten von Transformationen vor dem Speichern
Rohdaten Schema Transformation Data Warehouse
ETL
Verkehr, Wetter, Logs Spalten & Typen festlegen Bereinigt & Angepasst Sofort Analysierbar

Schema-on-Read
• Rohdaten werden im Originalformat gespeichert →die Struktur wird erst beim Lesen/Analysieren der
Daten interpretiert
• Speicherung im Originalformat (strukturiert, unstrukturiert, semi-strukturiert)
• Keine aufwendige Vorverarbeitung
• ELT als Standardvorgehen
Rohdaten Data Lake Verschiedene Sichten
EL T
Sensoren, Bilder, Logs Speicherung im Original Bildanalyse, Verkehrsdashboard

Struktur/Architektur
Storage
| Ingestion | Maintenance | Exploration |
| --------- | ----------- | ----------- |
Datensatz Organisation
| Metadaten-Extraktion | Datenbereinigung | Datensuche |
| -------------------- | ---------------- | ---------- |
Metadaten-Modellierung Datenintegration Heterogene Datenanfragen
Metadaten ANreicherung
Was passiert beim Laden? Vorbereitung für Anfragen Zugriff durch Nutzer

Analogie - Datawarehouse
• DWH= Stadtbibliothek, alles sortiert in den Regalen

Analogie – Data Lake

Analogie – Data Swamp
• Data Swamp = dieselbe Lagerhalle, aber ohne Aufkleber

Lakehouse - Einleitung

Lakehouse
Drei Kernideen:
1. Offene Datenformate
• Parquet, CSV, JSON, usw.
2. Metadatenlayermit DBMS-Features
• ACID-Transaktionen
• Beispiel: Delta Lake
3. Performance
• Direkter Zugriff für ML/Datascience
• Vergleichbare SQL-Performance
Ein System statt zwei:
Warehouse-Funktionen auf dem Lake

3.Datenstruktur
| Speicher | Formate | Parquet | Metadaten  |
| -------- | ------- | ------- | ---------- |

4.Abfragemodell
Unterschiede zum
| DuckDB SQL | Delta Lake | Apache Spark |
| ---------- | ---------- | ------------ |
klassischen SQL

DuckDB – Was bringt das eigentlich?

DuckDB – Was bringt das eigentlich?

DuckDB – Was bringt das eigentlich?
Duck-DB-Weg
Standard-SQL-Weg

DuckDB – Allgemeine Informationen
Liest direkt aus:
Technik
Was ist DuckDB?
• Spaltenorientiert (OLAP)
• Embedded analytische Datenbank Excel MySQL
• ACID-Transaktionen
• In-Process(kein Server) PostgreSQL
• Zero Setup
• Open-Source
AWS S3 Text files
JSON
CSV
Wann nutzen?
Parquet
Wann nicht nutzen?
Delta Lake
• Lokale Daten Analyse
• Verteilte Workloads
• Notebook-Workflows
• OLTP
• Lernzwecke Azure Blob Storage
• Multi-User Server-DB

DuckDB – Grundlagen

Weitere Query Engines – Apache Spark
Duck DB Grenzen Apache Spark
• Nur Single-Node eine Maschine • Distributed Computing: Cluster mit Nodes
• RAM & CPU Limit • Petabyte-Scale
• Kein ML-Framework • Mllib integriert
• Kein Streaming • Structured Streaming
• Nicht für Multi-User • Cluster für Teams
→ DuckDB: lokal & schnell
→ Spark: groß verteilt
Beide ergänzen sich

Delta Lake
Was ist Delta Lake?
• Open Source Storage Layer
• Liegt auf Parquet
• Fügt ein Transaction-Log
hinzu
Kern Features:
• ACID-Transaktionen
• Time Travel
• Schema Enforcement

5.Architecture
Compute-
Ingestion- Cloud-Landscape
Storage- Data Governance
Pipelines Tabelle
Separation

Fragen
• Welche Ingestion-Art würdet ihr für Sensordaten einer Smart City wählen: Batch, Streaming oder CDC?
Warum?

Vergleich RDBMS vs. Data Lake vs. Lakehouse
Wann Welche
Direkter Was Data Lakes
Architektur
Vergleich nicht gut können
glänzt

Vergleich – RDBMS vs. Data Lake vs. Lakehouse

7. DEMO

8. AUFGABEN

Quellen
• https://www.researchgate.net/figure/Overview-of-the-three-layered-information-storage-model-containing-
the-raw-data-at-the_ fig6_ 327566909
• https://azure.microsoft.com/de-de/resources/cloud-computing-dictionary/what-is-a-data-lake
• https://www.databricks.com/blog/what-is-data-lakehouse
• https://www.databricks.com/de/discover/data-lakes
• https://www.databricks.com/discover/data-lakes/challenges
• KI Generierte Folien: Folien 22, 27, 28, 46, 49
Papers:
• https://arxiv.org/abs/2108.09020
• https://arxiv.org/abs/1908.00925