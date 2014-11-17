http        = require 'http'
c           = require 'lru-cache'
formatDate  = require 'dateformat'
url         = require 'url'
path        = require 'path'
moment      = require 'moment'
debug       = require('debug')('file:index')
koa         = require 'koa'
route       = require path.join(__dirname, 'router')
{port}      = require "#{__dirname}/../config"

module.exports = ->
    app = koa()

    _cache = c {
        maxAge: 24*60*60*1000
    }
    router = route app, _cache

    maxSeconds = 3600
    etag = {}

    app.use (next)->
        unless @path is '/auth/google'
            if !etag[@path]? then etag[@path] = Date.now()
            reload = !@headers.refreshgist? and cache = _cache.get @path
            if reload
                {buff, type} = cache
                @body = buff
                @type = type
            else
                yield next
                etag[@path] = Date.now()

            @set 'etag', etag[@path]
            @set 'Cache-Control', 'max-age=' + maxSeconds
            @set 'Expires', moment().startOf('day').add(1, 'day').format 'ddd, DD MMM YYYY HH:mm:ss [GMT]'
            @status = 304 if @fresh
        else yield next

    app.use router
    http.createServer app.callback()
    .listen port, -> console.log "serving gist on #{port}"