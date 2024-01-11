CREATE SCHEMA mastr;
SET search_path TO mastr,public;

DROP TABLE IF EXISTS Bundesland_LT;
CREATE TABLE IF NOT EXISTS Bundesland_LT (
  key INT PRIMARY KEY,
  value TEXT,
  schluessel TEXT
);
INSERT INTO Bundesland_LT VALUES
  (1400,'Brandenburg', '12'),
  (1401,'Berlin', '11'),
  (1402,'Baden-Württemberg', '08'),
  (1403,'Bayern', '09'),                            
  (1404,'Bremen', '04'),
  (1405,'Hessen', '06'),
  (1406,'Hamburg', '02'),
  (1407,'Mecklenburg-Vorpommern', '13'),
  (1408,'Niedersachsen', '03'),
  (1409,'Nordrhein-Westfalen', '05'),
  (1410,'Rheinland-Pfalz', '07'),
  (1411,'Schleswig-Holstein', '01'),
  (1412,'Saarland', '10'),
  (1413,'Sachsen', '14'),
  (1414,'Sachsen-Anhalt', '15'),
  (1415,'Thüringen', '16');

DROP TABLE IF EXISTS TechnologieStromerzeugung_LT;
CREATE TABLE IF NOT EXISTS TechnologieStromerzeugung_LT (
  key INT PRIMARY KEY,
  value TEXT
);
INSERT INTO TechnologieStromerzeugung_LT VALUES
  (542,'Verbrennungsmotor'),
  (543,'Brennstoffzelle'),
  (544,'Stirlingmotor'),
  (545,'Dampfmotor'),                            
  (546,'ORC (Organic Rankine Cycle)-Anlage'),
  (691,'Horizontalläufer'),
  (692,'Vertikalläufer'),
  (833,'Gegendruckmaschine mit Entnahme'),
  (834,'Gegendruckmaschine ohne Entnahme'),
  (835,'Gasturbinen ohne Abhitzekessel'),
  (836,'Gasturbinen mit Abhitzekessel'),
  (837,'Gasturbinen mit nachgeschalteter Dampfturbine'),
  (838,'Kondensationsmaschine mit Entnahme'),
  (839,'Kondensationsmaschine ohne Entnahme'),
  (840,'Sonstige'),
 (1444,'Druckwasserreaktor');

DROP TABLE IF EXISTS Hauptbrennstoff_LT CASCADE;
CREATE TABLE IF NOT EXISTS Hauptbrennstoff_LT (
  key INT PRIMARY KEY,
  value TEXT
);
INSERT INTO Hauptbrennstoff_LT VALUES
 (2414,'Abfall, fest, rein biogen'),
 (2415,'Altholz'),
 (2417,'Brennholz'),
 (2418,'Brennlauge'),
 (2419,'Feste biogene Stoffe'),
 (2420,'Holz'),
 (2421,'Holzhackschnitzel'),
 (2422,'Holzreste (z.B. Schreinereien)'),
 (2423,'Holzspäne, Sägemehl'),
 (2424,'Landschaftspflegeholz'),
 (2425,'Pellets (Holz)'),
 (2427,'Restholz'),
 (2428,'Rinde'),
 (2431,'Stroh, Strohpellets'),
 (2432,'Sulfitablauge'),
 (2435,'Warmbrennstoffe (biogener Gewerbeabfall)'),
 (2436,'Abfall, flüssig, biogen'),
 (2437,'Biodiesel'),
 (2438,'Biomethanol'),
 (2439,'Flüssige biogene Stoffe'),
 (2441,'Iso-Hexan'),
 (2442,'Palmöl'),
 (2443,'Pflanzenöl'),
 (2444,'Terpentin'),
 (2445,'Biogas (vor Ort verstromt)'),
 (2446,'Biomethan'),
 (2447,'Deponiegas'),
 (2448,'Klärgas'),
 (2457,'Steinkohlen'),
 (2460,'Braunkohlenbriketts'),
 (2463,'Rohbraunkohlen'),
 (2464,'Staub- und Trockenkohle'),
 (2465,'Wirbelschichtkohle'),
 (2466,'Dieselkraftstoff'),
 (2467,'Hochofengaseizöl, leicht'),
 (2468,'Heizöl, schwer'),
 (2469,'Flüssiggas'),
 (2471,'Raffineriegas'),
 (2472,'Andere Mineralölprodukte'),
 (2473,'Erdgas, Erdölgas'),
 (2474,'Grubengas'),
 (2475,'Hochofengas, Konvertergas'),
 (2477,'Andere Gase'),
 (2478,'Sonstige hergestellte Gase'),
 (2479,'nicht biogener Industrieabfall'),
 (2480,'nicht biogener Abfall (Hausmüll, Siedlungsabfälle)'),
 (2481,'Prozessdampf'),
 (2482,'Dampf (fremdbezogen)'),
 (2483,'Sonstige Wärme');

