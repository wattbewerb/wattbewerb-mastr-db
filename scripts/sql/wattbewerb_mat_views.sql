SET search_path TO mastr,public;

DROP MATERIALIZED VIEW IF EXISTS statistik_start_per_ags CASCADE;
CREATE MATERIALIZED VIEW statistik_start_per_ags AS
(SELECT ags gemeindeschluessel, IsNBPruefungAbgeschlossen, count(*) anzahl_anlagen, sum(brutto) Summe_Bruttoleistung, sum(netto) Summe_Nettonennleistung FROM 
(SELECT Gemeindeschluessel ags, IsNBPruefungAbgeschlossen, Bruttoleistung brutto, Nettonennleistung netto
FROM mastr
WHERE EnergietraegerId=2495 AND MaStRNummer LIKE 'SEE%' AND BetriebsStatusId=35 AND InbetriebnahmeDatum < '2021-02-21' AND HauptbrennstoffId IS NULL) as anlage
GROUP BY ags, IsNBPruefungAbgeschlossen);

DROP MATERIALIZED VIEW IF EXISTS statistik_ende_wbw1_per_ags CASCADE;
CREATE MATERIALIZED VIEW statistik_ende_wbw1_per_ags AS
(SELECT ags gemeindeschluessel, count(*) anzahl_anlagen, sum(brutto) Summe_Bruttoleistung, sum(netto) Summe_Nettonennleistung FROM 
(SELECT Gemeindeschluessel ags, Bruttoleistung brutto, Nettonennleistung netto
FROM mastr
WHERE EnergietraegerId=2495 AND MaStRNummer LIKE 'SEE%' AND BetriebsStatusId=35 AND InbetriebnahmeDatum < '2023-10-01' AND HauptbrennstoffId IS NULL) as anlage
GROUP BY ags);


DROP MATERIALIZED VIEW IF EXISTS statistik_start_per_ags_plausibel CASCADE;
CREATE MATERIALIZED VIEW statistik_start_per_ags_plausibel AS
(SELECT ags gemeindeschluessel, count(*) anzahl_anlagen, sum(brutto) Summe_Bruttoleistung, sum(netto) Summe_Nettonennleistung FROM 
(SELECT Gemeindeschluessel ags, Bruttoleistung brutto, Nettonennleistung netto
FROM mastr
WHERE EnergietraegerId=2495 AND MaStRNummer LIKE 'SEE%' AND BetriebsStatusId=35 AND InbetriebnahmeDatum < '2021-02-21' AND HauptbrennstoffId IS NULL
AND MaStRNummer NOT IN (SELECT MaStRNummer FROM checks WHERE check_code <220)
) as anlage
GROUP BY ags);

DROP MATERIALIZED VIEW IF EXISTS statistik_heute_per_ags_plausibel CASCADE;
CREATE MATERIALIZED VIEW statistik_heute_per_ags_plausibel AS
(SELECT ags gemeindeschluessel, count(*) anzahl_anlagen, sum(brutto) Summe_Bruttoleistung, sum(netto) Summe_Nettonennleistung FROM 
(SELECT Gemeindeschluessel ags, Bruttoleistung brutto, Nettonennleistung netto
FROM mastr
WHERE EnergietraegerId=2495 AND MaStRNummer LIKE 'SEE%' AND BetriebsStatusId=35 AND HauptbrennstoffId IS NULL
AND MaStRNummer NOT IN (SELECT MaStRNummer FROM checks WHERE check_code <220)
) as anlage
GROUP BY ags);

DROP MATERIALIZED VIEW IF EXISTS statistik_heute_per_ags CASCADE;
CREATE MATERIALIZED VIEW statistik_heute_per_ags AS
(SELECT ags gemeindeschluessel, IsNBPruefungAbgeschlossen, count(*) anzahl_anlagen, sum(brutto) Summe_Bruttoleistung, sum(netto) Summe_Nettonennleistung FROM 
(SELECT Gemeindeschluessel ags, IsNBPruefungAbgeschlossen, Bruttoleistung brutto, Nettonennleistung netto
FROM mastr
WHERE EnergietraegerId=2495 AND MaStRNummer LIKE 'SEE%' AND BetriebsStatusId=35 AND HauptbrennstoffId IS NULL) as anlage
GROUP BY ags, IsNBPruefungAbgeschlossen);

