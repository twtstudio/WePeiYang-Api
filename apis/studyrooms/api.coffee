POST_URL = 'http://e.tju.edu.cn/Education/toModule.do?prefix=/Education&page=/schedule.do?todo=displayWeekBuilding&schekind=6'

request = require('request')
iconv = require('iconv-lite')
config = require('../../config')
studyConfig = require('./config')
cheerio = require('cheerio')

module.exports.getEmptyRooms = (req, res, next) ->
  {week, building, start, len} = transferParams(req.params)
  chunks = []
  response = ''
  request({
      url : POST_URL
      method : 'POST'
      headers : {
        'User-Agent' : config.request.UA
      }
      qs : {
        todo : 'displayWeekBuilding'
        week : week
        building_no : building
      }
    },
    (rErr, rRes, rBody) ->
      if rErr
        next(rErr)
      res.send isRoomEmpty(response, start, len)
      next()
  ).on('data', (data) ->
    chunks.push(data);
  ).on('end', (res) ->
    response = iconv.decode(Buffer.concat(chunks), 'gbk')
  )

transferParams = (params) ->
  {building, interval, startlen} = params
  {day, week} = getTarget(interval)

  start = parseInt(startlen[0]) + day * 6 - 1
  len = parseInt(startlen[1])

  return {week, building, start, len}

getTarget = (interval) ->
  week = studyConfig.week
  tmp = parseInt(new Date().getDay())
  if parseInt(tmp) == 0
    day = 6
  else
    day = tmp - 1

  value = day + interval
  if value == 7
    day = 0
  else if value == 8
    day = 1

  if  value > 6
    week = week + 1

  return {day, week}

isRoomEmpty = (res, start, len) ->
  $ = cheerio.load(res)
  rooms = []
  $("[cellpadding='2'] > tr").each ->
    tds = $(@).find('td')
    if tds.length == 43
      obj = {}
      obj.is_seldom = ''
      for td in tds
        if td.attribs.bgcolor == '#336699'
          obj.room = $(td).find('font').text()
        else
          if $(td).find('font').attr('color') == 'black'
            obj.is_seldom += '0'
          else
            obj.is_seldom += '1'
      rooms.push(obj)
  result = []
  for room in rooms
    if room.is_seldom.substr(start, len).search(/0/) == -1
      result.push(room.room)
  return result