Sequelize = require 'sequelize'
config = require '../config.database'

db = new Sequelize config.news.dbname, config.news.dbuser, config.news.dbpasswd,
  host : config.news.dbhost
  define :
    freezeTableName : true
    timestamps : false

News = db.define 'iehome_comments',
  id :
    type : 'int'
    field : 'cid'
  nid : 'int'
  ccontent : 'text'
  cuser : 'varchar'
  ctime : 'int'
  cip : 'varchar'