DROP TABLE IF EXISTS IsNBPruefungAbgeschlossen_LT;
CREATE TABLE IF NOT EXISTS IsNBPruefungAbgeschlossen_LT (
  key INT PRIMARY KEY,
  value TEXT
);
INSERT INTO IsNBPruefungAbgeschlossen_LT VALUES
  (2954,'Geprüft'),
  (2955,'In Prüfung');

DROP TABLE IF EXISTS Statistik_LT;
CREATE TABLE IF NOT EXISTS Statistik_LT (
  key INT PRIMARY KEY,
  value TEXT
);
INSERT INTO Statistik_LT VALUES
  (2883,'A'),
  (2882,'B');

DROP TABLE IF EXISTS BetriebsStatus_LT;
CREATE TABLE IF NOT EXISTS BetriebsStatus_LT (
  key INT PRIMARY KEY,
  value TEXT
);
INSERT INTO BetriebsStatus_LT VALUES
 (31,'In Planung'),
 (35,'In Betrieb'),
 (37,'Vorübergehend stillgelegt'),
 (38,'Dauerhaft stillgelegt');

DROP TABLE IF EXISTS SystemStatus_LT;
CREATE TABLE IF NOT EXISTS SystemStatus_LT (
  key INT PRIMARY KEY,
  value TEXT
);
INSERT INTO SystemStatus_LT VALUES
 (472,'Aktiviert'); -- Deaktiviert wird nicht veröffentlicht

DROP TABLE IF EXISTS HauptausrichtungSolarModule_LT;
CREATE TABLE IF NOT EXISTS HauptausrichtungSolarModule_LT (
  key INT PRIMARY KEY,
  value TEXT
);
INSERT INTO HauptausrichtungSolarModule_LT VALUES
 (695,'Nord'),
 (696,'Nord-Ost'),
 (697,'Ost'),
 (698,'Süd-Ost'),
 (699,'Süd'),
 (700,'Süd-West'),
 (701,'West'),
 (702,'Nord-West'),
 (703,'nachgeführt'),
 (704,'Ost-West');

DROP TABLE IF EXISTS VollTeilEinspeisung_LT;
CREATE TABLE IF NOT EXISTS VollTeilEinspeisung_LT (
  key INT PRIMARY KEY,
  value TEXT
);
INSERT INTO VollTeilEinspeisung_LT VALUES
 (688,'Volleinspeisung'),
 (689,'Teileinspeisung');

DROP TABLE IF EXISTS Energietraeger_LT;
CREATE TABLE IF NOT EXISTS Energietraeger_LT (
  key INT PRIMARY KEY,
  value TEXT
);
INSERT INTO Energietraeger_LT VALUES
 (2403, 'Geothermie'),
 (2404, 'Solarthermie'),
 (2405, 'Klärschlamm '),
 (2406, 'Grubengas'),
 (2407, 'Steinkohle'),
 (2408, 'Braunkohle'),
 (2409, 'Mineralölprodukte'),
 (2410, 'Erdgas'),
 (2411, 'andere Gase'),
 (2412, 'nicht biogener Abfall'),
 (2413, 'Wärme'),
 (2493, 'Biomasse'),
 (2494, 'Kernenergie'),
 (2495, 'Solare Strahlungsenergie'),
 (2496, 'Speicher'),
 (2497, 'Wind'),
 (2498, 'Wasser'),
 (2957, 'Druck aus Gasleitungen'),
 (2958, 'Druck aus Wasserleitungen'); 

DROP TABLE IF EXISTS Anlagenbetreiberart_LT;
CREATE TABLE IF NOT EXISTS Anlagenbetreiberart_LT (
  key INT PRIMARY KEY,
  value TEXT
);
INSERT INTO Anlagenbetreiberart_LT VALUES
 (1, 'Natürliche Person'),
 (517, 'Natürliche Person'),
 (518, 'Organisation')
 ;

DROP TABLE IF EXISTS Batterietechnologie_LT;
CREATE TABLE IF NOT EXISTS Batterietechnologie_LT (
  key INT PRIMARY KEY,
  value TEXT
);
INSERT INTO Batterietechnologie_LT VALUES
 (727, 'Lithium-Batterie'),
 (728, 'Blei-Batterie'),
 (729, 'Redox-Flow-Batterie'),
 (730, 'Hochtemperaturbatterie'),
 (731, 'Nickel-Cadmium- / Nickel-Metallhydridbatterie'),
 (732, 'Sonstige Batterie')
;

