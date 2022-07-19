#!/usr/bin/python

import argparse
import sys, getopt
import pandas as pd
import json
import re
import requests
import time
from urllib3.util.retry import Retry
from requests.adapters import HTTPAdapter

RECORDS_PER_PAGE = 5000

s = requests.Session()

retries = Retry(total=15,
                backoff_factor=0.1,
                status_forcelist=[ 500, 502, 503, 504 ])

s.mount('http://', HTTPAdapter(max_retries=retries))

def filter_duplicates(df):
    duplicates = []
    last_id = None
    for index, row in df.iterrows():
        current_id = row['Id']
        if last_id == current_id:
            duplicates.append(index)
        last_id = current_id

    return df.drop(duplicates)

def to_iso_date(df, column):
    return pd.to_datetime(df[column].fillna("").str[6:-2].replace('-.*','', regex=True).replace('253402214400000',''), unit='ms')
    
def download_page(url, page, file_name):
    response = s.get(url)
    data = response.json()['Data']
    df = pd.json_normalize(data)
    if len(df.index) == 0:
        return 0
    
    # Drop column which can be reconstructed, e.g. values to a known key
    df.drop(columns=['Bundesland','StandortAnonymisiert','TechnologieStromerzeugung',
        'HauptausrichtungSolarModuleBezeichnung','HauptbrennstoffNamen',
        'VollTeilEinspeisungBezeichnung','BetriebsStatusName','SystemStatusName',
        'Zuschlagsnummern'], inplace=True)

    # Dropp columns currently not reflected by model
    df.drop(columns=['IsBuergerenergie'], inplace=True)
    df.drop(columns=['EegInstallierteLeistung'], inplace=True)

    # Convert mastr dateformat to iso date/timestamps
    df["DatumLetzteAktualisierung"] = to_iso_date(df, "DatumLetzteAktualisierung")
    df["EinheitRegistrierungsdatum"] = to_iso_date(df, "EinheitRegistrierungsdatum")
    df["EndgueltigeStilllegungDatum"] = to_iso_date(df, "EndgueltigeStilllegungDatum")
    df["GeplantesInbetriebsnahmeDatum"] = to_iso_date(df, "GeplantesInbetriebsnahmeDatum")
    df["InbetriebnahmeDatum"] = to_iso_date(df, "InbetriebnahmeDatum")
    df["EegAnlageRegistrierungsdatum"] = to_iso_date(df, "EegAnlageRegistrierungsdatum")
    df["EegInbetriebnahmeDatum"] = to_iso_date(df, "EegInbetriebnahmeDatum")
    df["GenehmigungDatum"] = to_iso_date(df, "GenehmigungDatum")
    df["GenehmigungRegistrierungsdatum"] = to_iso_date(df, "GenehmigungRegistrierungsdatum")
    df["KwkAnlageInbetriebnahmedatum"] = to_iso_date(df, "KwkAnlageInbetriebnahmedatum")
    df["KwkAnlageRegistrierungsdatum"] = to_iso_date(df, "KwkAnlageRegistrierungsdatum")


    # Render IDs as ints 
    for col in ['BundeslandId','HauptbrennstoffId','AnlagenbetreiberId','AnlagenbetreiberPersonenArt','IsNBPruefungAbgeschlossen',
        'LokationId','Batterietechnologie','LageEinheit','Leistungsbegrenzung','Regelzone','VollTeilEinspeisung',
        'NutzungsbereichGebSA','GemeinsamerWechselrichter','HauptausrichtungSolarModule','HauptneigungswinkelSolarmodule',
        'AnzahlSolarModule','TechnologieStromerzeugungId',
        'WindClusterOstseeId','WindClusterNordseeId','SpannungsebenenId','HerstellerWindenergieanlage']:
        try:
            df[col] = df[col].map(lambda x: '' if pd.isnull(x) else '%.f' % x)
        except:
            print('Error to render col {} as int'.format(col))
    df = filter_duplicates(df)

    if page == 1:
        df.to_csv (file_name, index = None, header=True)
    else:
        df.to_csv (file_name, index = None, header=False, mode='a')

    return len(df.index)

def download(only_updates_since = None):
    endpoint = 'https://www.marktstammdatenregister.de/MaStR/Einheit/EinheitJson/GetErweiterteOeffentlicheEinheitStromerzeugung'
    if only_updates_since:
        url = '{}?sort=MaStRNummer-asc,DatumLetzteAktualisierung-asc&page={}&pageSize={}&group=&filter=Letzte%20Aktualisierung~gt~%27{}%27'.format(endpoint, '{}', '{}', only_updates_since)
        out_filename =  'out/mastr_{}.csv'.format(only_updates_since)
    else:
        url = '{}?sort=MaStRNummer-asc&page={}&pageSize={}&group=&filter='.format(endpoint, '{}', '{}', '{}')
        out_filename =  'out/mastr.csv'

    page = 1
    while True:
        recent_count = download_page(url.format(page, RECORDS_PER_PAGE), page, out_filename)
        if recent_count == 0:
            break
        print("Downloaded {} rows".format((page - 1) * RECORDS_PER_PAGE + recent_count))
        page = page + 1 

def main(args):
    start_time = time.time()
    download(args.since)
    print("%s seconds" % (time.time() - start_time))

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    # call via e.g. python 01_download_mastr.py -s 12.02.2021
    parser.add_argument('-s', dest='since', required=False, help='Date in dd.mm.yyyy')
    args = parser.parse_args()
    main(args)
