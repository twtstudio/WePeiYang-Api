restify = require 'restify'
config = require './config'

common = require './common'
studyrooms = require './apis/studyrooms/api'
library = require './apis/library/api'
auth = require './apis/auth/api'
news = require './apis/news/api'
App = require './model/App'

server = restify.createServer
  name : config.defaults.SERVER_NAME
  version : config.defaults.VERSION

server.use restify.queryParser()
server.use restify.gzipResponse()

# check user-agent
server.use (req, res, next) ->
  if req.headers['user-agent']
    next()
  else
    next new restify.InvalidHeaderError 'should use user-agent'

# check app token
server.use (req, res, next) ->
  if req.query.appkey and req.query.token
    App.getByAppkey req.query.appkey, (err, app) ->
      if err || app is null
        next new restify.NotAuthorizedError 'appkey not found'

      keys = (key for key in Object.keys req.params when key not in ['token', 'appkey'])
      keys.sort()

      arr = (key + req.params[key] for key in keys)
      arr.unshift req.params.appkey
      arr.push app.secret

      sign = common.sha1 arr.join ''
      console.log sign
      if sign is req.params.token
        next()
      else
        next new restify.NotAuthorizedError 'wrong signature'
  else
    next new restify.MissingParameterError 'should set appkey and token'

# check user token
server.use (req, res, next) ->
  next()

# request storage
server.use (req, res, next) ->
  next()

paths =
  '/api/studyrooms/:building/:interval/:startlen' : { privacy : 'public', func : studyrooms.getEmptyRooms, method : 'get' }
  '/api/library/search/:title' : { privacy : 'public', func : library.search, method : 'get' }

server.get {path: '/api/studyrooms/:building/:interval/:startlen', version: '1'}, studyrooms.getEmptyRooms
server.get {path: '/api/library/search/:title', version: '1'}, library.search
server.get {path: '/api/library/info', version: '1'}, library.info
server.get {path: '/api/auth/login', version: '1'}, auth.login
server.get {path: '/api/news/:type', version: '1'}, news.list
server.get {path: '/api/news/:type/:id', version: '1'}, news.detail

server.listen config.http.PORT, config.http.IP_ADDRESS, ->
  console.log "server is now listening on port #{ config.http.PORT }"