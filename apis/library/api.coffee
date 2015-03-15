search = require './search'
auth = require './auth'
info = require './info'

module.exports.search = (req, res, next) ->
  search.searchBooks req, res, next

module.exports.info = (req, res, next) ->
 auth.login req, (result, cookies) ->
   #console.log result
   if cookies is null
     res.send 400, result
     next()
   else
     info.fetchInfo cookies, (result) ->
       res.send result
       next()