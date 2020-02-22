import
  # oids,
  # times,
  # strutils,
  options
  # md5,
  # os

import json except `[]`
import jsonextra

import
  jester,
  # norm / mongodb,
  mongopool,
  bson,
  bson / marshal,
  nullable

import
  models
  # credentials

marshal(WebVisit)
marshal(WebDay)
marshal(WebMonth)

########################################
#
#  WEB TRACKING FUNCTIONS
#
########################################


proc create_webVisit*(db: var MongoConnection, request: Request) =
  try:
    #
    # prep
    #
    let now = getTime()
    var parms = newJObject()
    for k, v in request.params.pairs:
      parms[$k] = $v
    #
    # save the basic hit
    #
    var wv = WebVisit()
    wv.url = request.path
    wv.user_agent = "" #TBD
    wv.args = $parms
    wv.status_code = 200 # TBD
    wv.remote_addr = request.ip
    wv.x_forwarded_for = "" # TBD
    wv.date = now
    #
    discard db.insertOne("WebVisit", wv.toBson)
    #
    # upsert daily numbers
    #
    var temptime = now.utc
    temptime.nanosecond = 0
    temptime.second = 0
    temptime.minute = 0
    temptime.hour = 0
    let top_of_day = temptime.toTime
    try:
      var webDayDoc = db.find("WebDay", @@{"url": wv.url, "date": top_of_day}).returnOne()
      webDayDoc["count"] = webDayDoc["count"] + 1
      discard db.replaceOne("WebDay", @@{"_id": webDayDoc["_id"]}, webDayDoc)
    except:
      var wd = WebDay()
      wd.date = top_of_day
      wd.url = wv.url
      wd.count = 1
      discard db.insertOne("WebDay", wd.toBson)
    #
    # upsert monthly numbers
    #
    temptime.monthday = 1
    let top_of_month = temptime.toTime
    try:
      var webMonthDoc = db.find("WebMonth", @@{"url": wv.url, "date": top_of_month}).returnOne()
      webMonthDoc["count"] = webMonthDoc["count"] + 1
      discard db.replaceOne("WebMonth", @@{"_id": webMonthDoc["_id"]}, webMonthDoc)
    except:
      var wm = WebMonth()
      wm.date = top_of_month
      wm.url = wv.url
      wm.count = 1
      discard db.insertOne("WebMonth", wm.toBson)
  except:
    echo getCurrentExceptionMsg()


