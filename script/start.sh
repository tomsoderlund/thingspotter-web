#!/bin/bash

echo "Starting ThingSpotter..."
cd /home/tom/www/thingspotter/

echo "Starting Rails Server..."
script/server -d -e production -p 8120