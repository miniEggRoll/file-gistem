http        = require 'http'
path        = require 'path'
debug       = require('debug')('file:index')
koa         = require 'koa'
cond        = require 'koa-conditional-get'
etag        = require 'koa-etag'
auth        = require path.join(__dirname, 'googleAuth')
git         = require path.join(__dirname, 'git')

{PORT, MAX_SECONDS, DEFAULT_PATH} = process.env

app = koa()

app.use (next)->
    @path = DEFAULT_PATH unless /^\/.+$/.test @path
    yield next

app.use (next)->
    yield next
    @set 'Cache-Control', 'max-age=' + MAX_SECONDS

app.use cond()
app.use etag()

app.use auth
app.use git

http.createServer app.callback()
.listen PORT, -> console.log "serving git on #{PORT}"
