config = module.exports = {}

config.defaults =
  SERVER_NAME : 'WePeiYang-Api'
  VERSION     : '0.0.1'

config.http =
  IP_ADDRESS : '127.0.0.1'
  PORT       : 3000

config.request =
  UA : 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36'
  timeout : 60000

config.status =
  GET_SUCCESS      : 200
  POST_SUCCESS     : 201
  METHOD_TO_ASYNC  : 202
  GET_RANGES       : 206
  BAD_REQUEST      : 400
  AUTH_ERROR       : 401
  PERMISSION_DENY  : 403
  NOT_FOUND        : 404
  WRONG_PARAMS     : 422
  TOO_MANY_REQUEST : 429
  SERVER_ERROR     : 500