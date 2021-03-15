psql --host localhost --port 25432 --user postgres -f scripts/sql/schema.sql
psql --host localhost --port 25432 --user postgres -c "\COPY mastr_stage FROM '$PWD/out/mastr.csv' DELIMITER ',' CSV HEADER;"
psql --host localhost --port 25432 --user postgres -f scripts/sql/initial_stage_transform.sql
psql --host localhost --port 25432 --user postgres -f scripts/sql/wattbewerb_mat_views.sql
