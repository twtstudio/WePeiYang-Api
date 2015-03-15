request = require 'request'
cheerio = require 'cheerio'
xml = require 'xml2js'
async = require 'async'
config = require './config'
utils = require '../../common'

exports.searchBooks = (req, res, next) ->
  title = req.params.title
  async.waterfall [
    (callback) ->
      request(
        url : config.SEARCH_URL + title
        method: 'GET'
        headers : {
          'HOST' : 'ilink.lib.tju.edu.cn'
          'User-Agent' : 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36'
        }
        (error, rEes, body) ->
          if error
            next error

          result = fetchBooks(body)
          callback null, result.books, result.bookIds
      )

    (books, bookIds, callback) ->
      fetchBookPosition bookIds, (result) ->
        if result != null and result.length != 0
          for record in result
            books[record.bookrecno.shift()].position = record.callno

        callback null, books, bookIds

    (books, bookIds, callback) ->
      fetchBookStatus bookIds, (result) ->
        if result != null and result.length != 0
          Object.keys(result).forEach (key) ->
            books[key].status = result[key]

        callback null, books

    (books, callback) ->
      response = []
      Object.keys(books).forEach (key) ->
        response.push books[key]
      res.send response
      next()
      callback null

  ], (err) ->
    if (err)
      console.log err
      res.send err
      next()

fetchBooks = (body) ->
  $ = cheerio.load body
  books = {}
  bookIds = []

  $(body).find('div.bookmeta').each ->
    book = {}
    book.no = @.attribs.bookrecno
    book.title = fetchBookTitle($(@).find('span.bookmetaTitle').first().text().trim())
    tmp = fetchBookAuthorAndPublisher($(@).find('a'))
    book.author = tmp.author
    book.publisher = tmp.publisher
    book.position = ''
    book.status = {}

    books[book.no] = book
    bookIds.push book.no

  return {books, bookIds}


fetchBookTitle = (title) ->
  if (title.indexOf('/', title.length - 1) != -1)
    title = title.substr(0, title.length - 1).trim()
  return title

fetchBookAuthorAndPublisher = (html) ->
  result =
    author : ""
    publisher : ""

  html.each ->
    if @.attribs.href.indexOf('searchWay=author') isnt -1
      result.author = convertUrlToData(@.attribs.href)
    else if @.attribs.href.indexOf('searchWay=publisher') isnt -1
      result.publisher = convertUrlToData(@.attribs.href)

  return result

convertUrlToData = (url) ->
  url.substr(url.indexOf('&q=') + 3)

fetchBookPosition = (ids, callback) ->
  request(
    url : config.GET_CALLNO_URL + ids.join(',')
    method : 'GET'
    headers : {
      'HOST' : 'ilink.lib.tju.edu.cn'
      'User-Agent' : 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36'
    }
    (err, res, body) ->
      if (err)
        return []
      xml.parseString body, (err, result) ->
        if err
          callback []
        if result != ''
          callback result.records.record
        else
          callback []
  )

fetchBookStatus = (ids, callback) ->
  result = []
  async.each ids, (item, cb) ->
    request(
      url : config.GET_BOOK_STATUS_URL + item
      method : 'GET'
      headers : {
        'HOST' : 'ilink.lib.tju.edu.cn'
        'User-Agent' : 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36'
      }
      (err, res, body) ->
        info = {}
        if (err)
          result[item] = info
          cb null

        obj = JSON.parse body

        info.allnum = obj.holdingList.length
        info.outnum = Object.keys(obj.loanWorkMap).length
        info.books = []
        for book in obj.holdingList
          tmp = getBookStatus(obj, book)
          v = {}
          v.state = tmp.state
          v.returnDate = tmp.returnDate
          v.currentlib = obj.libcodeMap[book.curlib]
          v.currentloc = obj.localMap[book.curlocal]
          #v.currentlib = book.curlib
          #v.currentloc = book.curlocal
          info.books.push v

        result[item] = info
        cb null
    )
  , (err) ->
    if (err)
      callback []
    callback result

# 获取图书馆藏状态，根据图书馆自身的 js 完成
getBookStatus = (obj, book) ->
  state = book.state
  returnDate = ''

  if state is 2 and obj.libcodeDeferDateMap[book.curlib] > 0
    currentDate = new Date()
    todayDate = new Date(currentDate.getFullYear(),
      currentDate.getMonth(), currentDate.getDate()).getTime()
    dateStr = book.indate.split("-")
    bookDate = new Date(dateStr[0], dateStr[1]-1, dateStr[2]).getTime()
    intervalDays = new Number((todayDate-bookDate) / (24*60*60*1000))
    if intervalDays < obj.libcodeDeferDateMap[book.curlib] + 1
      state = 1;

  if state is 3
    loanWork = obj.loanWorkMap[book.barcode]
    if loanWork isnt undefined
      returnDate = formatReturnDate(new Date(loanWork.returnDate))

  return {state: obj.holdStateMap[state].stateName, returnDate: returnDate}
  #{state: state, returnDate: returnDate}

formatReturnDate = (date) ->
  year = date.getFullYear()
  month = utils.formatNumber date.getMonth() + 1
  day = utils.formatNumber date.getDate()
  "#{year}-#{month}-#{day}"