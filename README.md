file-gistem
===========

use node v0.11 harmony generator, powered by koa


env vars
- port
- maxSecond
- secret
- user
- password


start
```
npm start
```

Start container

docker run -d --name bridge -p 20010:20010 --env-file /srv/salt/docker/env/bridge.env registry.eztable.com/serv-it
