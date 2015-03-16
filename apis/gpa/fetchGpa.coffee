request = require 'request'
iconv = require 'iconv-lite'
cheerio = require 'cheerio'
async = require 'async'

auth = require '../auth/auth'
common = require '../../common'

termsname = ['大一上', '大一下', '大二上', '大二下', '大三上', '大三下', '大四上', '大四下', '大五上', '大五下', '传奇大六', 'GoodBye']

module.exports.fetchGpa = (tjuuname, tjupasswd, callback) ->
  async.waterfall [
    (cb) ->
      auth.checkTju tjuuname, tjupasswd, (err, cookies) ->
        if err or cookies is null
          cb err
        else
          cb null, cookies

    (cookies, cb) ->
      _fetchPageUrl cookies, (err, result) ->
        cb err if err isnt null
        cb null, cookies, result

    (cookies, urls, cb) ->
      _fetchGpaDetail cookies, urls, (err, result) ->
        if err
          cb err
        else
          cb null, result

    (terms, cb) ->
      _calculateGpa terms, (terms, stat, all) ->
        cb null, terms, stat, all

    (terms, stat, all, cb) ->
      _formatData terms, stat, all, (result) ->
        callback result
        cb null

  ], (err) ->
    if err
      callback err

_fetchPageUrl = (cookies, callback) ->
  request {
    url : 'http://e.tju.edu.cn/Education/stuachv.do'
    method : 'GET'
    jar : cookies
  }, (err, res, body) ->
    if err
      callback err, null
    else
      result = []
      $ = cheerio.load body
      $("table[width='90%']").find("td[colspan='2']").each ->
        item = $(@).find('a')['0']
        if item isnt undefined
          result.push
            name : item.attribs.href.split('=').pop()
            href : item.attribs.href
      callback null, result

_fetchGpaDetail = (cookies, urls, callback) ->
  result = {}
  async.each urls, (url, cb) ->
    _requestPage cookies, url.href, (err, body) ->
      if err
        result[url.name] = {}
        cb null
      else
        _parseHTML body, (items) ->
          result[url.name] = items
          cb null
  , (err) ->
    if err
      callback null, []
    else
      callback null, result

_requestPage = (cookies, href, callback) ->
  chunks = []
  request {
    url : 'http://e.tju.edu.cn' + href
    method : 'GET'
    jar : cookies
  }
  .on 'data', (data) ->
    chunks.push data
  .on 'end',  ->
    response = iconv.decode Buffer.concat(chunks), 'gbk'
    callback null, response

_parseHTML = (body, callback) ->
  result = []
  $ = cheerio.load body
  $("table[bgcolor='#999999']").find("tr[bgcolor='#FFFFFF']").each ->
    tds = $(@).find('td')
    item = {}
    if tds.length is 9
      [ item.no, item.name, item.type, item.credit, item.score, item.reset ] = [ $(tds['1']).text().trim(), $(tds['2']).text().trim(), $(tds['3']).text().trim(), $(tds['5']).text().trim(), $(tds['6']).text().trim(), $(tds['8']).text().trim() ]
    result.push item

  _fixParams result, (arr) ->
    callback arr

_fixParams = (arr, callback) ->
  for item in arr
    item.type = if item.type is '--' then 1 else 0
    item.reset = if item.reset in ['重修', '安排重修'] then 1 else 0

    if item.credit is '.5'
      item.credit = '0.5'
    item.credit = parseFloat item.credit

    if item.score is '评价'
      item.score = -1
    item.score = parseFloat item.score

  callback arr

_calculateGpa = (terms, callback) ->
  stat = {}
  totalScore = 0
  totalCredit = 0
  totalGpa = 0

  Object.keys(terms).forEach (term) ->
    credit = 0
    score = 0
    gpa = 0
    avscore = 0
    avgpa = 0

    for item in terms[term]
      if item.type isnt 1 and item.score >= 60 and item.score <= 100 and item.name isnt '社会实践'
        credit += parseFloat item.credit
        score += item.credit * parseFloat item.score
        sgpa = _getGpa item.score
        gpa += item.credit * sgpa
        item.gpa = sgpa

    avscore = if credit is 0 then 60.00 else score / credit
    avgpa = if credit is 0 then 1.00 else gpa / credit

    totalCredit += credit
    totalGpa += gpa
    totalScore += score

    stat[term] =
      credit : credit
      score : parseFloat avscore.toFixed 2
      gpa : parseFloat avgpa.toFixed 2

  avscore = if totalCredit is 0 then 60.00 else totalScore / totalCredit
  avgpa = if totalCredit is 0 then 1.00 else totalGpa / totalCredit

  all =
    credit : totalCredit
    score : parseFloat avscore.toFixed 2
    gpa : parseFloat avgpa.toFixed 2

  callback terms, stat, all

_formatData = (terms, stat, all, callback) ->
  result = {}
  result.stat = all
  result.terms = []

  termsKeys = Object.keys stat
  _mapTermsName termsKeys, (names) ->
    termsKeys.forEach (term) ->
      result.terms.push
        term : term
        name : names[term]
        stat : stat[term]
        scores : terms[term]

  callback result

_getGpa = (score) ->
  if score >= 90 and score <= 100
    return 4.0
  else if score >=85 and score < 90
    return 3.7
  else if score >= 82 and score < 85
    return 3.3
  else if score >= 78 and score < 82
    return 3.0
  else if score >= 75 and score < 78
    return 2.7
  else if score >= 72 and score < 75
    return 2.3
  else if score >= 68 and score < 72
    return 2.0
  else if score >= 64 and score < 68
    return 1.5
  else if score >= 60 and score < 64
    return 1.0
  else
    return 0.0

_mapTermsName = (terms, callback) ->
  result = {}
  terms.sort()
  _generateTerms terms[0].substr(0, 2), (map) ->
    terms.forEach (term) ->
      result[term] = termsname[map[term]]
    callback result

_generateTerms = (start, callback) ->
  map = {}
  arr = []
  start = parseInt start
  for i in [0..5]
    k = start + i
    arr.push common.formatNumber(k) + common.formatNumber(k + 1) + '1'
    arr.push common.formatNumber(k) + common.formatNumber(k + 1) + '2'
  for name, i in arr
    map[name] = i
  callback map