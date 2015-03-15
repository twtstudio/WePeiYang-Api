request = require 'request'

crypto = require 'crypto'
twtapi = require './TWTApi'
config = require '../../keys'

module.exports.login = (req, callback) ->
  username = req.query.twtuname
  password = req.query.twtpasswd
  TWTApiHelper = new TWTApi.TWTAPIHelper config.twtapi.domain, config.twtapi.apikey
  TWTApiHelper.login username, password, (data) ->
    if data is false
      callback
        info : "账号或者密码错误，登录失败，请重新登录"
    else
      if data.isteacher isnt "0"
        callback
          info : "登录账号为老师"
      else
        TWTApiHelper.getStudentInfo req.query.twtuname, (result) ->
          if result is false
            callback
              info : "获取个人详细信息失败"
          else
            result.token = generateToken()
            callback result

module.exports.checkTju = (tjuuname, tjupasswd, callback) ->

module.exports.checkLib = (libuname, libpasswd, callback) ->

generateToken = () ->
  token = crypto.randomBytes(48).toString 'base64'
  token.replace(/\//g, '_').replace /\+/g,'-'
