# Download postalcode/population data
mkdir data/suche-postleitzahl/
curl https://www.suche-postleitzahl.org/download_files/public/zuordnung_plz_ort_landkreis.csv > data/suche-postleitzahl/zuordnung_plz_ort_landkreis.csv
# Wegeen captcha aktuell manuell herunterzuladen
# curl https://www.suche-postleitzahl.org/download_v1/wgs84/mittel/plz-5stellig/geojson/plz-5stellig.geojson > data/suche-postleitzahl/plz-5stellig.json

# import into mastr
ogr2ogr -f "PostgreSQL" "$1" "data/suche-postleitzahl/plz-5stellig.json" -nln plz_gebiete -lco SCHEMA=mastr -overwrite

