_           = require 'underscore'
c           = require 'lru-cache'
formatDate  = require 'dateformat'
url         = require 'url'
path        = require 'path'
debug       = require('debug')('file:index')
koa         = require 'koa'
route       = require path.join(__dirname, 'router')
{port}      = require "#{__dirname}/../config"

app = koa()
_cache = c {
    maxAge: 24*60*60*1000
}

router = route app, _cache

app.use (next)-->
    if !@headers.refreshgist? and  cache = _cache.get @path 
        {buff, type} = cache
        @body = buff
        @type = type
    else 
        yield next

app.use router
app.listen port, -> console.log "listening on #{port}"
