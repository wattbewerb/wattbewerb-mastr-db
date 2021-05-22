psql -d $1 -f scripts/sql/schema.sql
psql -d $1 -f scripts/sql/indexes.sql
psql -d $1 -f scripts/sql/checks.sql
psql -d $1 -f scripts/sql/wattbewerb_mat_views.sql
