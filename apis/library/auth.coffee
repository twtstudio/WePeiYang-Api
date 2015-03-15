request = require 'request'
common = require '../../common'
config = require './config'

exports.login = (req, callback) ->
  username = req.query.username
  password = req.query.password
  cookies = request.jar()
  request {
    url : 'http://ilink.lib.tju.edu.cn/opac/reader/doLogin'
    method : 'POST'
    headers : {
      'HOST' : 'ilink.lib.tju.edu.cn'
      'User-Agent' : config.UA
    }
    form : {
      rdid : username
      rdPasswd : common.md5 password
      returnUrl : ''
    }
    jar : cookies
  }, (err, response, body) ->
    if err
      console.log err
      callback { info : '登录图书馆出错' }, null

    if response.statusCode is 200
      callback { info : '图书馆账号或密码出错'}, null
    else if response.statusCode is 302
      callback { location : response.headers.location }, cookies
    else
      callback { info : '未知错误' }, null