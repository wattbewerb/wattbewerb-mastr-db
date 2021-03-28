SET search_path TO mastr,public;

CREATE MATERIALIZED VIEW CHECKS AS
SELECT 100 check_code, 'Verbrenner mit solarer Strahlungsenergie' check_name, 'Photovoltaik-Anlage mit Hauptbrennstoff '||Hauptbrennstoff_LT.value beschreibung, gemeindeschluessel, mastrnummer, isnbpruefungabgeschlossen, datumletzteaktualisierung, NetzbetreiberMaStRNummer, NetzbetreiberNamen FROM mastr 
JOIN Hauptbrennstoff_LT on Hauptbrennstoff_LT.key = mastr.HauptbrennstoffId WHERE EnergietraegerId=2495
UNION
SELECT 200 check_code, 'Inplausibele Bruttoleistung' check_name,'Bruttoleistung '||bruttoleistung|| ' bei '|| AnzahlSolarModule ||' Solarmodulen unpausibel' beschreibung, gemeindeschluessel, mastrnummer, isnbpruefungabgeschlossen, datumletzteaktualisierung, NetzbetreiberMaStRNummer, NetzbetreiberNamen FROM mastr 
WHERE bruttoleistung/AnzahlSolarModule > 0.9 AND (bruttoleistung < 30 OR anlagenbetreiberpersonenart = 517)
UNION
SELECT 210 check_code, 'Koordinatenveröffentlichung bei unplausibler Bruttoleistung' check_name, 'Mögliches Datenschutzproblem wg. Koordinatenveröffentlichung trotz inplausibler Bruttoleistung '||bruttoleistung|| ' bei '|| AnzahlSolarModule ||' Solarmodulen' beschreibung, gemeindeschluessel, mastrnummer, isnbpruefungabgeschlossen, datumletzteaktualisierung, NetzbetreiberMaStRNummer, NetzbetreiberNamen FROM mastr 
WHERE bruttoleistung/AnzahlSolarModule > 0.9 AND bruttoleistung >= 30 AND anlagenbetreiberpersonenart != 517
UNION
SELECT 300 check_code, 'Nabenhöhe unerwartet hoch' check_name, 'Nabenhöhe '||NabenhoeheWindenergieanlage||' unerwartet hoch' beschreibung, gemeindeschluessel, mastrnummer, isnbpruefungabgeschlossen, datumletzteaktualisierung, NetzbetreiberMaStRNummer, NetzbetreiberNamen FROM mastr
WHERE NabenhoeheWindenergieanlage > 200
UNION
SELECT 310 check_code, 'Windanlagen-Rotorradius größer als Nabenhöhe' check_name, 'Nabenhöhe '||NabenhoeheWindenergieanlage||' bei Rotordurchmesser '||RotordurchmesserWindenergieanlage||' unerwartet' beschreibung, gemeindeschluessel, mastrnummer, isnbpruefungabgeschlossen, datumletzteaktualisierung, NetzbetreiberMaStRNummer, NetzbetreiberNamen  FROM mastr
WHERE NabenhoeheWindenergieanlage < (RotordurchmesserWindenergieanlage/2)
UNION
SELECT 320 check_code, 'Rotordurchmesser größer als weltgrößter Anlage' check_name, 'Rotordurchmesser '||RotordurchmesserWindenergieanlage||' unerwartet hoch' beschreibung, gemeindeschluessel, mastrnummer, isnbpruefungabgeschlossen, datumletzteaktualisierung, NetzbetreiberMaStRNummer, NetzbetreiberNamen FROM mastr
WHERE RotordurchmesserWindenergieanlage > 180;

CREATE OR REPLACE VIEW anzahl_auffaelligkeiten AS
SELECT COALESCE(geprueft.check_code,inpruefung.check_code) check_code, COALESCE(geprueft.check_name,inpruefung.check_name) check_name, anzahl_geprueft, anzahl_inpruefung FROM
(SELECT check_code, check_name, count(*) anzahl_geprueft from checks 
WHERE isnbpruefungabgeschlossen=2954
GROUP by check_code, check_name) geprueft
FULL OUTER JOIN (SELECT check_code, check_name, count(*) anzahl_inpruefung from checks 
WHERE isnbpruefungabgeschlossen=2955
GROUP by check_code, check_name) inpruefung 
ON geprueft.check_code = inpruefung.check_code 
ORDER BY COALESCE(geprueft.check_code,inpruefung.check_code);
