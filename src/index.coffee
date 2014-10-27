_       = require 'underscore'
Q       = require 'q'
debug   = require('debug')('file:index')
koa     = require 'koa'
https   = require 'https'
gistem  = require 'gistem'

config  = require "#{__dirname}/../config"
{port, acc} = config
port ?= 20010

gist = new gistem acc

app = koa()
app.use require('koa-trie-router') app

app.route '/gist/:description/:filename'
    .get (next)-->
        {filename, description} = @params
        filename ||= 'index.html'
        description ||= 'shared'

        g = yield getGist(gist, description)
        if g and file = g.files[filename]
            @type = file.type
            @body = yield getFile({description, filename}, g)
        else @throw 404, "can't find file #{description}/#{filename}"

        yield next

app.route '/gist/:description'
    .get (next)-->
        {description} = @params
        description ||= 'shared'
        @redirect "/gist/#{description}/index.html"

app.route '/gist'
    .get (next)-->
        @redirect "/gist/shared/index.html"

app.route '/'
    .get (next)-->
        @redirect "/gist"

app.listen port, -> console.log "listening on #{port}"

getGist = (gist, description)->
    Q.Promise (resolve)->
        gist.init()
        .then (token)->
            gist.list token
        .then (gists)->
            g = _.findWhere gists, {description}
            resolve g

getFile = ({filename, description}, {files})->
    Q.Promise (resolve)->
        {raw_url} = files[filename]
        reqOpt =
            hostname: 'gist.githubusercontent.com'
            port: 443
            path: raw_url.split('gist.githubusercontent.com')[1]
            method: 'GET'
            auth: "#{gist.token}:x-oauth-basic"
            headers:
                'User-Agent': acc.user
        req = https.request reqOpt, (res)->
            resolve res
        do req.end
