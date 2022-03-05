python3 05_upsert_teilnehmer.py -u https://wattbewerb.herokuapp.com/api/v1/competitors -d $1
psql -d $1 -c "TRUNCATE TABLE mastr.mastr;"
psql -d $1 -c "\COPY mastr.mastr FROM '$PWD/out/mastr.csv' DELIMITER ',' CSV HEADER;"
psql -d $1 -f scripts/sql/refresh_matviews.sql