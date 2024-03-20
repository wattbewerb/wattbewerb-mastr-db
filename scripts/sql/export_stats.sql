SET search_path=mastr,public;

--	.header on

\COPY (select * from stat_ranking) TO 'out/ranking.csv' DELIMITER ',' CSV HEADER;
--\COPY (select * from stat_nbpruefung) TO 'out/nbpruefung.csv' DELIMITER ',' CSV HEADER;
-- https://app.datawrapper.de/chart/enNPh/visualize#refine
\COPY ( SELECT * FROM stats_auffaelligkeiten_staedte ORDER BY "Unplausible Brutttoleistung"+"Unplausible Brutttoleistung mit Koordinatenveröffentlichung"+"Unplausibles Inbetriebnahmedatum" DESC ) TO 'out/datawrapper_unplausibel.csv' WITH CSV DELIMITER '	' HEADER;

-- datawrapper_prozentzuwachs_vs_start
\COPY (SELECT name, (bruttoleistung_start_geprueft+bruttoleistung_start_inpruefung)/residents   startwert, (bruttoleistung_aktuell_geprueft + bruttoleistung_aktuell_inpruefung)/residents "Leistung[kWp]/EW", zuwachs_prozent "Zuwachs in %", zuwachs_kwp/residents "Zuwachs [kWp]/EW", case WHEN residents < 100000 then 'K' ELSE 'G' end "Klasse" from zuwachs_per_gemeinde z JOIN teilnehmer t ON gemeindeschluessel=t.ags ORDER BY zuwachs_kwp/residents DESC) TO 'out/datawrapper_prozentzuwachs_vs_start.csv' WITH CSV DELIMITER '	' HEADER;

-- wattbewerb_unplausible_anlagen
\COPY (SELECT * FROM checks WHERE check_code < 300) TO 'out/wattbewerb_unplausible_anlagen.csv' WITH CSV DELIMITER ';' HEADER;

-- wattbewerb_unplausible_anlagen_08226
\COPY (SELECT * FROM checks WHERE check_code < 300 AND gemeindeschluessel like '08226%' ORDER BY bruttoleistung DESC) TO 'out/wattbewerb_unplausible_anlagen_08226.csv' WITH CSV DELIMITER ';' HEADER;

-- datawrapper_netzbetreiber_unplausible_bruttoleistung
\COPY (SELECT left(netzbetreibernamen, position('(' in netzbetreibernamen)-2) "Netzbetreiber", count(*) "Anzahl", sum(bruttoleistung) "Summe unplausible Bruttoleistung [kWp]", to_timestamp(avg(extract(epoch from datumletzteaktualisierung)))::date "Durchschnittsdatum Letzte Aktualisierung"  FROM checks WHERE check_code < 300 group by netzbetreibernamen order by sum(bruttoleistung) DESC) TO 'out/datawrapper_netzbetreiber_unplausible_bruttoleistung.csv' WITH CSV DELIMITER ';' HEADER;

--datawrapper_karte_unplausibilitaeten
\COPY (SELECT SUBSTRING(gemeindeschluessel,1,5) Code, COUNT(*) "Anzahl Anlagen", SUM(bruttoleistung) "Bruttoleistung" FROM checks WHERE check_code BETWEEN 200 and 210 GROUP BY SUBSTRING(gemeindeschluessel,1,5)) TO 'out/datawrapper_karte_unplausibilitaeten.csv' WITH CSV DELIMITER ',' HEADER;

-- wattbewerb_unplausible_anlagen_teilnehmer
\COPY (SELECT t.name, c.* FROM checks c JOIN teilnehmer t ON t.ags = c.gemeindeschluessel WHERE check_code < 300 ORDER BY t.ags, c.bruttoleistung DESC) TO 'out/wattbewerb_unplausible_anlagen_teilnehmer.csv' WITH CSV DELIMITER ';' HEADER;

--datawrapper_bruttoleistung_je_modul_letzte_woche
\COPY (select mastrnummer "MaStR-Nummer", bruttoleistung/AnzahlSolarModule "Leistung je Modul [kWp/Modul]", AnzahlSolarModule "Anzahl Module",  bruttoleistung "Bruttoleistung [kWp]", case when bruttoleistung/AnzahlSolarModule > 0.9 then 'Ja' else 'Nein' end "Unplausibel" from mastr where InbetriebnahmeDatum > (current_date - 9)  and EnergietraegerId=2495 and AnzahlSolarModule is not null and bruttoleistung > 0 and BetriebsStatusid=35) TO 'out/datawrapper_bruttoleistung_je_modul_letzte_woche.csv' WITH CSV DELIMITER ',' HEADER;

