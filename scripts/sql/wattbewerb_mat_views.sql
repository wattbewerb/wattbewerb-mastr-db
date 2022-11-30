SET search_path TO mastr,public;

DROP MATERIALIZED VIEW IF EXISTS statistik_start_per_ags CASCADE;
CREATE MATERIALIZED VIEW statistik_start_per_ags AS
(SELECT ags gemeindeschluessel, IsNBPruefungAbgeschlossen, count(*) anzahl_anlagen, sum(brutto) Summe_Bruttoleistung, sum(netto) Summe_Nettonennleistung FROM 
(SELECT Gemeindeschluessel ags, IsNBPruefungAbgeschlossen, Bruttoleistung brutto, Nettonennleistung netto
FROM mastr
WHERE EnergietraegerId=2495 AND MaStRNummer LIKE 'SEE%' AND BetriebsStatusId=35 AND InbetriebnahmeDatum < '2021-02-13' AND HauptbrennstoffId IS NULL) as anlage
GROUP BY ags, IsNBPruefungAbgeschlossen);

DROP MATERIALIZED VIEW IF EXISTS statistik_start_per_ags_plausibel CASCADE;
CREATE MATERIALIZED VIEW statistik_start_per_ags_plausibel AS
(SELECT ags gemeindeschluessel, count(*) anzahl_anlagen, sum(brutto) Summe_Bruttoleistung, sum(netto) Summe_Nettonennleistung FROM 
(SELECT Gemeindeschluessel ags, Bruttoleistung brutto, Nettonennleistung netto
FROM mastr
WHERE EnergietraegerId=2495 AND MaStRNummer LIKE 'SEE%' AND BetriebsStatusId=35 AND InbetriebnahmeDatum < '2021-02-13' AND HauptbrennstoffId IS NULL
AND MaStRNummer NOT IN (SELECT MaStRNummer FROM checks WHERE check_code <300)
) as anlage
GROUP BY ags);

DROP MATERIALIZED VIEW IF EXISTS statistik_heute_per_ags_plausibel CASCADE;
CREATE MATERIALIZED VIEW statistik_heute_per_ags_plausibel AS
(SELECT ags gemeindeschluessel, count(*) anzahl_anlagen, sum(brutto) Summe_Bruttoleistung, sum(netto) Summe_Nettonennleistung FROM 
(SELECT Gemeindeschluessel ags, Bruttoleistung brutto, Nettonennleistung netto
FROM mastr
WHERE EnergietraegerId=2495 AND MaStRNummer LIKE 'SEE%' AND BetriebsStatusId=35 AND HauptbrennstoffId IS NULL
AND MaStRNummer NOT IN (SELECT MaStRNummer FROM checks WHERE check_code <300)
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
  heute.Summe_Bruttoleistung-start.Summe_Bruttoleistung zuwachs_kwp
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

CREATE VIEW stat_nbpruefung AS
SELECT IsNBPruefungAbgeschlossen, date_trunc('month',EinheitRegistrierungsdatum) RegistrierungsMonat, count(*) Anzahl
FROM mastr.mastr
WHERE energietraegerid=2495
GROUP BY IsNBPruefungAbgeschlossen, date_trunc('month', EinheitRegistrierungsdatum)
ORDER BY IsNBPruefungAbgeschlossen, date_trunc('month', EinheitRegistrierungsdatum);

DROP MATERIALIZED VIEW IF EXISTS letzte_aktualisierung;
CREATE MATERIALIZED VIEW letzte_aktualisierung AS
SELECT MAX(DatumLetzteAktualisierung) zeitpunkt FROM mastr.mastr; 
