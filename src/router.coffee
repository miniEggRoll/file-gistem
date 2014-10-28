stream              = require 'stream'
debug               = require('debug')('file:router')
path                = require 'path'
{getGist, getFile}  = require path.join(__dirname, 'getGist')

class collect extends stream.Transform
    constructor: (@cache, @path, @type)->
        super
        @buff = new Buffer(0)
    _transform: (chunk, dummy, cb)->
        @buff = Buffer.concat [@buff, chunk]
        @push chunk
        do cb
    _flush: (cb)->
        @cache.set @path, {@buff, @type}
        do cb

loadFile = (description, filename, _cache)->
    -->
        g = yield getGist(description)
        if g and file = g.files[filename]
            @type = file.type
            collector = new collect(_cache, @path, @type)
            res = yield getFile({description, filename}, g)
            @body = res.pipe collector
        else @throw 404, "can't find file #{description}/#{filename}"

module.exports = (app, _cache)->
    app.use require('koa-trie-router') app
    app.route '/gist/:description/:filename'
        .get (next)-->
            {filename, description} = @params
            filename ||= 'index.html'
            description ||= 'shared'
            yield loadFile(description, filename, _cache).call @
            yield next

    app.route '/gist/:description'
        .get (next)-->
            {description} = @params
            description ||= 'shared'
            filename = 'index.html'
            yield loadFile(description, filename, _cache).call @
            yield next

    app.route '/gist'
        .get (next)-->
            description = 'shared'
            filename = 'index.html'
            yield loadFile(description, filename, _cache).call @
            yield next

    app.route '/'
        .get (next)-->
            description = 'shared'
            filename = 'index.html'
            yield loadFile(description, filename, _cache).call @
            yield next
