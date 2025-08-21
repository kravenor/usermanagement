## How to install
Pull repository

Run ```mv .env.example .env``` and customize your project name in _COMPOSE_PROJECT_NAME_ variable

Run ```cd src/fe && cp .env.example .env``` and customize _VITE_API_BASE_URL_ with your ${COMPOSE_PROJECT_NAME}

Run ```cd src/be && cp .env.example .env``` and customize _APP_URL_  and _DB_DATABASE_ with your ${COMPOSE_PROJECT_NAME}   

Start docker container with:

```docker-compose build && docker-compose up ```

Open backend container with ```docker exec -it ${COMPOSE_PROJECT_NAME}_be bash``` and run 

* ```composer install```
* ```php artisan migrate --seed``` this create base tables and populate with an admin user [admin@prova.com:password]
* ```php artisan jwt:secret```
* ```php artisan key:generate```

exit backend container. 



Now if you open your browser to http://fe.${COMPOSE_PROJECT_NAME}.localhost you should see login page


