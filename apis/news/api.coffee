query = require './query'

module.exports.list = (req, res, next) ->
  #console.log req.params
  type = req.params.type
  page = req.query.p
  query.queryNewsList type, page, (results) ->
    res.send results
    next()

module.exports.detail = (req, res, next) ->
  type = req.params.type
  id = req.params.id
  query.queryNewsDetail type, id, (result) ->
    res.send result
    next()