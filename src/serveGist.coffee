http        = require 'http'
path        = require 'path'
debug       = require('debug')('file:index')
koa         = require 'koa'
cond        = require 'koa-conditional-get'
etag        = require 'koa-etag'
c           = require 'lru-cache'
route       = require path.join(__dirname, 'router')

{port, maxSeconds} = process.env

maxSeconds = 60*60*24
_cache = c {
    maxAge: maxSeconds*1000
}

module.exports = ->
    app = koa()

    app.use (next)->
        yield next
        @set 'Cache-Control', 'max-age=' + maxSeconds

    app.use cond()

    app.use etag()

    app.use (next)->
        reload = @headers.refreshgist? or !_cache.has @path
        if reload then yield next
        else
            {buff, type, raw_url} = _cache.get @path
            @body = buff
            @type = type
            @set 'gist_raw_url', raw_url

    app.use route app, _cache

    http.createServer app.callback()
    .listen port, -> console.log "serving gist on #{port}"
