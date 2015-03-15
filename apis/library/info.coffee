request = require 'request'
cheerio = require 'cheerio'
config = require './config'

exports.fetchInfo = (cookies, callback) ->
  request {
    url : config.INFO_URL
    method : 'GET'
    headers : {
      'HOST': 'ilink.lib.tju.edu.cn'
      'User-Agent': 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36'
    }
    jar : cookies
  }, (error, response, body) ->
    if error
      callback { status : '', info : '查询个人数据出错' }

    if response.statusCode is 302
      callback { info : "登录出错，请重新登录" }
    else
      result = extractInfo body
      callback result

extractInfo = (html) ->
  {owe, rent, all} = extractMoneyInfo(html)
  books = extractBookInfo(html)
  {owe, rent, all, books}

extractMoneyInfo = (html) ->
  info =
    owe : '0.0'
    rent : '0'
    all : '0'

  $ = cheerio.load html
  $("table[style='margin:10px;width: 680px;']").find('td').each ->
    arr =  $(@).text().split('】')
    title = arr[0].replace('【', '').trim()
    content = arr[1] if arr.length != 1
    if title isnt undefined
      if title is '本馆已借/可借' and content isnt undefined
        tmp = content.trim().split '/'
        info.rent = tmp[0]
        info.all = tmp[1]
      else if title is '欠款' and content isnt undefined
        tmp = content.replace(' ', '').split '【'
        info.owe = tmp[0].trim() if tmp[0] isnt undefined

  return info

extractBookInfo = (html) ->
  books = []
  $ = cheerio.load html
  $("table[cellpadding='0']").find('tr').each ->
    if @.attribs.id != 'contentHeader'
      book = []
      $(@).find('td').each ->
        book.push $(@).text().trim()
      books.push matchBookInfo book
  return books

matchBookInfo = (book) ->
  item = {}
  for info, i in book
    switch i
      when 1 then item.title = info
      when 2 then item.author = info
      when 3 then item.position = info
      when 4 then item.currentloc = info
      when 6 then item.rentdate = info
      when 7 then item.backdate = info
  return item