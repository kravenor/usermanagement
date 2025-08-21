ARG NODE_TAG=22.18.0
FROM node:${NODE_TAG}-slim

RUN apt update -y
RUN apt upgrade -y
RUN apt install -y \
    nano \
    wget \
    dnsutils \
    net-tools \
    python3


RUN mkdir -p /var/www/html
WORKDIR /var/www/html

COPY docker-entrypoint.sh /usr/bin/node-docker-entrypoint

USER root
RUN mkdir -p /var/www/html
RUN chmod ag+x /usr/bin/node-docker-entrypoint
RUN chown -R node:node /usr/local/lib/node_modules
RUN chown -R node:node /usr/local/bin
RUN chown -R node:node /var/www

RUN npm i -g nodemon

USER node
ENTRYPOINT ["node-docker-entrypoint"]
CMD [ "npm", "run", "dev"]
#CMD ["npm", "start"]

