#!/bin/sh

set -e

if [ -f "/app/package.json" ]; then
  if [ -n "$(diff /tmp/package.json /app/package.json)" ]; then
    echo "You have differences between your package.json and the image's package.json. Please re-build the image of this container and retry."
    exit 1
  fi
else
  echo "Missing package.json!"
  exit 1
fi

echo "Installing dependencies from /tmp ..."
rsync -ar /tmp/node_modules/ /app/node_modules/
cp -a /tmp/package-lock.json /app/package-lock.json
echo "Dependencies installed successfully."

echo "Waiting for MongoDB to be ready at $DB_HOSTNAME:$DB_PORT ..."
sh /app/wait-for.sh $DB_HOSTNAME:$DB_PORT -t 180
echo "MongoDB is ready."

exec "$@"
