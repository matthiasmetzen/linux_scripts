#!/bin/sh

sudo sh -c "rm -f /var/cache/knot-resolver/*.mdb"
sudo systemctl restart kresd@0
