# Pull base image.
FROM localhost:5000/nodev0.11.14

COPY . /tmp
WORKDIR /tmp

RUN npm install
CMD npm start
