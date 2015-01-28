debug   = require('debug')('file:git')
https   = require 'https'
mime    = require 'mime'
c       = require 'lru-cache'
stream  = require 'stream'
path    = require 'path'

class collect extends stream.Transform
    constructor: (@cache, @path)->
        super
        @buff = new Buffer(0)
    _transform: (chunk, dummy, cb)->
        @buff = Buffer.concat [@buff, chunk]
        @push chunk
        do cb
    _flush: (cb)->
        @cache.set @path, @buff
        do cb

_cache = c {maxAge: +MAX_SECONDS*1000}

{MAX_SECONDS} = process.env
{GIT_OWNER, GIT_REPO, GIT_BRANCH, GIT_SECRET, GIT_ACCOUNT} = process.env

module.exports = (next)->
    {headers, method} = @
    filePath = @path
    if method is 'GET'
        filePath += '/index.html' unless path.extname filePath
        filePath = path.normalize filePath
        debug 'path %s', filePath
        
        reload = headers.refreshgist? or !_cache.has filePath
        unless reload then @body = _cache.get filePath
        else
            debug 'reload %s', filePath
            reqOpt =
                hostname: 'raw.githubusercontent.com'
                port: 443
                path: "/#{GIT_OWNER}/#{GIT_REPO}/#{GIT_BRANCH}#{filePath}"
                method: 'GET'
                auth: "#{GIT_SECRET}:x-oauth-basic"
                headers:
                    'User-Agent': GIT_ACCOUNT
            try
                res = yield (done)->
                    https.get reqOpt, (res)->
                        done null, res
            catch e
                @throw e.error.code, e.error.message
            
            if res.statusCode is 200
                @body = res.pipe new collect(_cache, filePath)
                @type = mime.lookup filePath
    yield next
