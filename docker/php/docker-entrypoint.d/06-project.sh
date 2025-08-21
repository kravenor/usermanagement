#!/bin/bash
set -e

cd ${PHP_PROJECT_ROOT}

ENV_FILE=.env
ENV_DOCKER_FILE=.env.docker
ENV_EXAMPLE_FILE=.env.example
COMPOSER_FILE=composer.json
VENDOR_DIR=vendor

function check_command_exists(){
  if ! command -v $1 &> /dev/null
  then
    # Return 1 = false
    return 1
  fi
  # Return 0 = false
  return 0
}

res_count_subdirs=null
function count_subdirs(){
  res_count_subdirs=null
  local dir=$1
  local count=$(find ./${dir}/ -mindepth 1 -maxdepth 1 -type d -printf '.' | wc -c)
  res_count_subdirs=$count
}

function gitignore_add(){
    local line=$1
    local file=$2
    if ! grep -Fxq "$line" "$file"; then
        echo "${line}" >> "$file"
    fi
}

function magento_create_auth(){
  gitignore_add "auth.json" "./.gitignore"
  local wwwdata_dir=$(su www-data -c 'composer config --global home')
  template='{\\"http-basic\\": {\\"repo.magento.com\\": {\\"username\\": \\"%s\\", \\"password\\": \\"%s\\"}, \\"repo.mageplaza.com\\": {\\"username\\": \\"%s\\", \\"password\\": \\"%s\\"}}}'
  auth_file_content=$(printf "$template" "$MAGENTO_ADOBE_ACCESS_KEY_PUBLIC" "$MAGENTO_ADOBE_ACCESS_KEY_PRIVATE"  "$MAGENTO_ADOBE_ACCESS_KEY_PUBLIC" "$MAGENTO_ADOBE_ACCESS_KEY_PRIVATE" )
  auth_file="${wwwdata_dir}/auth.json"
  echo "Creating file $auth_file ..."
  su www-data -c "echo ${auth_file_content} > $auth_file"
  chown www-data ${auth_file}

  # root has different template
  local root_dir=$(composer config --global home)
  template='{\"http-basic\": {\"repo.magento.com\": {\"username\": \"%s\", \"password\": \"%s\"}, \"repo.mageplaza.com\": {\"username\": \"%s\", \"password\": \"%s\"}}}'
  auth_file_content=$(printf "$template" "$MAGENTO_ADOBE_ACCESS_KEY_PUBLIC" "$MAGENTO_ADOBE_ACCESS_KEY_PRIVATE"  "$MAGENTO_ADOBE_ACCESS_KEY_PUBLIC" "$MAGENTO_ADOBE_ACCESS_KEY_PRIVATE" )
  auth_file="${root_dir}/auth.json"
  echo "Creating file $auth_file ..."
  echo ${auth_file_content} > $auth_file
}

if test -f "$ENV_FILE"; then
  echo "Using existing .env file"
  # a project is already there, do nothing unless vendor dir doesn't exist
#  if [ -z "$(ls -A ${VENDOR_DIR})" ]; then
#    su www-data -c 'composer install'
#  fi
#  exec "$@"
elif test -f "$ENV_DOCKER_FILE"; then
  echo "Using existing .env.docker file"
# a docker-ready project is already there, let's use it as .env
#  su www-data
#  cp $ENV_DOCKER_FILE $ENV_FILE
#  composer install
#  php artisan migrate
#  php artisan passport:install
#  php artisan db:seed
elif test -f "$ENV_EXAMPLE_FILE"; then
# a project is already there, but not configured yet, so do nothing
  echo "project not configured yet, missing .env file...."
#  exec "$@"
elif test -f "$COMPOSER_FILE"; then
  echo "Composer.json file found, checking if vendor folder is empty"
  # a project is already there, do nothing unless vendor dir doesn't exist
  if [ -z "$(ls -A ${VENDOR_DIR})" ]; then
    echo "vendor folder doesn't exists yet, installing from composer.json file..."
    composer install
    if check_command_exists 'php artisan';
    then
      php artisan key:generate
    fi
    #su www-data -c 'composer install'
    #su www-data -c 'php artisan key:generate'
  else
    count_subdirs ${VENDOR_DIR}
    if [ ${res_count_subdirs} -eq 0 ]; then
      echo "vendor folder is empty, installing from composer.json file..."
      # vendor folder exists, but has no subfolders
      case $PHP_PROJECT_DIST in
        magento2)
          magento_create_auth
          su www-data -c 'composer install'
        ;;
        *)
          su www-data -c 'composer install'
        ;;
      esac
    else
      echo "vendor folder is not empty, doing nothing..."
    fi
  fi
