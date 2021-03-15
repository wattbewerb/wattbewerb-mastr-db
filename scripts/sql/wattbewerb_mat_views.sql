DROP MATERIALIZED VIEW statistik_start_per_ags;
CREATE MATERIALIZED VIEW statistik_start_per_ags AS
(SELECT ags gemeindeschluessel, count(*) anzahl_anlagen, sum(brutto) Summe_Bruttoleistung, sum(netto) Summe_Nettonennleistung FROM 
(SELECT Gemeindeschluessel ags, Bruttoleistung brutto, Nettonennleistung netto
FROM mastr
WHERE EnergietraegerId=2495 AND MaStRNummer LIKE 'SEE%' AND BetriebsStatusId=35 AND InbetriebnahmeDatum < '2021-02-13' AND HauptbrennstoffId IS NULL) as anlage
GROUP BY ags);

DROP MATERIALIZED VIEW statistik_heute_per_ags;
CREATE MATERIALIZED VIEW statistik_heute_per_ags AS
(SELECT ags gemeindeschluessel, count(*) anzahl_anlagen, sum(brutto) Summe_Bruttoleistung, sum(netto) Summe_Nettonennleistung FROM 
(SELECT Gemeindeschluessel ags, Bruttoleistung brutto, Nettonennleistung netto
FROM mastr
WHERE EnergietraegerId=2495 AND MaStRNummer LIKE 'SEE%' AND BetriebsStatusId=35 AND HauptbrennstoffId IS NULL) as anlage
GROUP BY ags);

CREATE OR REPLACE VIEW zuwachs_per_gemeinde AS
SELECT heute.gemeindeschluessel, ROUND(start.Summe_Bruttoleistung) Bruttoleistung_start, ROUND(heute.Summe_Bruttoleistung) Bruttoleistung_aktuell, ROUND(((heute.Summe_Bruttoleistung/start.Summe_Bruttoleistung)-1)*100,2) zuwachs_prozent, ROUND(heute.Summe_Bruttoleistung-start.Summe_Bruttoleistung) zuwachs_absolut
FROM statistik_heute_per_ags heute
FULL OUTER JOIN statistik_start_per_ags start ON heute.gemeindeschluessel = start.gemeindeschluessel
WHERE start.Summe_Bruttoleistung > 0 AND heute.gemeindeschluessel IS NOT NULL
ORDER BY heute.Summe_Bruttoleistung/start.Summe_Bruttoleistung DESC;

CREATE OR REPLACE VIEW zuwachs_per_landkreis AS
SELECT heute.gemeindeschluessel, ROUND(start.Summe_Bruttoleistung) Bruttoleistung_start, ROUND(heute.Summe_Bruttoleistung) Bruttoleistung_aktuell, ROUND(((heute.Summe_Bruttoleistung/start.Summe_Bruttoleistung)-1)*100,2) zuwachs_prozent, ROUND(heute.Summe_Bruttoleistung-start.Summe_Bruttoleistung) zuwachs_absolut
FROM (SELECT LEFT(gemeindeschluessel,5)||'000' gemeindeschluessel, SUM(Summe_Bruttoleistung) Summe_Bruttoleistung FROM statistik_heute_per_ags GROUP BY LEFT(gemeindeschluessel,5)||'000') AS heute
FULL OUTER JOIN (SELECT LEFT(gemeindeschluessel,5)||'000' gemeindeschluessel, SUM(Summe_Bruttoleistung) Summe_Bruttoleistung FROM statistik_start_per_ags GROUP BY LEFT(gemeindeschluessel,5)||'000') AS start ON heute.gemeindeschluessel = start.gemeindeschluessel
WHERE start.Summe_Bruttoleistung > 0 AND heute.gemeindeschluessel IS NOT NULL
ORDER BY heute.Summe_Bruttoleistung/start.Summe_Bruttoleistung DESC;

CREATE OR REPLACE VIEW zuwachs_per_bundesland AS
SELECT heute.gemeindeschluessel, ROUND(start.Summe_Bruttoleistung) Bruttoleistung_start, ROUND(heute.Summe_Bruttoleistung) Bruttoleistung_aktuell, ROUND(((heute.Summe_Bruttoleistung/start.Summe_Bruttoleistung)-1)*100,2) zuwachs_prozent, ROUND(heute.Summe_Bruttoleistung-start.Summe_Bruttoleistung) zuwachs_absolut
FROM (SELECT LEFT(gemeindeschluessel,2) gemeindeschluessel, SUM(Summe_Bruttoleistung) Summe_Bruttoleistung FROM statistik_heute_per_ags GROUP BY LEFT(gemeindeschluessel,2)) AS heute
FULL OUTER JOIN (SELECT LEFT(gemeindeschluessel,2) gemeindeschluessel, SUM(Summe_Bruttoleistung) Summe_Bruttoleistung FROM statistik_start_per_ags GROUP BY LEFT(gemeindeschluessel,2)) AS start ON heute.gemeindeschluessel = start.gemeindeschluessel
WHERE start.Summe_Bruttoleistung > 0 AND heute.gemeindeschluessel IS NOT NULL
ORDER BY heute.Summe_Bruttoleistung/start.Summe_Bruttoleistung DESC;

CREATE OR REPLACE VIEW zuwachs_deutschland AS
SELECT ROUND(start.Summe_Bruttoleistung) Bruttoleistung_start, ROUND(heute.Summe_Bruttoleistung) Bruttoleistung_aktuell, ROUND(((heute.Summe_Bruttoleistung/start.Summe_Bruttoleistung)-1)*100,2) zuwachs_prozent, ROUND(heute.Summe_Bruttoleistung-start.Summe_Bruttoleistung) zuwachs_absolut
FROM (SELECT SUM(Summe_Bruttoleistung) Summe_Bruttoleistung FROM statistik_heute_per_ags) AS heute,
  (SELECT SUM(Summe_Bruttoleistung) Summe_Bruttoleistung FROM statistik_start_per_ags) AS start;

