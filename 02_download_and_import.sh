set -e
if [ "$#" -lt 1 ]; then
	echo "Wrong number of arguments. Use 02_download_and_import.sh <connectstring_stage> [<connectstring_prod>]"
	exit
fi

python3 03_download_mastr.py
./06_import_mastr.sh $1
if [ "$#" = 2 ]; then
	./06_import_mastr.sh $2
fi
zip -oD body.zip out/mastr.csv
gzip out/mastr.csv
mv out/mastr.csv.gz out/mastr_complete_`date +"%Y-%m-%d"`.csv.gz

./07_export_stats.sh $1