--datawrapper_bruttoleistung_je_modul_letzte_woche_aggr
\COPY (SELECT "Unplausibel", sum("Bruttoleistung [kWp]") "Summe Bruttoleistung [kWp]", Count(*) "Anzahl" FROM (select bruttoleistung/AnzahlSolarModule "Leistung je Modul", AnzahlSolarModule "Anzahl Module", bruttoleistung "Bruttoleistung [kWp]", case when bruttoleistung/AnzahlSolarModule > 0.9 then 'Unpausibel' else 'Plausibel' end "Unplausibel" from mastr where InbetriebnahmeDatum > (current_date - 9) and EnergietraegerId=2495 and AnzahlSolarModule is not null and bruttoleistung > 0 and BetriebsStatusid=35) unplausible_anla GROUP BY "Unplausibel") TO 'out/datawrapper_bruttoleistung_je_modul_letzte_woche_aggr.csv' WITH CSV DELIMITER ',' HEADER;

-- datawrapper_unplausible_anlagen_netze_bw
\COPY (select TO_CHAR(einheitmeldedatum :: DATE, 'YYYY-MM-DD')  Meldedatum, c.bruttoleistung, check_code,check_name,beschreibung,c.gemeindeschluessel ,c.mastrnummer,c.isnbpruefungabgeschlossen, TO_CHAR(m.EegInbetriebnahmeDatum, 'YYYY-MM-DD') InbetriebnahmeDatum from mastr.checks c join mastr.mastr m on c.mastrnummer=m.mastrnummer where c.netzbetreibernamen like 'Netze BW%' order by bruttoleistung desc) TO 'out/datawrapper_unplausible_anlagen_netze_bw.csv' WITH CSV DELIMITER ',' FORCE QUOTE gemeindeschluessel HEADER;

-- datawrapper_unplausible_anlagen_bayernwerk
\COPY (select TO_CHAR(einheitmeldedatum :: DATE, 'YYYY-MM-DD')  "Meldedatum", c.bruttoleistung "Bruttoleistung [kWp]", check_code,check_name,beschreibung,c.gemeindeschluessel ,c.mastrnummer,c.isnbpruefungabgeschlossen, TO_CHAR(m.EegInbetriebnahmeDatum, 'YYYY-MM-DD') InbetriebnahmeDatum from mastr.checks c join mastr.mastr m on c.mastrnummer=m.mastrnummer where c.netzbetreibernamen like 'Bayernwerk%' order by c.bruttoleistung desc) TO 'out/datawrapper_unplausible_anlagen_bayernwerk.csv' WITH CSV DELIMITER ',' FORCE QUOTE gemeindeschluessel HEADER;

-- out/datawrapper_unplausible_bruttoleistung_nach_betreiber.csv
\COPY (SELECT LEFT(c.netzbetreibernamen, position(')' IN c.netzbetreibernamen)) "Netzbetreiberin", sum(c.bruttoleistung) "Summe Bruttoleistung [kWp]" FROM mastr.checks c GROUP BY left(c.netzbetreibernamen, position(')' IN c.netzbetreibernamen)) ORDER BY sum(bruttoleistung) DESC) TO 'out/datawrapper_unplausible_bruttoleistung_nach_betreiber.csv' WITH CSV DELIMITER ',' HEADER;

-- out/datawrapper_karte_unplausible_anlagen.csv
\COPY (SELECT c.mastrnummer, Breitengrad, Laengengrad, m.bruttoleistung FROM mastr.checks c  JOIN mastr.mastr m on c.mastrnummer=m.mastrnummer  WHERE check_code=210 ORDER BY m.bruttoleistung DESC LIMIT 10)  TO 'out/datawrapper_karte_unplausible_anlagen.csv' WITH CSV DELIMITER ',' HEADER;
-- out/datawrapper_karte_anlagen_top20
\COPY (Select t.name "Gemeinde", m.inbetriebnahmedatum "Inbetriebnahmedatum", m.gemeindeschluessel "Gemeindeschlüssel", breitengrad "lat" ,laengengrad "lon", m.mastrnummer "MaStR-Nummer", m.bruttoleistung "Bruttoleistung [kWp]", CASE WHEN c.mastrnummer IS NULL THEN 'Plausibel' ELSE 'Unplausibel' END "Plausibel?" from mastr.mastr m LEFT OUTER JOIN mastr.checks c ON m.mastrnummer=c.mastrnummer JOIN mastr.teilnehmer t ON m.gemeindeschluessel=t.ags where energietraegerid=2495 and betriebsstatusid=35 order by m.bruttoleistung desc limit 20) TO 'out/datawrapper_karte_anlagen_top20.csv' WITH CSV DELIMITER ',' HEADER;

