Q       = require 'q'
koa     = require 'koa'
https   = require 'https'
_       = require 'underscore'
gistem  = require 'gistem'
config  = require "#{__dirname}/../config"

{acc} = config

gist = new gistem acc
gist._cache = {}
app = koa()
app.use require('koa-trie-router') app

app.route '/gist/:description/:filename'
    .get (next)-->
        {filename, description} = @params
        ext = filename.split('.').pop()
        switch ext
            when 'html'
                @type = 'text/html'
            when 'js'
                @type = 'text/javascript'
            when 'css'
                @type = 'text/css'
        g = yield getGist(gist, description)
        @body = yield getFile(@params, g)
        yield next

app.listen 20010, -> console.log 'listen on 20010'

getGist = (gist, description)->
    Q.Promise (resolve)->
        cache = gist._cache[description]
        if cache? then resolve cache
        else
            gist.init()
            .then (token)->
                gist.list token
            .then (gists)->
                g = _.findWhere gists, {description}
                gist._cache[description] = g
                resolve g

getFile = ({filename, description}, g)->
    Q.Promise (resolve)->
        {files} = g
        {raw_url} = files[filename]
        cache = gist._cache[raw_url]
        if cache then resolve cache
        else
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
