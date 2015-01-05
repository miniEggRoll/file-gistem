https   = require 'https'
_       = require 'underscore'
debug   = require('debug')('file:getGist')
path    = require 'path'
gistem  = require 'gistem'
Q       = require 'q'

{user, password} = process.env

gist = new gistem {user, password}

module.exports.getGist = (description)->
    Q.Promise (resolve)->
        gist.init()
        .then (token)->
            gist.list token
        .then (gists)->
            g = _.findWhere gists, {description}
            resolve g

module.exports.getFile = ({filename, description}, {files})->
    Q.Promise (resolve)->
        {raw_url} = files[filename]
        reqOpt =
            hostname: 'gist.githubusercontent.com'
            port: 443
            path: raw_url.split('gist.githubusercontent.com')[1]
            method: 'GET'
            auth: "#{gist.token}:x-oauth-basic"
            headers:
                'User-Agent': user
        req = https.request reqOpt, (res)->
            resolve res
        do req.end
