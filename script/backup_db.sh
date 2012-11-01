#!/bin/bash

filename="thingspotter_production_"`eval date +%Y%m%d`".sql"
echo "Taking backup:" $filename
cd /home/tom/www/thingspotter/backup
mysqldump -h localhost -utom -pfusion thingspotter_production > $filename
gzip $filename
echo "Done."