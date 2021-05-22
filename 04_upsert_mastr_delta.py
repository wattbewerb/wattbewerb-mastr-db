import psycopg2
import psycopg2.extras
import csv
import pandas as pd
from pangres import upsert
from sqlalchemy import create_engine
import argparse
import time

def do_upsert(dbconnectstring, importfile):
    engine = create_engine(dbconnectstring, connect_args={"options": "-csearch_path=mastr,public"})
    df = pd.read_csv(importfile, dtype={"Gemeindeschluessel":str, "PlZ":str}, encoding='utf-8')

    df["DatumLetzteAktualisierung"] = pd.to_datetime(df["DatumLetzteAktualisierung"].fillna("").str[6:-2], unit='ms')
    df["EinheitMeldeDatum"] = pd.to_datetime(df["EinheitMeldeDatum"].fillna("").str[6:-2], unit='ms')
    df["EndgueltigeStilllegungDatum"] = pd.to_datetime(df["EndgueltigeStilllegungDatum"].fillna("").str[6:-2], unit='ms')
    df["GeplantesInbetriebsnahmeDatum"] = pd.to_datetime(df["GeplantesInbetriebsnahmeDatum"].fillna("").str[6:-2], unit='ms')
    df["InbetriebnahmeDatum"] = pd.to_datetime(df["InbetriebnahmeDatum"].fillna("").str[6:-2], unit='ms')
    df["EegAnlageMeldedatum"] = pd.to_datetime(df["EegAnlageMeldedatum"].fillna("").str[6:-2], unit='ms')
    df["EegInbetriebnahmeDatum"] = pd.to_datetime(df["EegInbetriebnahmeDatum"].fillna("").str[6:-2], unit='ms')
    df["GenehmigungDatum"] = pd.to_datetime(df["GenehmigungDatum"].fillna("").str[6:-2], unit='ms')
    df["GenehmigungMeldedatum"] = pd.to_datetime(df["GenehmigungMeldedatum"].fillna("").str[6:-2], unit='ms')
    df["KwkAnlageInbetriebnahmedatum"] = pd.to_datetime(df["KwkAnlageInbetriebnahmedatum"].fillna("").str[6:-2], unit='ms')
    df["KwkAnlageMeldedatum"] = pd.to_datetime(df["KwkAnlageMeldedatum"].fillna("").str[6:-2], unit='ms')

    # Convert column names to match lowercase sql table names
    df = df.rename(columns=str.lower)
    # Need to set primary key column as index
    df = df.set_index('id')

    upsert(engine=engine,
           df=df,
           table_name='mastr',
           if_row_exists='update',
           dtype={},
           chunksize=1000)

    refresh_matviews(engine)

def refresh_matviews(engine):
    with engine.connect() as connection:
        connection.execute("REFRESH MATERIALIZED VIEW statistik_heute_per_ags")
        connection.execute("REFRESH MATERIALIZED VIEW statistik_start_per_ags")

def main(args):
    start_time = time.time()
    do_upsert(args.dbconnectstring, args.importfile)
    print("%s seconds" % (time.time() - start_time))

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    # python 03_upsert_mastr_delta.py -i 'out/mastr_14.03.2021.csv' -c 'postgresql://postgres:@localhost:25432/postgres'
    parser.add_argument('-i', dest='importfile')
    parser.add_argument('-c', dest='dbconnectstring')
    args = parser.parse_args()
    main(args)