#  exec "$@"
else
  echo "creating new project...."
  case $PHP_PROJECT_DIST in
    meals)
      echo "installing laravel Meals dist...."
      su www-data -c 'composer create-project --prefer-dist laravel/laravel ${PHP_PROJECT_ROOT} 8'
      su www-data -c 'composer install --prefer-dist'      
      su www-data -c 'composer require laravel-json-api/laravel'
      su www-data -c 'composer require --dev laravel-json-api/testing'
      su www-data -c 'composer require laravel/sanctum'
      su www-data -c 'composer require laravel/fortify'
      su www-data -c 'composer require santigarcor/laratrust'
      su www-data -c 'php artisan config:clear'
      su www-data -c 'php artisan vendor:publish --provider="LaravelJsonApi\Laravel\ServiceProvider"'
      su www-data -c 'php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"'
      su www-data -c 'php artisan vendor:publish --provider="Laravel\Fortify\FortifyServiceProvider"'
      su www-data -c 'php artisan vendor:publish --tag="laratrust"'
      su www-data -c 'php artisan laratrust:setup'
      su www-data -c 'composer dump-autoload'
      su www-data -c 'php artisan migrate'
      su www-data -c 'php artisan db:seed'
    ;;
    laravel)
      echo "installing laravel vanilla dist...."
      if [[ -z "${PHP_PROJECT_DIST_VERSION}" || ! -n "${PHP_PROJECT_DIST_VERSION}" ]]; 
      then 
        su www-data -c 'composer create-project --prefer-dist laravel/laravel ${PHP_PROJECT_ROOT} $PHP_PROJECT_DIST_VERSION'
      else
        su www-data -c 'composer create-project --prefer-dist laravel/laravel ${PHP_PROJECT_ROOT}'
      fi
      #  su www-data -c "cp $ENV_DOCKER_FILE $ENV_FILE"
      su www-data -c 'composer install --prefer-dist'
      su www-data -c 'php artisan migrate'      
      su www-data -c 'php artisan db:seed'
    ;;
    magento2)
      echo "installing magento2 ecommerce...."
      su www-data -c 'cd ${PHP_PROJECT_ROOT}'
      su www-data -c 'composer config --global http-basic.repo.magento.com ${MAGENTO_ADOBE_ACCESS_KEY_PUBLIC} ${MAGENTO_ADOBE_ACCESS_KEY_PRIVATE}'
      su www-data -c 'composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition ${PHP_PROJECT_ROOT}'
      su www-data -c 'find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +'
      su www-data -c 'find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +'
      chown -R :www-data .
      chmod u+x bin/magento
      magento_setup_cmd='bin/magento setup:install \
                      --base-url=http://${SELF_URL} \
                      --db-host=${PHP_DB_HOST} \
                      --db-name=${PHP_DB_NAME} \
                      --db-user=${PHP_DB_USER} \
                      --db-password=${PHP_DB_PASSWORD} \
                      --backend-frontname=admin \
                      --admin-firstname=admin \
                      --admin-lastname=admin \
                      --admin-email=${MAGENTO_ADMIN_EMAIL} \
                      --admin-user=admin \
                      --admin-password=admin123 \
                      --language=en_US \
                      --currency=EUR \
                      --timezone=Europe/Rome \
                      --use-rewrites=1 \
                      --search-engine=${PHP_ELASTICSEARCH_ENGINE} \
                      --elasticsearch-host=${PHP_ELASTICSEARCH_HOST} \
                      --elasticsearch-port=${PHP_ELASTICSEARCH_PORT} \
                      --elasticsearch-index-prefix=${PHP_ELASTICSEARCH_INDEX_PREFIX} \
                      --elasticsearch-timeout=15'
      #echo ${magento_setup_cmd}
      su www-data -c "${magento_setup_cmd}"
      if ! [[ -z "${MAGENTO_SAMPLE_DATA}" ]]; then
        magento_create_auth
        su www-data -c 'bin/magento sampledata:deploy --no-interaction'
        su www-data -c 'bin/magento setup:upgrade -n'
        #magento_setup_cmd="${magento_setup_cmd} --use-sample-data"
      fi      
      su www-data -c 'bin/magento module:disable Magento_TwoFactorAuth'
      su www-data -c 'composer require magento/pwa'
      su www-data -c 'bin/magento module:enable --clear-static-content Magento_ContactGraphQlPwa'
      su www-data -c 'bin/magento module:enable --clear-static-content Magento_NewsletterGraphQlPwa'
      su www-data -c 'bin/magento deploy:mode:set developer'
      su www-data -c 'bin/magento cache:flush'

    ;;
  esac
fi
