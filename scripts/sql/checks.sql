SET search_path TO mastr,public;

DROP MATERIALIZED VIEW IF EXISTS CHECKS CASCADE;
CREATE MATERIALIZED VIEW CHECKS AS
SELECT 100 check_code, 'Verbrenner mit solarer Strahlungsenergie' check_name, 'Photovoltaik-Anlage mit Hauptbrennstoff '||Hauptbrennstoff_LT.value beschreibung, gemeindeschluessel, mastrnummer, bruttoleistung, isnbpruefungabgeschlossen, datumletzteaktualisierung, NetzbetreiberMaStRNummer, NetzbetreiberNamen FROM mastr 
JOIN Hauptbrennstoff_LT on Hauptbrennstoff_LT.key = mastr.HauptbrennstoffId WHERE EnergietraegerId=2495
UNION
SELECT 200 check_code, 'Unplausibele Bruttoleistung' check_name,'Bruttoleistung '||bruttoleistung|| ' bei '|| AnzahlSolarModule ||' Solarmodulen unpausibel' beschreibung, gemeindeschluessel, mastrnummer, bruttoleistung, isnbpruefungabgeschlossen, datumletzteaktualisierung, NetzbetreiberMaStRNummer, NetzbetreiberNamen FROM mastr 
WHERE bruttoleistung/AnzahlSolarModule > 0.9 AND (bruttoleistung < 30 OR anlagenbetreiberpersonenart = 517)
UNION
SELECT 210 check_code, 'Koordinatenveröffentlichung bei unplausibler Bruttoleistung' check_name, 'Mögliches Datenschutzproblem wg. Koordinatenveröffentlichung trotz unplausibler Bruttoleistung '||bruttoleistung|| ' bei '|| AnzahlSolarModule ||' Solarmodulen' beschreibung, gemeindeschluessel, mastrnummer, bruttoleistung, isnbpruefungabgeschlossen, datumletzteaktualisierung, NetzbetreiberMaStRNummer, NetzbetreiberNamen FROM mastr 
WHERE bruttoleistung/AnzahlSolarModule > 0.9 AND bruttoleistung >= 30 AND anlagenbetreiberpersonenart != 517
UNION
SELECT 290 check_code, 'Inbetriebnahmedatum PV-Anlage vor 1980' check_name, 'Inbetriebnahmedatum '||Inbetriebnahmedatum||' vor 1983' beschreibung, gemeindeschluessel, mastrnummer, bruttoleistung, isnbpruefungabgeschlossen, datumletzteaktualisierung, NetzbetreiberMaStRNummer, NetzbetreiberNamen FROM mastr
WHERE EnergietraegerId=2495 and  Inbetriebnahmedatum< '1980-01-01'
UNION
SELECT 300 check_code, 'Nabenhöhe unerwartet hoch' check_name, 'Nabenhöhe '||NabenhoeheWindenergieanlage||' unerwartet hoch' beschreibung, gemeindeschluessel, mastrnummer, bruttoleistung, isnbpruefungabgeschlossen, datumletzteaktualisierung, NetzbetreiberMaStRNummer, NetzbetreiberNamen FROM mastr
WHERE NabenhoeheWindenergieanlage > 200
UNION
SELECT 310 check_code, 'Windanlagen-Rotorradius größer als Nabenhöhe' check_name, 'Nabenhöhe '||NabenhoeheWindenergieanlage||' bei Rotordurchmesser '||RotordurchmesserWindenergieanlage||' unerwartet' beschreibung, gemeindeschluessel, mastrnummer, bruttoleistung, isnbpruefungabgeschlossen, datumletzteaktualisierung, NetzbetreiberMaStRNummer, NetzbetreiberNamen  FROM mastr
WHERE NabenhoeheWindenergieanlage < (RotordurchmesserWindenergieanlage/2)
UNION
SELECT 320 check_code, 'Rotordurchmesser größer als weltgrößter Anlage' check_name, 'Rotordurchmesser '||RotordurchmesserWindenergieanlage||' unerwartet hoch' beschreibung, gemeindeschluessel, mastrnummer, bruttoleistung, isnbpruefungabgeschlossen, datumletzteaktualisierung, NetzbetreiberMaStRNummer, NetzbetreiberNamen FROM mastr
WHERE RotordurchmesserWindenergieanlage > 180
;

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