CREATE OR REPLACE VIEW zuwachs_per_gemeinde AS
SELECT heute_geprueft.gemeindeschluessel,
  start_geprueft.anzahl_anlagen AS anz_start_geprueft,
  COALESCE(start_inpruefung.anzahl_anlagen, 0) AS anz_start_inpruefung,
  COALESCE(heute_geprueft.anzahl_anlagen, 0) AS anz_heute_geprueft,
  COALESCE(heute_inpruefung.anzahl_anlagen, 0) AS anz_heute_inpruefung,
  round(COALESCE(start_geprueft.summe_bruttoleistung,0)) AS bruttoleistung_start_geprueft,
  round(COALESCE(heute_geprueft.summe_bruttoleistung,0)) AS bruttoleistung_aktuell_geprueft,
  round(COALESCE(start_inpruefung.summe_bruttoleistung, 0)) AS bruttoleistung_start_inpruefung,
  round(COALESCE(heute_inpruefung.summe_bruttoleistung, 0)) AS bruttoleistung_aktuell_inpruefung,
  round((COALESCE(heute_geprueft.summe_bruttoleistung, 0) + COALESCE(heute_inpruefung.summe_bruttoleistung,0)) - (COALESCE(start_geprueft.summe_bruttoleistung,0) + COALESCE(start_inpruefung.summe_bruttoleistung, 0)), 2) AS zuwachs_kwp,
  round(((COALESCE(heute_geprueft.summe_bruttoleistung,0) + COALESCE(heute_inpruefung.summe_bruttoleistung,0)) / (COALESCE(start_geprueft.summe_bruttoleistung,0) + COALESCE(start_inpruefung.summe_bruttoleistung, 0)) - 1::numeric) * 100::numeric, 2) AS zuwachs_prozent
  FROM mastr.statistik_heute_per_ags heute_geprueft
   FULL JOIN mastr.statistik_heute_per_ags heute_inpruefung ON heute_geprueft.gemeindeschluessel = heute_inpruefung.gemeindeschluessel AND heute_inpruefung.isnbpruefungabgeschlossen = 2955
   FULL JOIN mastr.statistik_start_per_ags start_geprueft ON heute_geprueft.gemeindeschluessel = start_geprueft.gemeindeschluessel AND start_geprueft.isnbpruefungabgeschlossen = 2954
   FULL JOIN mastr.statistik_start_per_ags start_inpruefung ON heute_geprueft.gemeindeschluessel = start_inpruefung.gemeindeschluessel AND (start_inpruefung.isnbpruefungabgeschlossen = 2955 or start_inpruefung.isnbpruefungabgeschlossen is null)
 WHERE 
   heute_geprueft.isnbpruefungabgeschlossen = 2954
  AND
   COALESCE(start_geprueft.summe_bruttoleistung,0) + coalesce(start_inpruefung.summe_bruttoleistung, 0) > 0::numeric
  AND 
   heute_geprueft.gemeindeschluessel IS NOT null
 ORDER BY ((COALESCE(heute_geprueft.summe_bruttoleistung,0) + COALESCE(heute_inpruefung.summe_bruttoleistung,0)) / (COALESCE(start_geprueft.summe_bruttoleistung,0) + COALESCE(start_inpruefung.summe_bruttoleistung, 0))) DESC;      

CREATE OR REPLACE VIEW zuwachs_per_gemeinde_plausibel AS
SELECT heute.gemeindeschluessel, 
  start.anzahl_anlagen anz_start, 
  heute.anzahl_anlagen anz_heute,
  ROUND(start.Summe_Bruttoleistung) Bruttoleistung_start,
  ROUND(heute.Summe_Bruttoleistung) Bruttoleistung_aktuell,
  heute.Summe_Bruttoleistung-start.Summe_Bruttoleistung zuwachs_kwp,
  round(((heute.Summe_Bruttoleistung-start.Summe_Bruttoleistung)/start.Summe_Bruttoleistung - 1::numeric) * 100::numeric, 2) AS zuwachs_prozent
FROM statistik_heute_per_ags_plausibel heute
FULL OUTER JOIN statistik_start_per_ags_plausibel start ON heute.gemeindeschluessel = start.gemeindeschluessel 
WHERE start.Summe_Bruttoleistung > 0 AND heute.gemeindeschluessel IS NOT NULL
ORDER BY (heute.Summe_Bruttoleistung-start.Summe_Bruttoleistung) DESC;


