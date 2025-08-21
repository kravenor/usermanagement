#!/bin/bash
set -e

mkdir -p ${PHP_PROJECT_ROOT}
chown -R www-data:www-data ${PHP_PROJECT_ROOT}
cd ${PHP_PROJECT_ROOT}

function check_command_exists(){
  if ! command -v $1 &> /dev/null
  then
    # Return 1 = false
    return 1
  fi
  # Return 0 = false
  return 0
}

function install_composer(){
  if check_command_exists 'composer';
  then
    echo "composer already installed"
  else
    echo "installing composer..."
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
  fi  
}

function update_composer(){
  if [[ -z "${PHP_COMPOSER_VERSION}" ]]; 
  then 
    echo "PHP_COMPOSER_VERSION not set, skipping composer update"
  else
    echo "upgrading composer to version ${PHP_COMPOSER_VERSION}..."
    composer self-update ${PHP_COMPOSER_VERSION}
  fi
}

install_composer
update_composer