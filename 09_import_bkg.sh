shp2pgsql -I -s 25832 -d -D data/bkg/vg250-ew_12-31.utm32s.shape.ebenen/vg250-ew_ebenen_1231/VG250_KRS.shp mastr.vg250_krs | psql -d $1
shp2pgsql -I -s 25832 -d -D data/bkg/vg250-ew_12-31.utm32s.shape.ebenen/vg250-ew_ebenen_1231/VG250_GEM.shp mastr.vg250_gem | psql -d $1