CREATE OR REPLACE VIEW anzahl_auffaelligkeiten_je_gemeinde AS
SELECT COALESCE(geprueft.gemeindeschluessel,inpruefung.gemeindeschluessel) gemeindeschluessel, 
COALESCE(anzahl_geprueft, 0) anzahl_geprueft, 
COALESCE(anzahl_inpruefung, 0) anzahl_inpruefung,
COALESCE(anzahl_geprueft, 0) + COALESCE(anzahl_inpruefung,0) anzahl_gesamt FROM
(SELECT gemeindeschluessel, count(*) anzahl_geprueft from checks 
WHERE isnbpruefungabgeschlossen=2954
  AND check_code < 300 -- For wattbewerb, we cont just pv issues
GROUP by gemeindeschluessel) geprueft
FULL OUTER JOIN (SELECT gemeindeschluessel, count(*) anzahl_inpruefung from checks 
WHERE isnbpruefungabgeschlossen=2955
  AND check_code < 300 -- For wattbewerb, we cont just pv issues
GROUP by gemeindeschluessel) inpruefung 
ON geprueft.gemeindeschluessel = inpruefung.gemeindeschluessel 
ORDER BY COALESCE(anzahl_geprueft,0) DESC, COALESCE(anzahl_inpruefung,0) DESC;

CREATE VIEW anzahl_auffaelligkeiten_je_gmd_und_check AS 
SELECT gemeindeschluessel, check_name, check_code, count(*) anzahl
FROM checks
GROUP BY gemeindeschluessel, check_name, check_code;

CREATE OR REPLACE VIEW stats_auffaelligkeiten_staedte AS 
SELECT name, 
       COALESCE(c200.anzahl,0) "Unplausible Brutttoleistung",
       COALESCE(c210.anzahl,0) "Unplausible Brutttoleistung mit Koordinatenveröffentlichung",
       COALESCE(c400.anzahl,0) "Unplausibles Inbetriebnahmedatum" 
  FROM teilnehmer t
  LEFT JOIN anzahl_auffaelligkeiten_je_gmd_und_check c200 ON c200.check_code=200 AND c200.gemeindeschluessel=t.ags 
  LEFT OUTER JOIN anzahl_auffaelligkeiten_je_gmd_und_check c210 ON c210.check_code=210 AND c210.gemeindeschluessel=t.ags 
  LEFT OUTER JOIN anzahl_auffaelligkeiten_je_gmd_und_check c400 ON c400.check_code=400 AND c400.gemeindeschluessel=t.ags ;

CREATE OR REPLACE VIEW anzahl_auffaelligkeiten_je_betreiber AS
SELECT COALESCE(geprueft.NetzbetreiberMaStRNummer,inpruefung.NetzbetreiberMaStRNummer) NetzbetreiberMaStRNummer, 
COALESCE(geprueft.NetzbetreiberNamen,inpruefung.NetzbetreiberNamen) NetzbetreiberNamen, 
anzahl_geprueft, anzahl_inpruefung FROM
(SELECT NetzbetreiberMaStRNummer, NetzbetreiberNamen, count(*) anzahl_geprueft from checks 
WHERE isnbpruefungabgeschlossen=2954
GROUP by NetzbetreiberMaStRNummer, NetzbetreiberNamen) geprueft
FULL OUTER JOIN (SELECT NetzbetreiberMaStRNummer, NetzbetreiberNamen, count(*) anzahl_inpruefung from checks 
WHERE isnbpruefungabgeschlossen=2955
GROUP by NetzbetreiberMaStRNummer, NetzbetreiberNamen) inpruefung 
ON geprueft.NetzbetreiberMaStRNummer = inpruefung.NetzbetreiberMaStRNummer 
ORDER BY COALESCE(anzahl_geprueft,0) DESC, COALESCE(anzahl_inpruefung,0) DESC;

CREATE OR REPLACE VIEW unplausible_bruttoleistung_je_gemeinde AS
SELECT u.gemeindeschluessel, COALESCE(sum(u.bruttoleistung),0) bruttoleistung_unplausibel
FROM teilnehmer t
LEFT JOIN (SELECT gemeindeschluessel, mastrnummer, bruttoleistung FROM checks WHERE check_code in (200, 210, 400) GROUP BY gemeindeschluessel, mastrnummer, bruttoleistung) AS u ON t.ags = u.gemeindeschluessel
JOIN (SELECT mastrnummer FROM mastr WHERE Inbetriebnahmedatum > '2021-02-12') n ON n.mastrnummer = u.mastrnummer 
GROUP BY u.gemeindeschluessel;
;

CREATE VIEW stat_plausibilitaet_bruttoleistung AS
SELECT CASE WHEN c.isnbpruefungabgeschlossen = 2954 THEN 'Inplausibel, geprüft (kWp)' ELSE 'Inplausibel, ungeprüft (kWp)' END , SUM(m.bruttoleistung) bruttoleistung 
FROM mastr m 
JOIN checks c ON m.mastrnummer = c.mastrnummer WHERE energietraegerid=2495
GROUP BY c.isnbpruefungabgeschlossen
UNION
SELECT 'Plausibel (kWp)', SUM(bruttoleistung) bruttoleistung FROM mastr m WHERE energietraegerid=2495 AND mastrnummer not in (select mastrnummer from checks);
	

