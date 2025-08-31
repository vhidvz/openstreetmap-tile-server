#!/bin/bash

set -euo pipefail

set -x

export PGHOST=${PGHOST:-localhost}
export PGPORT=${PGPORT:-5432}
export PGUSER=${PGUSER:-renderer}
export PGPASSWORD=${PGPASSWORD:-renderer}
export PGDATABASE=${PGDATABASE:-gis}
export PGSSLMODE=${PGSSLMODE:-disable}
export PGCONNECT_TIMEOUT=${PGCONNECT_TIMEOUT:-10}

# if there is no custom style mounted, then use osm-carto
if [ ! "$(ls -A /data/style/)" ]; then
    mv /home/renderer/src/openstreetmap-carto-backup/* /data/style/
fi

# Clean /tmp
rm -rf /tmp/*

# Configure Apache CORS
if [ "${ALLOW_CORS:-}" == "enabled" ] || [ "${ALLOW_CORS:-}" == "1" ]; then
    echo "export APACHE_ARGUMENTS='-D ALLOW_CORS'" >> /etc/apache2/envvars
fi

# Initialize Apache
service apache2 restart

# Configure renderd threads
sed -i -E "s/num_threads=[0-9]+/num_threads=${THREADS:-4}/g" /etc/renderd.conf

# Run while handling docker stop's SIGTERM
stop_handler() {
    kill -TERM "$child"
}
trap stop_handler SIGTERM

sudo -u renderer renderd -f -c /etc/renderd.conf &
child=$!
wait "$child"

exit 0
