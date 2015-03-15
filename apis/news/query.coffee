async = require 'async'

News = require '../../model/News'
common = require '../../common'

module.exports.queryNewsList = (type, page, callback) ->
  News.findList type, page, (err, results) ->
    if err
      callback err
    else
      for item in results
        item.addat = common.unixTimeConvert item.addat, 'yyyy-mm-dd'
      callback results

module.exports.queryNewsDetail = (type, id, callback) ->
  News.findDetail type, id, (err, news) ->
    if err
      callback err
    else
      news.addat = common.unixTimeConvert news.addat, 'yyyy-mm-dd'
      callback news

module.exports.queryCommentsList = (id, callback) ->

module.exports.insertComment = (callback) ->