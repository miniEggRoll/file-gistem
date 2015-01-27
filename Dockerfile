# Pull base image.
FROM registry.eztable.com/nodev0.11.14

COPY . /tmp
WORKDIR /tmp

RUN npm install
CMD npm start
