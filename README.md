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

###### Voraussetzungen

Der initiale Download erfordert eine lokale Python-Installation sowie die Installation von benötigten Bibliotheken anhand der requirements.txt-Datei:

```sh
pip install -r requirements.txt
```

Desweiteren wird eine existierende postgres-Instanz vorausgesetzt.

###### Datenbank-Schema anlegen
Über das Skript `01_create_schema.sh` wird das Datenbank-Schema (Schlüsseltabellen, Staging-Tabelle für den Import und die mastr-Tabelle angelegt, sowie Prüfungs- und Statistik-Views (teilweise als materialized Views) angelegt.

```sh
./01_create_schema.sh postgres://<connectstring>
```

###### Komplettdownload und Import

Über das skript 02_download_and_import.sh wird die MaStR-Datenbank heruntergeladen, in die Datenbank importiert und alle materialized Views aktualisiert.

```sh
./02_download_and_import.sh postgres://<connectstring>
```

### Tägliches Update

Über das Download-Skript lassen sich auch Datensätze ab einem bestimmten Änderungszeitpunkt herunterladen und mit dem upsert-Skript importieren.

```sh
python 03_download_mastr.py -s 15.03.2021
python 04_upsert_mastr_delta.py -i out/mastr_15.03.2021.csv -c 'postgresql://postgres:@localhost:25432/postgres'
```

Zum Import in eine Remote-Datenbank muss der Connectstring entsprechend angepasst werden.

### Aktualisierung Wattbewerb Teilnehmer-Städte


```sh
python 04_upsert_teilnehmer.py -i data/mastr_15.03.2021.csv -c 'postgresql://postgres:@localhost:25432/postgres'
```

Zum Import in eine Remote-Datenbank muss der Connectstring entsprechend angepasst werden.

### Auswertungen
Mit dem initialen Import werden die folgenden (teils materialisierten) Views angelegt:

* statistik_start_per_ags
* statistik_heute_per_ags
* zuwachs_per_gemeinde
* zuwachs_per_landkreis
* zuwachs_per_bundesland

## Docker
Um den Komplett-Abruf und Datenbankimport via Docker auszuführen, lässt sich via

```
docker build -t mfdz/wattbewerb-mastr .
docker run -v $PWD/out:/app/out/ mfdz/wattbewerb-mastr bash 02_download_and_import.sh <dbconnectstring1> [<dbconnectstring2>] &> out/import.log
``` 

## Änderungen
* Mit [Version 22.2.98 des MaStR](https://www.marktstammdatenregister.de/MaStRHilfe/subpages/releasenotes.html) (veröffentlicht am 2.11.2022) werden statt der angefragten Anzahl Datensätze teilweise weniger zurückgeliefert. Zudem wurde die Eigenschaft `migriert` entfernt. Bestehende schemata müssen daher mit einem `ALTER TABLE mastr.mastr DROP COLUMN migriert; ALTER TABLE mastr.mastr DROP COLUMN statistik;`  angepasst werden. Dazu Umbenennungen der Eigenschaften 
* Mit [Version 24.1.135 des MaStR](https://www.marktstammdatenregister.de/MaStRHilfe/subpages/releasenotes.html) (veröffentlicht am 2.5.2024) entfiel das Feld GemeinsamerWechselrichter.Skript `scripts/sql/00_schema_changes.sql` entfernt dieses Feld aus der `mastr`-Tabelle.

