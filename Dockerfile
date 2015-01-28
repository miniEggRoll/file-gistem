# Pull base image.
FROM registry.eztable.com/nodev0.11.14

COPY ./src/ /app/src
COPY ./package.json /app/
WORKDIR /app

RUN npm install
CMD npm start
