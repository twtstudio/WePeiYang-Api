auth = require './auth'

module.exports.login = (req, res, next) ->
  auth.login req.query.twtuname, req.query.twtpasswd, (result) ->
    res.send result
    next()

module.exports.bindTju = (req, res, next) ->

module.exports.unbindTju = (req, res, next) ->

module.exports.bindLib = (req, res, next) ->

module.exports.unbindLib = (req, res, next) ->