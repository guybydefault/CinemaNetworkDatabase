psql -h pg -d studs -f drop.sql
git pull
psql -h pg -d studs -f create.sql
psql -h pg -d studs -f functions.sql