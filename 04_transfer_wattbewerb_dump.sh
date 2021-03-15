pg_dump -T mastr_stage -d 'postgresql://postgres:@localhost:25432/postgres' > out/wattbewerb.dump
pg_restore --verbose --clean --no-acl --no-owner -d $1 out/wattbewerb.dump
