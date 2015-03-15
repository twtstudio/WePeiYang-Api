request = require 'request'

class TWTAPIHelper
  constructor : (@domain, @apikey) ->

  query : (method, query, callback) ->
    query.api_key = @apikey
    query.method = method
    request {
      url : 'http://www.twt.edu.cn/api/?domain=' + @domain
      method : 'POST'
      form : query
    }, (error, response, data) ->
      if error
        callback false
      data = JSON.parse data
      if data.flag isnt 1
        callback false
      else
        callback data

  login : (username, password, callback) ->
    data = {}
    data.username = username
    data.password = password
    data.ishashed = 0
    @query 'twt.login', data, callback

  getStudentInfo : (twtname, callback) ->
    data = {}
    data.field = 'twtname'
    data.keyword = twtname
    @query 'student.info', data, callback

module.exports.TWTAPIHelper = TWTAPIHelper