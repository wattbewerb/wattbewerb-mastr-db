#!/usr/bin/python

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
    
def download_page(url, page, file_name):
    response = s.get(url)
    data = response.json()['Data']
    df = pd.json_normalize(data)
    
    # Drop column which can be reconstructed, e.g. values to a known key
    df.drop(columns=['Bundesland','StandortAnonymisiert','TechnologieStromerzeugung',
        'HauptausrichtungSolarModuleBezeichnung','HauptbrennstoffNamen',
        'VollTeilEinspeisungBezeichnung','BetriebsStatusName','SystemStatusName'], inplace=True)

    if page == 1:
        df.to_csv (file_name, index = None, header=True, float_format='%.f')
    else:
        df.to_csv (file_name, index = None, header=False, float_format='%.f', mode='a')

    return len(df.index)

def download(only_updates_since = None):
    endpoint = 'https://www.marktstammdatenregister.de/MaStR/Einheit/EinheitJson/GetErweiterteOeffentlicheEinheitStromerzeugung'
    if only_updates_since:
        url = '{}?sort=MaStRNummer-asc,DatumLetzteAktualisierung-asc&page={}&pageSize={}&group=&filter=Letzte%20Aktualisierung~gt~%27{}%27~and~Daten%20aus%20Vorg%C3%A4ngerregister%20ausblenden~eq~0'.format(endpoint, '{}', '{}', only_updates_since)
        out_filename =  'out/mastr_{}.csv'.format(only_updates_since)
    else:
        url = '{}?sort=MaStRNummer-asc&page={}&pageSize={}&group=&filter=Daten%20aus%20Vorg%C3%A4ngerregister%20ausblenden~eq~0'.format(endpoint, '{}', '{}', '{}')
        out_filename =  'out/mastr.csv'

    page = 1
    while True:
        recent_count = download_page(url.format(page, RECORDS_PER_PAGE), page, out_filename)
        print("Downloaded {} rows".format((page - 1) * RECORDS_PER_PAGE + recent_count))
        if recent_count < RECORDS_PER_PAGE:
            break
        page = page + 1 

def main(argv):
    since_date = None
    help_text = '01_download_mastr.py -s <Date in dd.mm.yyyy>'
    try:
        opts, args = getopt.getopt(argv,"hs:",["since="])
    except getopt.GetoptError:
        print(helptext)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print(helptext)
            sys.exit()
        elif opt in ("-s", "--since"):
            since_date = arg
    start_time = time.time()
    download(since_date)
    print("%s seconds" % (time.time() - start_time))

if __name__ == "__main__":
    main(sys.argv[1:])