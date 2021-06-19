set -e
if [ "$#" -lt 1 ]; then
	echo "Wrong number of arguments. Use 02_download_and_import.sh <connectstring_stage> [<connectstring_prod>]"
	exit
fi

python3 03_download_mastr.py
psql -d $1 -c "TRUNCATE TABLE mastr.mastr;"
psql -d $1 -c "\COPY mastr.mastr FROM '$PWD/out/mastr.csv' DELIMITER ',' CSV HEADER;"
psql -d $1 -f scripts/sql/refresh_matviews.sql
if [ "$#" -e 2 ]; then
	psql -d $2 -c "TRUNCATE TABLE mastr.mastr;"
	psql -d $2 -c "\COPY mastr.mastr FROM '$PWD/out/mastr.csv' DELIMITER ',' CSV HEADER;"
	psql -d $2 -f scripts/sql/refresh_matviews.sql
fi
gzip out/mastr.csv
mv out/mastr.csv.gz out/mastr_complete_`date +"%Y-%m-%d"`.csv.gz
