#!/bin/sh
set -e

FE_DIR=/var/www/html
NODEMODULES_DIR="${FE_DIR}/node_modules"
PACKAGE_FILE="${FE_DIR}/package.json"

#chown -R node:node /var/www

if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- node "$@"
fi

cd $FE_DIR

# install PNPM
npm install -g pnpm

if test -f "$PACKAGE_FILE"; then
  exec "$@"
  # sleep infinity
else
   case $NODE_PROJECT_DIST in
      meals)
        npx create-next-app . --use-npm --example "https://github.com/vercel/next-learn-starter/tree/master/learn-starter"
        npm run build
        exec "$@"
      ;;
      *)
        sleep infinity
      ;;
  esac
fi


