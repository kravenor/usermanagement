#!/bin/bash
set -e

cd ${PHP_PROJECT_ROOT}


function can_install_drush(){
  if [[ -z "${PHP_DRUSH_VERSION}" || ! -n "${PHP_DRUSH_VERSION}" || "${PHP_DRUSH_VERSION}" == "" || ${PHP_DRUSH_VERSION} == '""' ]]; 
  then 
    # var is empty. Return 1 = false
    return 1
  else
    # var is not empty. Return 0 = true
    return 0
  fi
}

function check_command_exists(){
  if ! command -v $1 &> /dev/null
  then
    # Return 1 = false
    return 1
  fi
  # Return 0 = false
  return 0
}

function install_drush(){
  if can_install_drush; then
    if check_command_exists 'drush';
    then
      echo "drush already installed"
    else
      echo "installing drush ${PHP_DRUSH_VERSION}..."
      cd /usr/local/bin
      mkdir drush-${PHP_DRUSH_VERSION}
      cd drush-${PHP_DRUSH_VERSION}
      composer require drush/drush:^${PHP_DRUSH_VERSION}
      ln -s /usr/local/bin/drush-${PHP_DRUSH_VERSION}/vendor/bin/drush /usr/local/bin/drush
    fi
  else
   echo "drush not installed, no PHP_DRUSH_VERSION environment variable provided"
  fi
}

install_drush
