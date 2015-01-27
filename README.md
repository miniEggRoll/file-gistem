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

docker run -d --env-file /srv/salt/docker/env/file-gistem.env -p 20010:20010 --name bridge registry.eztable.com/file-gistem
