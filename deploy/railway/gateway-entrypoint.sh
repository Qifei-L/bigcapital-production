#!/bin/sh
set -eu
task_resolver=$(sed -n 's/^nameserver //p' /etc/resolv.conf | head -n 1)
case "$task_resolver" in *:*) task_resolver="[$task_resolver]";; esac
sed "s/__RESOLVER__/$task_resolver/g" /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
exec nginx -g 'daemon off;'