DROP TABLE IF EXISTS mastr CASCADE;
CREATE TABLE IF NOT EXISTS mastr (
    Id INT PRIMARY KEY,
    AnlagenbetreiberId INT,
    AnlagenbetreiberPersonenArt INT,
    AnlagenbetreiberMaskedName TEXT,
    AnlagenbetreiberMaStRNummer TEXT,
    AnlagenbetreiberName TEXT,
    BetriebsStatusId INT,
    Breitengrad NUMERIC(9,6),
    BundeslandId INT,
    DatumLetzteAktualisierung TIMESTAMP,
    EinheitRegistrierungsdatum DATE,
    EinheitName TEXT,
    EndgueltigeStilllegungDatum DATE,
    Flurstueck TEXT,
    Gemarkung TEXT,
    Gemeinde TEXT,
    Gemeindeschluessel TEXT,
    GeplantesInbetriebsnahmeDatum DATE,
    Hausnummer TEXT,
    InbetriebnahmeDatum DATE,
    IsNBPruefungAbgeschlossen INT,
    Laengengrad NUMERIC(9,6),
    LandId INT,
    Landkreis TEXT,
    LokationId INT,
    LokationMastrNr TEXT,
    MaStRNummer TEXT,
    NetzbetreiberId TEXT,
    NetzbetreiberMaskedNamen TEXT,
    NetzbetreiberMaStRNummer TEXT,
    NetzbetreiberNamen TEXT,
    NetzbetreiberPersonenArt TEXT,
    Ort TEXT,
    Plz TEXT,
    Strasse TEXT,
    SystemStatusId INT,
    Typ INT,
    AktenzeichenGenehmigung TEXT,
    AnzahlSolarModule INT,
    Batterietechnologie INT,
    Bruttoleistung NUMERIC(12, 3),
    EegInbetriebnahmeDatum DATE,
    EegAnlageMastrNummer TEXT,
    EegAnlageRegistrierungsdatum DATE,
    EegAnlagenschluessel TEXT,
    EegZuschlag TEXT,
    -- Zuschlagsnummern TEXT, new in 07-11.03.2022, for now ignore
    EnergietraegerId INT,
    EnergietraegerName TEXT,
    GemeinsamerWechselrichter INT,
    Genehmigungbehoerde TEXT,
    GenehmigungDatum DATE,
    GenehmigungRegistrierungsdatum DATE,
    GenehmigungsMastrNummer TEXT,
    Gruppierungsobjekte TEXT,
    GruppierungsobjekteIds TEXT,
    HatFlexibilitaetspraemie BOOLEAN,
    HauptausrichtungSolarModule INT,
    HauptbrennstoffId INT,
    HauptneigungswinkelSolarmodule INT,
    HerstellerWindenergieanlage INT,
    HerstellerWindenergieanlageBezeichnung TEXT, -- Potentiell hoher Nachführungsaufwand, daher nicht normalisiert
    IsAnonymisiert TEXT,
    IsEinheitNotstromaggregat TEXT,
    KraftwerkName TEXT,
    KraftwerkBlockName TEXT,
    KwkAnlageElektrischeLeistung NUMERIC(12,3),
    KwkAnlageInbetriebnahmedatum DATE,
    KwkAnlageMastrNummer TEXT,
    KwkAnlageRegistrierungsdatum DATE,
    KwkZuschlag TEXT,
    LageEinheit INT,
    LageEinheitBezeichnung TEXT,
    Leistungsbegrenzung INT,
    MieterstromAngemeldet TEXT,
    MigrationseinheitMastrNummer INT,
    NabenhoeheWindenergieanlage NUMERIC(5, 2),
    Nettonennleistung NUMERIC(12, 3),
    NutzbareSpeicherkapazitaet NUMERIC(12, 2),
    NutzungsbereichGebSA INT,
    Pilotwindanlage BOOLEAN,
    Prototypanlage BOOLEAN,
    Regelzone INT,
    RotordurchmesserWindenergieanlage NUMERIC(5,1),
    SpannungsebenenId INT,
    SpannungsebenenNamen TEXT, -- Nicht normalisierte Ausgabe
    SpeicherEinheitMastrNummer TEXT,
    TechnologieStromerzeugungId INT,
    ThermischeNutzleistung NUMERIC(12,3),
    Typenbezeichnung TEXT,
    VollTeilEinspeisung INT,
    WasserkraftErtuechtigung TEXT,
    WindClusterOstseeId INT,
    WindClusterNordseeId INT,
    WindparkName TEXT
);

DROP TABLE IF EXISTS teilnehmer CASCADE;
CREATE TABLE IF NOT EXISTS teilnehmer (
  ags TEXT,
  name TEXT,
  communityType TEXT,
  registerDate DATE,
  residents INT
);
CREATE UNIQUE INDEX name ON teilnehmer (ags);