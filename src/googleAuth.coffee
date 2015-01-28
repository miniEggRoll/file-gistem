path            = require 'path'
https           = require 'https'
tokenGen        = require 'firebase-token-generator'
debug           = require('debug')('file:googleAuth')

{FIREBASE_SECRET}  = process.env

tokenGenerator = new tokenGen FIREBASE_SECRET

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

signFirebaseToken = ({hd, email})->
    uid = email
    firebase_token = tokenGenerator.createToken {uid, hd}
    @body = {firebase_token}

module.exports = (next)->
    if @method is 'GET' and /^\/auth(\/[^\/]*)*$/i.test @path
        token = @get 'googleAccessToken'
        reqOpt =
            hostname: 'www.googleapis.com'
            path: "/oauth2/v2/userinfo"
            method: 'GET'
            headers:
                Authorization: "Bearer #{token}"
        try
            data = yield getData reqOpt
            {hd, email} = data
            debug email
        catch e
            @throw 401, e.message

        if hd is 'eztable.com' then signFirebaseToken.call @, {hd, email}
        else @throw 401, 'NOT EZTABLEr'
    yield next
