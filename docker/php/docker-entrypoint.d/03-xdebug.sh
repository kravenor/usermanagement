#!/bin/bash
set -e

cd ${PHP_PROJECT_ROOT}

function install_xdebug(){
  echo "Copying default XDEBUG ini"
  cp /home/xdebug/xdebug-default.ini /usr/local/etc/php/conf.d/xdebug.ini

  if [[ $XDEBUG_MODES == *"profile"* ]]; then
      echo "Appending profile ini"
      echo "" >> /usr/local/etc/php/conf.d/xdebug.ini
      cat /home/xdebug/xdebug-profile.ini >> /usr/local/etc/php/conf.d/xdebug.ini
  fi

  if [[ $XDEBUG_MODES == *"debug"* ]]; then
      echo "Appending debug ini"
      echo "" >> /usr/local/etc/php/conf.d/xdebug.ini
      cat /home/xdebug/xdebug-debug.ini >> /usr/local/etc/php/conf.d/xdebug.ini

      echo "Setting Client Host to: $XDEBUG_CLIENT_HOST"
      sed -i -e 's/xdebug.client_host = localhost/xdebug.client_host = '"${XDEBUG_CLIENT_HOST}"'/g' /usr/local/etc/php/conf.d/xdebug.ini

      echo "Setting Client Port to: $XDEBUG_CLIENT_PORT"
      sed -i -e 's/xdebug.client_port = 9003/xdebug.client_port = '"${XDEBUG_CLIENT_PORT}"'/g' /usr/local/etc/php/conf.d/xdebug.ini

      echo "Setting IDE Key to: $XDEBUG_IDE_KEY"
      sed -i -e 's/xdebug.idekey = docker/xdebug.idekey = '"${XDEBUG_IDE_KEY}"'/g' /usr/local/etc/php/conf.d/xdebug.ini
  fi

  if [[ $XDEBUG_MODES == *"trace"* ]]; then
      echo "Appending trace ini"
      echo "" >> /usr/local/etc/php/conf.d/xdebug.ini
      cat /home/xdebug/xdebug-trace.ini >> /usr/local/etc/php/conf.d/xdebug.ini
  fi

  if [[ "off" == $XDEBUG_MODES || -z $XDEBUG_MODES ]]; then
      echo "Disabling XDEBUG";
      echo "" >> /usr/local/etc/php/conf.d/xdebug.ini
      cp /home/xdebug/xdebug-off.ini /usr/local/etc/php/conf.d/xdebug.ini
  else
      echo "Setting XDEBUG mode: $XDEBUG_MODES"
      echo "" >> /usr/local/etc/php/conf.d/xdebug.ini
      echo "xdebug.mode = $XDEBUG_MODES" >> /usr/local/etc/php/conf.d/xdebug.ini
  fi;
}

install_xdebug

