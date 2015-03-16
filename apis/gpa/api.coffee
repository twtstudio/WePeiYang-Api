info = require './fetchGpa'

module.exports.getGpa = (req, res, next) ->
  info.fetchGpa req.query.tjuuname, req.query.tjupasswd, (err, result) ->
    if err
      res.send err
    else
      res.send result
    next()