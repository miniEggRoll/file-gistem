_           = require 'underscore'
c           = require 'lru-cache'
formatDate  = require 'dateformat'
url         = require 'url'
path        = require 'path'
moment      = require 'moment'
debug       = require('debug')('file:index')
koa         = require 'koa'
route       = require path.join(__dirname, 'router')
{port}      = require "#{__dirname}/../config"

app = koa()
_cache = c {
    maxAge: 24*60*60*1000
}
maxSeconds = 3600
router = route app, _cache

etag = {}

app.use (next)-->
    if !etag[@path]? then etag[@path] = Date.now()
    if !@headers.refreshgist? and cache = _cache.get @path 
        {buff, type} = cache
        @body = buff
        @type = type
    else
        yield next
        etag[@path] = Date.now()
    
    @set 'etag', etag[@path]
    if @fresh 
        @status = 304
        return 
    @set "Cache-Control", "max-age=" + maxSeconds
    @set "Expires", formatDate(moment().startOf('day').add(1, 'day').toDate(), "ddd, dd mmm yyyy HH:MM:ss 'GMT'", true)
    
app.use router
app.listen port, -> console.log "listening on #{port}"
