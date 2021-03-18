# Wattbewerb-MaStR-DB

Die WATTbewerb-MaStR-DB ist eine periodisch aktualisierte Kopie des öffentlich abrufenbaren 
Markstammdatenregisters. 

Dieses Repository umfasst Skripte zum Abruf, Reimport in eine lokale Datenbank, Auswertungn und (geplant) Datenprüfung.

## Ablauf

### Initialer Abruf
Da derzeit keine regelmäßig aktualisierten Komplett-Exporte des Markstammdatenregisters angeboten werden, und der letzte veröffentlichte Komplett-Export den Stand vom 22.10.2020 wiedergibt, laden 
wir die MaStR-Daten initial vollständig ab. 

#### Details zum initialen Abruf
##### Paginierter Abruf
Der Download erfolgt schrittweise durch Abrufe von jeweils 5000 Datensätzen (maximal mögliche Anzahl Datensätze je Abruf). Ein solcher paginierte Abruf setzt voraus, dass die Sortierreihenfolge der Anlagen über alle Abrufe hinweg gleich bleibt, und insbesondere keine Anlagen eingefügt oder gelöscht werden, wovon wir bei der erweiterten Einheitenübersicht ausgehen.

##### Redundante Informationen
Um den Speicherbedarf zu reduzieren, werden einige Spalten vor Speicherung direkt gelöscht. 
Dies gilt insbesondere für Spalten, die aus anderen Spalten eindeutig abgeleitet werden können:

* Bundesland
* StandortAnonymisiert
* TechnologieStromerzeugung
* HauptausrichtungSolarModuleBezeichnung 
* HauptbrennstoffNamen
* VollTeilEinspeisungBezeichnung 
* BetriebsStatusName 
* SystemStatusName

##### Download durchführen

Der initiale Download erfordert eine lokale Python-Installation sowie die Installation von benötigten Bibliotheken anhand der requirements.txt-Datei:

```sh
pip install -r requirements.txt

python 01_download_mastr.py
```

### Import in die Datenbank
Über das Skript 02_import.sh wird das Datenbank-Schema (Schlüsseltabellen, Staging-Tabelle für den Import und die mastr-Tabelle angelegt, die abgerufenen Daten in die Staging-Tabelle importiert, 
in die mastr-Tabelle übernommen und verschiedene Datenbank-Views (teilweise als materialized Views) angelegt.

```sh
./02_import.sh
```

### Export und Reimport
Um die Datenbank in eine Remote-Datenbank zu importieren, kann man über Skript 04_export_wattbewerb_dump.sh eine Dump-Datei erstellen, die sich mit

```sh
04_transfer_wattbewerb_dump.sh <remote db connectstring>
```
exportieren und in eine remote (z.B. Heroku-)Datenbank reimportieren lässt.

### Tägliches Update

Über das Download-Skript lassen sich auch Datensätze ab einem bestimmten Änderungszeitpunkt herunterladen und mit dem upsert-Skript importieren.

```sh
python 01_download_mastr.py -s 15.03.2021
python 03_upsert_mastr_delta.py -i out/mastr_15.03.2021.csv -c 'postgresql://postgres:@localhost:25432/postgres'
```

Zum Import in eine Remote-Datenbank muss der Connectstring entsprechend angepasst werden.

### Auswertungen
Mit dem initialen Import werden die folgenden (teils materialisierten) Views angelegt:

* statistik_start_per_ags
* statistik_heute_per_ags
* zuwachs_per_gemeinde
* zuwachs_per_landkreis
* zuwachs_per_bundesland
