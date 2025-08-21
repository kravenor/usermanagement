ARG NGINX_TAG=1.19

FROM nginx:${NGINX_TAG}

RUN apt update -y
RUN apt upgrade -y
RUN apt install -y \
    nano \
    wget \
    dnsutils


RUN mkdir -p /var/www/html

ARG USER_ID
ARG GROUP_ID

SHELL ["/bin/bash", "-c"]
RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    userdel -f www-data &&\
    if getent group www-data ; then groupdel www-data; fi &&\
    groupadd -g ${GROUP_ID} www-data &&\
    useradd -l -m -u ${USER_ID} -g www-data www-data &&\
    install -d -m 0755 -o www-data -g www-data /home/www-data \
    ;fi
SHELL ["/bin/sh", "-c"]

RUN mkdir -p /home/www-data/.ssh
RUN chown -R www-data:www-data /home/www-data/.ssh
RUN chown -R www-data:www-data /var/www/html
WORKDIR /var/www/html

RUN sed -i 's/user  nginx;/user  www-data;/g' /etc/nginx/nginx.conf
RUN chown -R www-data:www-data /var/www/html

RUN rm /etc/nginx/conf.d/default.conf

COPY 20-envsubst-on-templates.sh /docker-entrypoint.d