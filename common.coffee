crypto = require 'crypto'
dateformat = require 'dateformat'

module.exports.formatNumber = (number) ->
  if (number < 10)
    return '0' + number
  else
    return number.toString()

module.exports.md5 = (string) ->
  crypto.createHash('md5').update(string).digest 'hex'

module.exports.sha1 = (string) ->
  crypto.createHash('sha1').update(string).digest 'hex'

module.exports.unixTimeConvert = (unixtime, formatter = 'yyyy-mm-dd HH:MM:ss') ->
  date = new Date unixtime * 1000
  dateformat date, formatter

module.exports.checkQueries = (queries, checkList, callback) ->
  for key in checkList
    queries[key]