#!/bin/bash
set -euo pipefail
cd /home/frappe/frappe-bench
if [ ! -f sites/common_site_config.json ]; then
  printf '{}' > sites/common_site_config.json
fi
cp -a /opt/built-sites/apps.txt sites/apps.txt
mkdir -p sites/assets
cp -a /opt/built-sites/assets/. sites/assets/
redis-server --bind 127.0.0.1 --port 6379 --dir /data/redis --appendonly yes --daemonize yes --logfile /data/redis/redis.log
bench set-config -g redis_cache redis://127.0.0.1:6379/0
bench set-config -g redis_queue redis://127.0.0.1:6379/1
bench set-config -g redis_socketio redis://127.0.0.1:6379/0
env/bin/python /opt/ensure_site.py
if [ ! -f "sites/$SITE_NAME/site_config.json" ]; then
  bench new-site "$SITE_NAME" --db-type sqlite --admin-password "$ADMIN_PASSWORD"
fi
bench use "$SITE_NAME"
bench --site "$SITE_NAME" set-config host_name "$HOST_NAME"
if ! bench --site "$SITE_NAME" list-apps | grep -q frappe_books; then
  bench --site "$SITE_NAME" install-app frappe_books
fi
bench --site "$SITE_NAME" migrate
env/bin/python /opt/setup_demo.py
exec env/bin/python /opt/run_books.py --host 0.0.0.0 --port "${PORT:-8000}" --web-threads 2 --job-threads 1