CREATE OR REPLACE VIEW zuwachs_per_landkreis AS
SELECT gemeindeschluessel, anz_heute_geprueft, anz_heute_inpruefung, Bruttoleistung_start_geprueft, Bruttoleistung_aktuell_geprueft, Bruttoleistung_start_inpruefung, Bruttoleistung_aktuell_inpruefung,
ROUND(((Bruttoleistung_aktuell_geprueft+Bruttoleistung_aktuell_inpruefung)/(Bruttoleistung_start_geprueft+Bruttoleistung_start_inpruefung)-1)*100,2) zuwachs_prozent
FROM (SELECT LEFT(gemeindeschluessel,5)||'000' gemeindeschluessel, 
	SUM(anz_heute_geprueft) anz_heute_geprueft, SUM(anz_heute_inpruefung) anz_heute_inpruefung, 
	SUM(Bruttoleistung_start_geprueft) Bruttoleistung_start_geprueft,
	SUM(Bruttoleistung_aktuell_geprueft) Bruttoleistung_aktuell_geprueft,
	SUM(Bruttoleistung_start_inpruefung) Bruttoleistung_start_inpruefung,
	SUM(Bruttoleistung_aktuell_inpruefung) Bruttoleistung_aktuell_inpruefung
 FROM zuwachs_per_gemeinde GROUP BY LEFT(gemeindeschluessel,5)||'000') landkreis
ORDER BY (Bruttoleistung_aktuell_geprueft+Bruttoleistung_aktuell_inpruefung)/(Bruttoleistung_start_geprueft+Bruttoleistung_start_inpruefung) DESC;

CREATE OR REPLACE VIEW zuwachs_per_bundesland AS
SELECT gemeindeschluessel, anz_heute_geprueft, anz_heute_inpruefung, Bruttoleistung_start_geprueft, Bruttoleistung_aktuell_geprueft, Bruttoleistung_start_inpruefung, Bruttoleistung_aktuell_inpruefung,
ROUND(((Bruttoleistung_aktuell_geprueft+Bruttoleistung_aktuell_inpruefung)/(Bruttoleistung_start_geprueft+Bruttoleistung_start_inpruefung)-1)*100,2) zuwachs_prozent
FROM (SELECT LEFT(gemeindeschluessel,2) gemeindeschluessel, 
	SUM(anz_heute_geprueft) anz_heute_geprueft, SUM(anz_heute_inpruefung) anz_heute_inpruefung, 
	SUM(Bruttoleistung_start_geprueft) Bruttoleistung_start_geprueft,
	SUM(Bruttoleistung_aktuell_geprueft) Bruttoleistung_aktuell_geprueft,
	SUM(Bruttoleistung_start_inpruefung) Bruttoleistung_start_inpruefung,
	SUM(Bruttoleistung_aktuell_inpruefung) Bruttoleistung_aktuell_inpruefung
 FROM zuwachs_per_gemeinde GROUP BY LEFT(gemeindeschluessel,2)) land
ORDER BY (Bruttoleistung_aktuell_geprueft+Bruttoleistung_aktuell_inpruefung)/(Bruttoleistung_start_geprueft+Bruttoleistung_start_inpruefung) DESC;


-- Netzbetreiberprüfung ausstehend
DROP MATERIALIZED VIEW IF EXISTS nbpruefung_je_netzbetreiber CASCADE;
CREATE MATERIALIZED VIEW nbpruefung_je_netzbetreiber AS
SELECT NetzbetreiberMaskedNamen, IsNBPruefungAbgeschlossen, COUNT(*)
FROM mastr
WHERE EnergietraegerId=2495
GROUP BY NetzbetreiberMaskedNamen,IsNBPruefungAbgeschlossen;

CREATE OR REPLACE VIEW anlagen_in_pruefung AS
SELECT ungeprueft.NetzbetreiberMaskedNamen, geprueft.count geprueft, ungeprueft.count in_pruefung, ROUND(100.0 * ungeprueft.count / (geprueft.count + ungeprueft.count),1) prozent_in_pruefung
FROM nbpruefung_je_netzbetreiber ungeprueft
FULL OUTER JOIN nbpruefung_je_netzbetreiber geprueft ON ungeprueft.NetzbetreiberMaskedNamen = geprueft.NetzbetreiberMaskedNamen
WHERE ungeprueft.IsNBPruefungAbgeschlossen=2955
AND geprueft.IsNBPruefungAbgeschlossen=2954
ORDER BY in_pruefung DESC;

DROP VIEW IF EXISTS stat_ranking;
CREATE OR REPLACE VIEW stat_ranking AS
SELECT t.*, z.*, ROUND(zuwachs_kwp/residents*1000,2) zuwachs_watt_per_ew FROM TEILNEHMER t
LEFT JOIN zuwachs_per_gemeinde z ON t.ags = z.gemeindeschluessel
ORDER BY zuwachs_kwp/residents DESC;

