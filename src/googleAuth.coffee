path        = require 'path'
https       = require 'https'
debug       = require('debug')('file:googleAuth')

getData = (reqOpt)->
    (done)->
        emailReq = https.request reqOpt, (res)->
            result = ''
            res.on 'data', (chunk)->
                result += chunk.toString()
            res.on 'end', ->
                if res.statusCode is 200 then done null, JSON.parse result 
                else done new Error(result) 
        do emailReq.end


module.exports = (next)->
    token = @get 'googleAccessToken'
    reqOpt = 
        hostname: 'www.googleapis.com'
        path: "/oauth2/v2/userinfo"
        method: 'GET'
        headers:
            Authorization: "Bearer #{token}"

    try
        {hd} = yield getData reqOpt
    catch e
        @throw 401, e
    
    if hd is 'eztable.com' then @body = {hd} else @throw 401, 'NOT EZTABLEr'
    yield next
