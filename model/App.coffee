Sequelize = require 'sequelize'
config = require '../config.database'

db = new Sequelize config.mobile.dbname, config.mobile.dbuser, config.mobile.dbpasswd,
  host : config.mobile.dbhost
  define :
    freezeTableName : true
    timestamps : false

App = db.define 'mb_app_keys',
  id : 'int'
  appname : 'string'
  appkey : 'string'
  secret : 'string'

module.exports.getByAppkey = (appkey, callback) ->
  App.find {
      where : { appkey : appkey }
    }
    .then (app) ->
      callback undefined , app
    .catch (err) ->
      callback err, undefined