c           = require 'lru-cache'
formatDate  = require 'dateformat'
path        = require 'path'
debug       = require('debug')('file:index')
koa         = require 'koa'
router      = require path.join(__dirname, 'router')
{port}      = require "#{__dirname}/../config"

_cache = c()

app = koa()

app.use (next)-->
    if !@headers.refreshgist? and  cache = _cache.get @path 
        {buff, type} = cache
        @body = buff
        @type = type
    else 
        yield next

router app, _cache
app.listen port, -> console.log "listening on #{port}"
