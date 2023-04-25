#!bin/bash

if [ -d "/home/frappe/frappe-bench/apps/frappe" ]; then
    echo "Bench already exists, skipping init"
    cd frappe-bench
    bench start
else
    echo "Creating new bench..."
fi

bench init --skip-redis-config-generation frappe-bench

cd frappe-bench

# Use containers instead of localhost
bench set-mariadb-host mariadb
bench set-redis-cache-host redis:6379
bench set-redis-queue-host redis:6379
bench set-redis-socketio-host redis:6379

# Remove redis, watch from Procfile
sed -i '/redis/d' ./Procfile
sed -i '/watch/d' ./Procfile

bench get-app erpnext
bench get-app payments
bench get-app education
bench get-app hrms
bench get-app healthcare
bench get-app ecommerce_integrations --branch main

bench new-site erpnext.localhost \
--force \
--mariadb-root-password 123 \
--admin-password admin \
--no-mariadb-socket

bench --site erpnext.localhost install-app erpnext
bench --site erpnext.localhost install-app payments
bench --site erpnext.localhost install-app education
bench --site erpnext.localhost install-app hrms
bench --site erpnext.localhost install-app healthcare
bench --site erpnext.localhost install-app ecommerce_integrations
bench --site erpnext.localhost set-config developer_mode 1
bench --site erpnext.localhost clear-cache
bench --site erpnext.localhost set-config mute_emails 1
bench use erpnext.localhost

bench start