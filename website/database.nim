import
  oids,
  times,
  strutils,
  options,
  md5,
  os

import json except `[]`
import jsonextra

import
  jester,
  norm / mongodb,
  nullable

import
  models,
  misc,
  credentials

dbAddCollection(WebVisit)
dbAddCollection(WebDay)
dbAddCollection(WebMonth)

connectMongoPool(mongoDbUrl, minConnections = 4, maxConnections = 12, loose=true)


########################################
#
#  WEB TRACKING FUNCTIONS
#
########################################


proc create_webVisit*(request: Request) =
  try:
    withDb:
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
      echo request.headers
      wv.user_agent = "" #TBD
      wv.args = $parms
      wv.status_code = 200 # TBD
      wv.remote_addr = request.ip
      wv.x_forwarded_for = "" # TBD
      wv.date = now
      #
      wv.insert()
      #
      # upsert daily numbers
      #
      var temptime = now.utc
      temptime.nanosecond = 0
      temptime.second = 0
      temptime.minute = 0
      temptime.hour = 0
      let top_of_day = temptime.toTime
      var wd = WebDay()
      let nwd = WebDay.getOneOption(cond = @@{"url": wv.url, "date": top_of_day})
      if nwd.isSome:
        wd = nwd.get
        wd.count += 1
        wd.update()
      else:
        wd.date = top_of_day
        wd.url = wv.url
        wd.count = 1
        wd.insert()
      #
      # upsert monthly numbers
      #
      temptime.monthday = 1
      let top_of_month = temptime.toTime
      var wm = WebMonth()
      let nwm = WebMonth.getOneOption(cond = @@{"url": wv.url, "date": top_of_month})
      if nwm.isSome:
        wm = nwm.get
        wm.count += 1
        wm.update()
      else:
        wm.date = top_of_month
        wm.url = wv.url
        wm.count = 1
        wm.insert()
  except:
    echo getCurrentExceptionMsg()


