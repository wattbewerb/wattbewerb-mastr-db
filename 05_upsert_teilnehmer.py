import psycopg2
import psycopg2.extras
import csv
import pandas as pd
from pangres import upsert
from sqlalchemy import create_engine
import argparse
import time
import json
import requests

def do_upsert(dbconnectstring, competitors_url):
    engine = create_engine(dbconnectstring, connect_args={"options": "-csearch_path=mastr,public"})
    
    r = requests.get(competitors_url)
    data = r.json()
    df = pd.json_normalize(data)

    # Convert column names to match lowercase sql table names
    df = df.rename(columns=str.lower)
    df.drop(columns=['id','land','area','urbanisation','lat','long','residentsdate'], inplace=True)
    
    # Need to set primary key column as index
    df = df.set_index('ags')

    upsert(con=engine,
           df=df,
           schema='mastr',
           table_name='teilnehmer',
           if_row_exists='update',
           dtype={},
           chunksize=1000)

def main(args):
    start_time = time.time()
    do_upsert(args.dbconnectstring, args.competitors_url)
    print("%s seconds" % (time.time() - start_time))

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    # python 05_upsert_teilnehmer.py -i https://wattbewerb.herokuapp.com/api/v1/competitors' -d 'postgresql://postgres:@localhost:25432/postgres'
    parser.add_argument('-u', dest='competitors_url')
    parser.add_argument('-d', dest='dbconnectstring')
    args = parser.parse_args()
    main(args)
