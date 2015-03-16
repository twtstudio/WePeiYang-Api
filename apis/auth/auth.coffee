request = require 'request'

twtapi = require './TWTApi'
config = require '../../keys'
serializer = require 'serializer'

SecureSerializer = new serializer.createSecureSerializer config.serialize.encrypt, config.serialize.signing

module.exports.login = (username, password, callback) ->
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
        TWTApiHelper.getStudentInfo username, (result) ->
          if result is false
            callback
              info : "获取个人详细信息失败"
          else
            result.token = generateToken()
            callback result

module.exports.checkTju = (tjuuname, tjupasswd, callback) ->
  cookies = request.jar()
  request {
    url: 'http://e.tju.edu.cn/Main/logon.do'
    method: 'POST'
    jar: cookies
    form:
      uid: tjuuname
      password: tjupasswd
  }, (err, res, body) ->
    if err
      callback err, null
    if res.statusCode is 302
      callback null, cookies
    else
      callback { info : '账号或密码错误' }, null


module.exports.checkLib = (libuname, libpasswd, callback) ->

generateToken = () ->