DROP VIEW IF EXISTS stat_ranking_plausibel;
CREATE OR REPLACE VIEW stat_ranking_plausibel AS
SELECT t.*, z.*, ROUND(zuwachs_kwp/residents*1000,2) zuwachs_watt_per_ew FROM TEILNEHMER t
LEFT JOIN zuwachs_per_gemeinde_plausibel z ON t.ags = z.gemeindeschluessel
ORDER BY zuwachs_kwp/residents DESC;

DROP VIEW IF EXISTS stat_ranking_nur_plausible;
CREATE OR REPLACE VIEW stat_ranking_nur_plausible AS
SELECT t.*, z.*, ROUND((zuwachs_kwp-bruttoleistung_unplausibel)/residents*1000,2) zuwachs_watt_per_ew FROM TEILNEHMER t
LEFT JOIN zuwachs_per_gemeinde z ON t.ags = z.gemeindeschluessel
LEFT JOIN unplausible_bruttoleistung_je_gemeinde b ON t.ags = b.gemeindeschluessel
ORDER BY (zuwachs_kwp-bruttoleistung_unplausibel)/residents DESC;


CREATE OR REPLACE VIEW zuwachs_ende_wbw1_per_gemeinde AS
SELECT statistik_ende_wbw1_per_ags.gemeindeschluessel,
  start_geprueft.anzahl_anlagen AS anz_start_geprueft,
  COALESCE(start_inpruefung.anzahl_anlagen, 0) AS anz_start_inpruefung,
  COALESCE(statistik_ende_wbw1_per_ags.anzahl_anlagen, 0) AS anz_ende_wbw1,
  round(COALESCE(start_geprueft.summe_bruttoleistung,0)) AS bruttoleistung_start_geprueft,
  round(COALESCE(statistik_ende_wbw1_per_ags.summe_bruttoleistung,0)) AS bruttoleistung_ende_wbw1,
  round(COALESCE(start_inpruefung.summe_bruttoleistung, 0)) AS bruttoleistung_start_inpruefung,
  round(COALESCE(statistik_ende_wbw1_per_ags.summe_bruttoleistung, 0) - (COALESCE(start_geprueft.summe_bruttoleistung,0) + COALESCE(start_inpruefung.summe_bruttoleistung, 0)), 2) AS zuwachs_kwp
  FROM mastr.statistik_ende_wbw1_per_ags 
   FULL JOIN mastr.statistik_start_per_ags start_geprueft ON statistik_ende_wbw1_per_ags.gemeindeschluessel = start_geprueft.gemeindeschluessel AND start_geprueft.isnbpruefungabgeschlossen = 2954
   FULL JOIN mastr.statistik_start_per_ags start_inpruefung ON statistik_ende_wbw1_per_ags.gemeindeschluessel = start_inpruefung.gemeindeschluessel AND (start_inpruefung.isnbpruefungabgeschlossen = 2955 or start_inpruefung.isnbpruefungabgeschlossen is null)
 WHERE 
   COALESCE(start_geprueft.summe_bruttoleistung,0) + coalesce(start_inpruefung.summe_bruttoleistung, 0) > 0::numeric
  AND 
   statistik_ende_wbw1_per_ags.gemeindeschluessel IS NOT null
 ORDER BY (COALESCE(statistik_ende_wbw1_per_ags.summe_bruttoleistung,0) / (COALESCE(start_geprueft.summe_bruttoleistung,0) + COALESCE(start_inpruefung.summe_bruttoleistung, 0))) DESC;      


DROP VIEW IF EXISTS stat_ranking_final;
CREATE OR REPLACE VIEW stat_ranking_final AS
SELECT t.*,  anz_start_geprueft + anz_start_inpruefung anz_start, anz_ende_wbw1,
  bruttoleistung_start_geprueft + bruttoleistung_start_inpruefung bruttoleistung_start, bruttoleistung_ende_wbw1, zuwachs_kwp,
 ROUND(zuwachs_kwp/residents*1000,2) zuwachs_watt_per_ew FROM TEILNEHMER t
LEFT JOIN zuwachs_ende_wbw1_per_gemeinde z ON t.ags = z.gemeindeschluessel
ORDER BY zuwachs_kwp/residents DESC;


DROP MATERIALIZED VIEW IF EXISTS letzte_aktualisierung;
CREATE MATERIALIZED VIEW letzte_aktualisierung AS
SELECT MAX(DatumLetzteAktualisierung) zeitpunkt FROM mastr.mastr; 

