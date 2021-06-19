SET search_path=mastr,public;

.header on

\COPY (select * from stat_ranking) TO 'out/ranking.csv' DELIMITER ',' CSV HEADER;
--\COPY (select * from stat_nbpruefung) TO 'out/nbpruefung.csv' DELIMITER ',' CSV HEADER;
-- https://app.datawrapper.de/chart/enNPh/visualize#refine
\COPY (
SELECT * FROM stats_auffaelligkeiten_staedte ORDER BY "Unplausible Brutttoleistung"+"Unplausible Brutttoleistung mit Koordinatenveröffentlichung"+"Unplausibles Inbetriebnahmedatum" DESC
) TO 'out/datawrapper_unplausibel.csv' WITH CSV DELIMITER '	' HEADER;

\COPY (
SELECT name, (bruttoleistung_start_geprueft+bruttoleistung_start_inpruefung)/residents   startwert, (bruttoleistung_aktuell_geprueft + bruttoleistung_aktuell_inpruefung)/residents "Leistung[kWp]/EW", zuwachs_prozent "Zuwachs in %", zuwachs_kwp/residents "Zuwachs [kWp]/EW", case WHEN residents < 100000 then 'K' ELSE 'G' end "Klasse" from zuwachs_per_gemeinde z 
JOIN teilnehmer t ON gemeindeschluessel=t.ags
ORDER BY zuwachs_kwp/residents DESC
) TO 'out/datawrapper_prozentzuwachs_vs_start.csv' WITH CSV DELIMITER '	' HEADER;

\COPY (
SELECT * FROM checks WHERE check_code < 300
) TO 'out/wattbewerb_unplausible_anlagen.csv' WITH CSV DELIMITER ';' HEADER;

\COPY (
SELECT * FROM checks WHERE check_code < 300
AND gemeindeschluessel like '08226%'
ORDER BY bruttoleistung DESC
) TO 'out/wattbewerb_unplausible_anlagen_08226.csv' WITH CSV DELIMITER ';' HEADER;

\COPY (
SELECT SUBSTRING(gemeindeschluessel,1,5) Code, COUNT(*) "Anzahl Anlagen", SUM(bruttoleistung) "Bruttoleistung" FROM checks WHERE check_code BETWEEN 200 and 210
GROUP BY SUBSTRING(gemeindeschluessel,1,5)
) TO 'out/datawrapper_karte_unplausibilitaeten.csv' WITH CSV DELIMITER ',' HEADER;

\COPY (
SELECT t.name, c.* FROM checks c
JOIN teilnehmer t ON t.ags = c.gemeindeschluessel
WHERE check_code < 300
ORDER BY t.ags, c.bruttoleistung DESC
) TO 'out/wattbewerb_unplausible_anlagen_teilnehmer.csv' WITH CSV DELIMITER ';' HEADER;
