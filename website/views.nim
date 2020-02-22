import
  # oids,
  # macros,
  # base64,
  times,
  re,
  strutils,
  system

import json except `[]`

import
  jester,
  jestermongopool,
  jestercookiemsgs,
  jesterjson,
  nullable,
  mongopool

import
  jsonextra,
  database,
  pages,
  misc,
  credentials


const gameslistJSON = staticRead("gameslist.json")

connectMongoPool(mongoDbUrl, minConnections = 4, maxConnections = 12, loose=true)

routes:
  plugin db <- nextMongoConnection("/dberror")
  plugin cm <- cookieMsgs()
  plugin data <- jsonDefault()
  get "/":
    create_webVisit(db, request)
    data["gameslist"] = parseJson(gameslistJSON)["gameslist"]
    resp pageIndex(data)
  get "/game/@game_id":
    create_webVisit(db, request)
    data["gamedetail"] = parseJson(gameslistJSON)["gameslist"].getObject("id", @"game_id")
    if data["gamedetail"].isNull:
      cm.say("danger", "Unable to locate a game with ID $1".format(@"game_id"))
      redirect "/"
    else:
      try:
        data["core"] = readFile("./gamecores/$1/core.html".format(@"game_id"))
        data["onload"] = data.safeStr(@["gamedetail","body_onload"])
        resp pageGamePlay(data)
      except:
        echo getCurrentExceptionMsg()
        cm.say("danger", "Internal Error: unable to load game data.")
        redirect "/"
  get "/add-game":
    create_webVisit(db, request)
    resp pageAddGame(data)