-- out/datawrapper_karte_anlagen_top20_aggr
\COPY (SELECT 'Gesamt' "Rubrik", sum(bruttoleistung) "Bruttoleistung [kWp]", count(*) "Anzahl" FROM (Select  m.bruttoleistung from mastr.mastr m  where energietraegerid=2495 and betriebsstatusid=35 order by m.bruttoleistung desc limit 20) anlagen UNION SELECT cat "Rubrik", sum(bruttoleistung) "Bruttoleistung [kWp]", count(*) "Anzahl" FROM (	Select m.bruttoleistung, CASE WHEN c.mastrnummer IS NULL THEN 'Plausibel' ELSE 'Unplausibel' END cat from mastr.mastr m LEFT OUTER JOIN mastr.checks c ON m.mastrnummer=c.mastrnummer where energietraegerid=2495 and betriebsstatusid=35 order by m.bruttoleistung desc limit 20) an GROUP BY cat ) TO 'out/datawrapper_karte_anlagen_top20_aggr.csv' WITH CSV DELIMITER ',' HEADER;

\COPY (SELECT t.name, u.gemeindeschluessel, summe_unplausibel "Gesamt-Bruttleistung unplausibel [kWp]", g.Summe_Bruttoleistung-summe_unplausibel "Gesamt-Bruttleistung plausibel [kWp]", ROUND(100*summe_unplausibel/g.Summe_Bruttoleistung) "Prozent unplausibel", 100-ROUND(100*(summe_unplausibel/g.Summe_Bruttoleistung)) "Prozent plausibel" FROM (SELECT c.gemeindeschluessel,sum(c.bruttoleistung) summe_unplausibel FROM checks c WHERE c.check_code between 100 and 299 GROUP BY c.gemeindeschluessel) u JOIN teilnehmer t ON t.ags=u.gemeindeschluessel JOIN (SELECT gemeindeschluessel, sum(summe_bruttoleistung) summe_bruttoleistung FROM statistik_heute_per_ags GROUP BY gemeindeschluessel) g ON g.gemeindeschluessel = u.gemeindeschluessel) TO 'out/datawrapper_unplausible_uebersicht.csv' WITH CSV DELIMITER ',' HEADER;
 ;

--, ROUND(100*summe_unplausibel/g.Summe_Bruttoleistung) "Prozent unplausibel", 100-ROUND(100*(summe_unplausibel/g.Summe_Bruttoleistung)) "Prozent plausibel" 
\COPY (SELECT t.name, u.gemeindeschluessel, summe_unplausibel "Gesamt-Bruttleistung unplausibel [kWp]", g.Summe_Bruttoleistung-summe_unplausibel "Gesamt-Bruttleistung plausibel [kWp]" FROM (SELECT c.gemeindeschluessel,sum(c.bruttoleistung) summe_unplausibel FROM checks c  JOIN MASTR m ON c.mastrnummer=m.mastrnummer WHERE m.inbetriebnahmedatum > '2021-02-21'	AND BetriebsStatusId=35 AND c.check_code between 100 and 299 GROUP BY c.gemeindeschluessel) u JOIN teilnehmer t ON t.ags=u.gemeindeschluessel JOIN (SELECT gemeindeschluessel, sum(bruttoleistung) summe_bruttoleistung FROM mastr WHERE EnergietraegerId=2495 AND BetriebsStatusid=35 AND InbetriebnahmeDatum > '2021-02-21' GROUP BY gemeindeschluessel) g ON g.gemeindeschluessel = u.gemeindeschluessel ORDER BY summe_unplausibel/g.Summe_Bruttoleistung DESC) TO 'out/datawrapper_anteil_unplausibler_neuzugaenge.csv' WITH CSV DELIMITER ',' HEADER;

