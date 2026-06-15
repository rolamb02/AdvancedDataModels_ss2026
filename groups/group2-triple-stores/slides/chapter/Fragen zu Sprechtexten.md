# Fragen zu Sprechtexten 
## Data Structure 
Folie 3
Ist das bei Wikidata direkt diese IDs oder findet da nochmal eine Übersetzungsebene statt? 
bsp: """
#Katzen
SELECT ?item ?itemLabel
WHERE
{
  ?item wdt:P31 wd:Q146. # Muss eine Katze sein
  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],mul,en". } # Helps get the label in your language, if not, then default for all languages, then en language
}
"""

wie ist das im vergleich zum Property Graph, dieser ist ja auch schneller bei Graph traversierung, deswegen? 

Folie 4 
kannst du mal ein reales Beispiel machen von subjekt bekannt rest suche? weil ich kenne das nur mit einer variable
ist das  immer so bei den bekannten triple store anbietern, was ist beispielsweise bei oxigraph, dem was ich als demo hab, was bei wikidata, was bei anderen bekannten? 
was bedetutet b tree sortierte kopie? kannst du das genauer ausführen? 

folie 5 
das mit diesem uri datenintegration ist doch auch genau das was gemeint ist, wenn man sagt triplestore hat semantik oder? also das eben man über eindeutige uri genau weiß, was das gennante ist? nicht nur eindeutigkeit sondern klassifizierbarkeit, beudetet stuttgart = stadt, george clooney = person / schauspieler


Bitte finaler check: 
Schau dir nochmal report md an, deckt das data structure kapitel wirklich das ab, was laut diesem dokument in root gefordert ist? fehlen punkte? 


## Query Model
Folie 1
auf dem html steht noch keine semantik vs w3c standart. was genau ist nochmal dieser w3c standart und hängt er mit semantik zusammen? 

ist die folie so gut gestaltet? 1. passt das mit dem w3c syntaktisch schon hier rein, wenn ja, dann ist das beispiel aus meinem Query so gut getroffen? weil ich finde hier wird das mit dem w3c ja nur bedingt deutlich oder? schließlich geht es ja darum, dass mit dbo:stadt oder so ähnlich eben klar ist, dass stuttgart eine stadt ist oder hab ich das falsch verstanden? ich finde nicht, dass wir unbedingt die querys aus meiner demo später hier nehmen müssen, dass können auch andere sein, wichtig ist, dass alles verdeutlicht wird. 

Folie 2
das mit dem "nur syntaktischer Zucker, keine externe DB" ist doch irgendwie weird oder? weil die studierenden können so wenig damit anfangen, könnten wir das in der html bitte umschreiben und auch im sprechtext dann entsprechend asusführen oder
 
 find das mit den ganzen query typen wirkt da ein bisschen überfordernd, weil das so alles auf einmal ist. zum anderen ist es auch irgendwie komisch die query typen nur so kurz aufgezählt zu haben. mindestens eigentlich gerne ein beispiel pro query typ, was eine mögliche anwendung demonstiert

irgendwie bin ich mit dem gesamten aufbau an vielen punkten nicht zufrieden wie du merkst, können wir da einfach nochmal das ganze neu denken? was ist mit der folienstruktur in slide structure, ist die vielleciht schonmal ein neuer anhaltspunkt?

verständlich ist eigentlich alles für mich glaub. aber da könnte wir nochmal drüber reden. 

---

Review Foliengesaltung: 
nochmal bitte drüber schauen, da stimmen paar sachen einfach nicht mit dem was wir besprochen haben. unten schonmal paar sachen, die mir aufgefallen sind. bitte lass uns nochmal gemeinsam planen, was zu ändern jetzt ist. Danke! 

Einmal bitte meine kommis durhclesen und dann selbst nochmal überlegen, sind die folien jetzt passend? 

-  das query typen ist immer noch drinnen bei 2. folie
-  Folie 3 graphisch unten nicht so schön, das obere muss ja auch alles nicht so groß sein. wie könnte man das graphisch anpassen 
- Folienanordnung auch hier optimierbar oder? 
- Folie 4 unten irgendwie abgeschnitten, zudem haben wir davor ja schon property path, das muss ja nicht nochmal so groß thematisiert werden. und ist irgendwo union mit drinnen? 
- unten abeschnitten. redesign? 
- demo hinweis raus aus den folien oder? ist doch quatsch das den leuten zu zeigen doer? 
- Verständis: Könnte ich describe bspw. nicht auch einfach durch select ?p ?o
uni:Stuttgart ?p ?o umsetzen? 
- desgintechnisch können wir das bissle schöner machen oder? arg viel fließtext in abetracht von instructions slide desgin

Bitte beachte meine Kommentare und überleg dann selbst nochmal aufgrundlage der Folien, wie könnte man die FOlien noch schöner gestalten / was könnte man verbessern. Nicht umsetzen nur planen und natürlich alles im Rahmen der Instructions Slide design. 


## Comparison
Folie 1: 
ich find das nicht so gut it links den orangenen und roten symbolen und rechts überall grüne Haken. das macht ja auch irgendwo kein sein, weil bspw. zeile in tabelle nicht per se schlechte rist als subjekt prädikat obekt. 

ich finde es immer noch bissle weird und verste es nicht mit Native Kanten. Sind beziehungen in RDF nicht einfach über die Prädikate (studiert an) als auch über geteilte Variable ermöglicht? 

kannst du bitte doch nochmal kurz erklären, warum bei semantik rdfs und owl aber nicht rdf oder sogar dbo oder wdt steht?

Folie 2
hier gibt es einen graphischen fehler in der kopfzeile, bitte screenshot anschauen. 


können wir bitte nochmal wiederholen, was jetzt ganz genau dieser w3c standart vorgibt. 



- würde reifikation rausnehmen und schreiben, dass es nich tso einfach möglich ist oder so, keine ahnung, aber das reifikation muss man glaub nicht mehr rausgreifen. 


okay, also die Traversal Perormance hab ich soweit verstanden, nur mit der begrifflichkeit permutationen in der folie tu ich mir schwer. Kannst du das erklären, oder könnte man das auf einen einfacheren Begriff runterbrechen? 

also bei typischer Use case sagst du knowledge graph / AI / RAG. Ist das wikrlich so? knowledge graph ist doch einfach ein anderes wort für Triple store oder was steckt dahinter. 


Folie 3: 
Beispiele für Tiefe graphennavigation sind Soziale Netzwerke, sonst noch was? 

ist ein Nachteil bei  einstieg tooling auch einfach, dass ich halt ggf. die verschiedenen Präfixe und auch prädikate / objekte kennen muss, um mich durchzunavigiere, bzw um meine  datenbank aufzusetzen. 

An sich hast du hier ja sozusagen db eigenschaften / vorraussetzungen gesagt, aber selten konkrete Use cases. Bitte hole das nach und achte auf seriöse quellen bzw arbeite mit notebook lm mcp. 

und bitte verifiziere auch nochal diesen ai / rag abschnitt. da bin ich mir nicht so sicher ehrlich gesagt. 

lass die typischen Use cases bei folie 2 draußen




Kommentar: Wenn du zugriff hast zu notebook lm mcp verifizieren deine aussagen mit diesem oder ggf. mit einer Online Recherche. 






