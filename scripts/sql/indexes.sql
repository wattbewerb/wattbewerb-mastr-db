CREATE UNIQUE INDEX ON MASTR.MASTR (mastrnummer);
CREATE INDEX ON MASTR.MASTR (gemeindeschluessel);
CREATE INDEX ON MASTR.MASTR (InbetriebnahmeDatum);
CREATE INDEX ON MASTR.MASTR (gemeindeschluessel,InbetriebnahmeDatum,EnergietraegerId);