-- out/datawrapper_anlagen_zuwachs_je_1k_ew_kleinstaedte
\COPY (SELECT t.name, z.gemeindeschluessel, (anz_start_geprueft+ anz_start_inpruefung) anz_start, ROUND((anz_start_geprueft + anz_start_inpruefung)*1.0/residents*1000.0,2) anz_je_1k_ew_start,  (anz_heute_geprueft + anz_heute_inpruefung) anz_heute,  ROUND((anz_heute_geprueft + anz_heute_inpruefung)*1.0/residents*1000.0,2) anz_je_1k_ew_heute,  (anz_heute_geprueft + anz_heute_inpruefung)-(anz_start_geprueft+ anz_start_inpruefung) zuwachs_anz, ROUND(((anz_heute_geprueft + anz_heute_inpruefung)-(anz_start_geprueft+ anz_start_inpruefung)*1.0)/residents*1000.0,1) zuwachs_anz_je_1k_ew FROM zuwachs_per_gemeinde z JOIN teilnehmer t ON t.ags=z.gemeindeschluessel WHERE residents < 100000 ORDER BY ((anz_heute_geprueft + anz_heute_inpruefung)-(anz_start_geprueft+ anz_start_inpruefung)*1.0)/residents DESC) TO 'out/datawrapper_anlagen_zuwachs_je_1k_ew_kleinstaedte.csv' WITH CSV DELIMITER ',' HEADER;

-- out/datawrapper_anlagen_zuwachs_je_1k_ew_grossstaedte
\COPY (SELECT t.name, z.gemeindeschluessel, (anz_start_geprueft+ anz_start_inpruefung) anz_start, ROUND((anz_start_geprueft + anz_start_inpruefung)*1.0/residents*1000.0,2) anz_je_1k_ew_start,  (anz_heute_geprueft + anz_heute_inpruefung) anz_heute,  ROUND((anz_heute_geprueft + anz_heute_inpruefung)*1.0/residents*1000.0,2) anz_je_1k_ew_heute,  (anz_heute_geprueft + anz_heute_inpruefung)-(anz_start_geprueft+ anz_start_inpruefung) zuwachs_anz, ROUND(((anz_heute_geprueft + anz_heute_inpruefung)-(anz_start_geprueft+ anz_start_inpruefung)*1.0)/residents*1000.0,1) zuwachs_anz_je_1k_ew FROM zuwachs_per_gemeinde z JOIN teilnehmer t ON t.ags=z.gemeindeschluessel WHERE residents >= 100000 ORDER BY ((anz_heute_geprueft + anz_heute_inpruefung)-(anz_start_geprueft+ anz_start_inpruefung)*1.0)/residents DESC) TO 'out/datawrapper_anlagen_zuwachs_je_1k_ew_grossstaedte.csv' WITH CSV DELIMITER ',' HEADER;

\COPY (SElECT t.name, t.joinedat beitritt, t.residents ewz, t.communitytype kommunentyp, s.*, round(zuwachs_kwp/residents*1000,2) zuwachs_wp_je_ew  FROM mastr.teilnehmer t JOIN mastr.zuwachs_per_gemeinde s on t.ags=s.gemeindeschluessel ORDER BY communitytype, zuwachs_kwp/residents DESC) TO 'out/wattbewerb_ranking_tabelle.csv' WITH CSV DELIMITER ',' HEADER;

-- out/wbw1_abschluss_ranking_kommunen
\COPY (SELECT * FROM stat_ranking_final WHERE communitytype ='community' ORDER BY zuwachs_watt_per_ew DESC) TO 'out/wbw1_abschluss_ranking_kommunen_alle.csv' WITH CSV DELIMITER ',' HEADER;

-- out/wbw1_abschluss_ranking_staedte
\COPY (SELECT * FROM stat_ranking_final WHERE communitytype ='city' ORDER BY zuwachs_watt_per_ew DESC) TO 'out/wbw1_abschluss_ranking_staedte_alle.csv' WITH CSV DELIMITER ',' HEADER;

-- out/wbw1_abschluss_ranking_grossstaedte
\COPY (SELECT * FROM stat_ranking_final WHERE communitytype ='metropolis' ORDER BY zuwachs_watt_per_ew DESC) TO 'out/wbw1_abschluss_ranking_grossstaedte_alle.csv' WITH CSV DELIMITER ',' HEADER;

-- out/wbw2_ranking
\COPY (SELECT * FROM stat_ranking_2_0 ORDER BY zuwachs_watt_per_ew DESC) TO 'out/wbw2_ranking_alle.csv' WITH CSV DELIMITER ',' HEADER;
