#!/bin/sh
set -eu
mkdir -p /data/sites /data/redis /data/logs
chown -R frappe:frappe /data
exec runuser -u frappe -- /opt/books-bootstrap.sh