DROP MATERIALIZED VIEW IF EXISTS stats_ranking_alle;
CREATE MATERIALIZED VIEW stats_ranking_alle AS
SELECT substr(ags, 1,5) kreis, t.gen || ' ' || t.bez "Gemeinde", 
       bruttoleistung_aktuell_geprueft +bruttoleistung_aktuell_inpruefung "Brutto kWp",
       t.ewz "EWZ", 
       ROUND((bruttoleistung_aktuell_geprueft +bruttoleistung_aktuell_inpruefung )/ewz*1000.,2) watt_per_ew,
       ROUND(zuwachs_kwp/ewz*1000.,2) zuwachs_watt_per_ew,
       ROUND((bruttoleistung_aktuell_geprueft +bruttoleistung_aktuell_inpruefung)/(bruttoleistung_start_geprueft +bruttoleistung_start_inpruefung)*100-100,1) "Zuwachs in % seit Start Wbw",
       z.*
  FROM mastr.vg250_gem t
  LEFT JOIN mastr.zuwachs_per_gemeinde z ON t.ags = z.gemeindeschluessel
WHERE gf=4 
  AND ewz > 0
  AND substr(ags, 1,5) ='05158'
ORDER BY zuwachs_kwp/ewz DESC;

DROP VIEW IF EXISTS mastr.stat_ranking_2_0;
CREATE VIEW mastr.stat_ranking_2_0 AS
SELECT 
    substr(t.ags, 1, 2) AS landschluessel,
    substr(t.ags, 1, 5) AS kreisschluessel,
    z.gemeindeschluessel,
    substr(t.ars, 1, 9) verbandschluessel,
    t.ars regionalschluessel,
    t.bez AS bezeichnung,
    t.gen AS name,
    t.ewz,
    round((z.bruttoleistung_aktuell_geprueft + z.bruttoleistung_aktuell_inpruefung) * 1000.0 / t.ewz, 2) AS watt_per_ew,
    round(z.zuwachs_kwp * 1000.0 / t.ewz , 2) AS zuwachs_watt_per_ew,
    z.zuwachs_prozent AS zuwachs_watt_prozent,
    z.anz_start_geprueft + z.anz_start_inpruefung AS anzahl_start,
    z.anz_heute_geprueft + z.anz_heute_inpruefung AS anzahl_aktuell,
    z.bruttoleistung_start_geprueft + z.bruttoleistung_start_inpruefung AS brutoleistung_start_kwp,
    z.bruttoleistung_aktuell_geprueft + z.bruttoleistung_aktuell_inpruefung AS brutoleistung_aktuell_kwp,
    z.zuwachs_kwp
   FROM mastr.vg250_gem t
     LEFT JOIN mastr.zuwachs_per_gemeinde z ON t.ags = z.gemeindeschluessel
  WHERE t.gf = 4 AND t.ewz > 0;

DROP VIEW IF EXISTS mastr.mastr_mit_ars;
CREATE VIEW mastr.mastr_mit_ars AS
SELECT substr(ags,1,2) landschluessel, substr(ags, 1,5) kreisschluessel, substr(ars,1,9) verbandschluessel, ars regiooalschluessel, m.*
  FROM  mastr.vg250_gem g
  JOIN mastr.mastr m ON g.ags= m.gemeindeschluessel 
  WHERE gf=4;

CREATE MATERIALIZED VIEW mastr.pv_groessenklassen_je_ags AS
(SELECT groessenklasse, substr(gemeindeschluessel,1,2) landschluessel, substr(gemeindeschluessel,1,5) kreisschluessel,gemeindeschluessel, SUM(bruttoleistung) bruttoleistung, COUNT(bruttoleistung) Anzahl
  FROM
(SELECT CASE WHEN bruttoleistung<0.8 THEN '< 0,8 kW' 
            WHEN bruttoleistung<10 THEN '>= 0,8 und < 10 kW' 
            WHEN bruttoleistung<20 THEN '>= 10 und < 20 kW' 
            WHEN bruttoleistung<30 THEN '>= 20 und < 30 kW' 
            WHEN bruttoleistung<100 THEN '>= 30 und < 100 kW' 
            ELSE 'ab 100 kW' 
       END groessenklasse, bruttoleistung, gemeindeschluessel  
     FROM mastr.mastr 
    WHERE betriebsstatusid=35 
      AND energietraegerid=2495
) AS A GROUP BY groessenklasse,gemeindeschluessel);
