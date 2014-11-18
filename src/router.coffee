stream              = require 'stream'
debug               = require('debug')('file:router')
path                = require 'path'
{getGist, getFile}  = require path.join(__dirname, 'getGist')
googleAuth          = require path.join(__dirname, 'googleAuth')

class collect extends stream.Transform
    constructor: (@cache, @path, @type, @raw_url)->
        super
        @buff = new Buffer(0)
    _transform: (chunk, dummy, cb)->
        @buff = Buffer.concat [@buff, chunk]
        @push chunk
        do cb
    _flush: (cb)->
        @cache.set @path, {@buff, @type, @raw_url}
        do cb

loadFile = (description, filename, _cache)->
    ->
        g = yield getGist(description)
        if g and file = g.files[filename]
            {@type, @raw_url} = file
            res = yield getFile({description, filename}, g)
            @body = res.pipe new collect(_cache, @path, @type, @raw_url)
            @set 'gist_raw_url', @raw_url
        else @throw 404, "can't find file #{description}/#{filename}"

defaultParams = (params)->
    {filename, description} = params
    filename ||= 'index.html'
    description ||= 'shared'
    {filename, description}

module.exports = (app, _cache)->
    router = require('koa-trie-router') app
    app.route [
        '/gist/:description/:filename'
        '/gist/:description/'
        '/gist/:description'
        '/gist/'
        '/gist'
        '/'
    ]
    .get (next)->
        {description, filename} = defaultParams @params
        yield loadFile(description, filename, _cache).call @
        yield next

    app.route '/auth/:provider'
    .get googleAuth

    router
