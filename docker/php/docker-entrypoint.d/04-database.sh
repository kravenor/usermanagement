#!/bin/bash
set -e

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

function install_libraries(){
  case $DB_DRIVER in
    mysql)
      if check_command_exists 'mysql';
      then
        echo "mysql already installed"
      else
        echo "installing mysql..."
        apt-get install -y mariadb-client
      fi
    ;;
    pgsql)
      if check_command_exists 'psql';
      then
        echo "psql already installed"
      else
        echo "installing psql..."
        apt-get install -y postgresql-client
      fi
    ;;
  esac
}

install_libraries