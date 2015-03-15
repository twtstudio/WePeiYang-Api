Sequelize = require 'sequelize'
config = require '../config.database'

db = new Sequelize config.news.dbname, config.news.dbuser, config.news.dbpasswd,
  host : config.news.dbhost
  define :
    freezeTableName : true
    timestamps : false

News = db.define 'iehome_news',
  id :
    type : 'int'
    field : 'index'
  subject : 'string'
  content : 'text'
  addat : 'string'
  visitcount : 'int'

module.exports.findList = (type, page, callback) ->
  News.findAll {
      attributes : ['id', 'subject', 'addat', 'visitcount']
      where :
        isshow : 1
        newstype : type
      offset : page * 20
      limit : 20
      order : 'addat DESC'
    }
    .then (results) ->
      callback null, results
    .catch (err) ->
      callback err, null

module.exports.findDetail = (type, id, callback) ->
  News.find id
    .then (news) ->
      callback null, news
    .catch (err) ->
      callback err, null