DROP MATERIALIZED VIEW statistik_start_per_ags CASCADE;
CREATE MATERIALIZED VIEW statistik_start_per_ags AS
(SELECT ags gemeindeschluessel, IsNBPruefungAbgeschlossen, count(*) anzahl_anlagen, sum(brutto) Summe_Bruttoleistung, sum(netto) Summe_Nettonennleistung FROM 
(SELECT Gemeindeschluessel ags, IsNBPruefungAbgeschlossen, Bruttoleistung brutto, Nettonennleistung netto
FROM mastr
WHERE EnergietraegerId=2495 AND MaStRNummer LIKE 'SEE%' AND BetriebsStatusId=35 AND InbetriebnahmeDatum < '2021-02-13' AND HauptbrennstoffId IS NULL) as anlage
GROUP BY ags, IsNBPruefungAbgeschlossen);

DROP MATERIALIZED VIEW statistik_heute_per_ags CASCADE;
CREATE MATERIALIZED VIEW statistik_heute_per_ags AS
(SELECT ags gemeindeschluessel, IsNBPruefungAbgeschlossen, count(*) anzahl_anlagen, sum(brutto) Summe_Bruttoleistung, sum(netto) Summe_Nettonennleistung FROM 
(SELECT Gemeindeschluessel ags, IsNBPruefungAbgeschlossen, Bruttoleistung brutto, Nettonennleistung netto
FROM mastr
WHERE EnergietraegerId=2495 AND MaStRNummer LIKE 'SEE%' AND BetriebsStatusId=35 AND HauptbrennstoffId IS NULL) as anlage
GROUP BY ags, IsNBPruefungAbgeschlossen);

CREATE OR REPLACE VIEW zuwachs_per_gemeinde AS
SELECT heute_geprueft.gemeindeschluessel, 
  heute_geprueft.anzahl_anlagen anz_geprueft, 
  heute_inpruefung.anzahl_anlagen anz_inpruefung, 
  ROUND(start_geprueft.Summe_Bruttoleistung) Bruttoleistung_start_geprueft, 
  ROUND(heute_geprueft.Summe_Bruttoleistung) Bruttoleistung_aktuell_geprueft,
  ROUND(start_inpruefung.Summe_Bruttoleistung) Bruttoleistung_start_inpruefung, 
  ROUND(heute_inpruefung.Summe_Bruttoleistung) Bruttoleistung_aktuell_inpruefung,
  ROUND(((heute_geprueft.Summe_Bruttoleistung+heute_inpruefung.Summe_Bruttoleistung)/(start_geprueft.Summe_Bruttoleistung+start_inpruefung.Summe_Bruttoleistung)-1)*100,2) zuwachs_prozent
FROM statistik_heute_per_ags heute_geprueft
FULL OUTER JOIN statistik_heute_per_ags heute_inpruefung ON heute_geprueft.gemeindeschluessel = heute_inpruefung.gemeindeschluessel 
FULL OUTER JOIN statistik_start_per_ags start_geprueft ON heute_geprueft.gemeindeschluessel = start_geprueft.gemeindeschluessel 
FULL OUTER JOIN statistik_start_per_ags start_inpruefung ON heute_geprueft.gemeindeschluessel = start_inpruefung.gemeindeschluessel 
WHERE heute_geprueft.IsNBPruefungAbgeschlossen=2954
  AND start_geprueft.IsNBPruefungAbgeschlossen=2954
  AND start_inpruefung.IsNBPruefungAbgeschlossen=2955
  AND heute_inpruefung.IsNBPruefungAbgeschlossen=2955
  AND (start_geprueft.Summe_Bruttoleistung + start_inpruefung.Summe_Bruttoleistung) > 0 AND heute_geprueft.gemeindeschluessel IS NOT NULL
ORDER BY (heute_geprueft.Summe_Bruttoleistung+heute_inpruefung.Summe_Bruttoleistung)/(start_geprueft.Summe_Bruttoleistung + start_inpruefung.Summe_Bruttoleistung) DESC;

CREATE OR REPLACE VIEW zuwachs_per_landkreis AS
SELECT gemeindeschluessel, anz_geprueft, anz_inpruefung, Bruttoleistung_start_geprueft, Bruttoleistung_aktuell_geprueft, Bruttoleistung_start_inpruefung, Bruttoleistung_aktuell_inpruefung,
ROUND(((Bruttoleistung_aktuell_geprueft+Bruttoleistung_aktuell_inpruefung)/(Bruttoleistung_start_geprueft+Bruttoleistung_start_inpruefung)-1)*100,2) zuwachs_prozent
FROM (SELECT LEFT(gemeindeschluessel,5)||'000' gemeindeschluessel, 
	SUM(anz_geprueft) anz_geprueft, SUM(anz_inpruefung) anz_inpruefung, 
	SUM(Bruttoleistung_start_geprueft) Bruttoleistung_start_geprueft,
	SUM(Bruttoleistung_aktuell_geprueft) Bruttoleistung_aktuell_geprueft,
	SUM(Bruttoleistung_start_inpruefung) Bruttoleistung_start_inpruefung,
	SUM(Bruttoleistung_aktuell_inpruefung) Bruttoleistung_aktuell_inpruefung
 FROM zuwachs_per_gemeinde GROUP BY LEFT(gemeindeschluessel,5)||'000') landkreis
ORDER BY (Bruttoleistung_aktuell_geprueft+Bruttoleistung_aktuell_inpruefung)/(Bruttoleistung_start_geprueft+Bruttoleistung_start_inpruefung) DESC;

CREATE OR REPLACE VIEW zuwachs_per_bundesland AS
SELECT gemeindeschluessel, anz_geprueft, anz_inpruefung, Bruttoleistung_start_geprueft, Bruttoleistung_aktuell_geprueft, Bruttoleistung_start_inpruefung, Bruttoleistung_aktuell_inpruefung,
ROUND(((Bruttoleistung_aktuell_geprueft+Bruttoleistung_aktuell_inpruefung)/(Bruttoleistung_start_geprueft+Bruttoleistung_start_inpruefung)-1)*100,2) zuwachs_prozent
FROM (SELECT LEFT(gemeindeschluessel,2) gemeindeschluessel, 
	SUM(anz_geprueft) anz_geprueft, SUM(anz_inpruefung) anz_inpruefung, 
	SUM(Bruttoleistung_start_geprueft) Bruttoleistung_start_geprueft,
	SUM(Bruttoleistung_aktuell_geprueft) Bruttoleistung_aktuell_geprueft,
	SUM(Bruttoleistung_start_inpruefung) Bruttoleistung_start_inpruefung,
	SUM(Bruttoleistung_aktuell_inpruefung) Bruttoleistung_aktuell_inpruefung
 FROM zuwachs_per_gemeinde GROUP BY LEFT(gemeindeschluessel,2)) land
ORDER BY (Bruttoleistung_aktuell_geprueft+Bruttoleistung_aktuell_inpruefung)/(Bruttoleistung_start_geprueft+Bruttoleistung_start_inpruefung) DESC;


-- Netzbetreiberprüfung ausstehend
DROP MATERIALIZED VIEW nbpruefung_je_netzbetreiber;
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

