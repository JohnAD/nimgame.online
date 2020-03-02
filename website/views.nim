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
  credentials,
  sendgrid


const gameslistJSON = staticRead("gameslist.json")

connectMongoPool(mongoDbUrl, minConnections = 4, maxConnections = 12, loose=true)

routes:
  plugin db <- nextMongoConnection("/dberror")
  plugin cm <- cookieMsgs()
  plugin data <- jsonDefault()
  get "/":
    create_webVisit(db, request)
    data["msgs"] = cm.toJson()
    data["gameslist"] = parseJson(gameslistJSON)["gameslist"]
    resp pageIndex(data)
  get "/game/@game_id":
    create_webVisit(db, request)
    data["msgs"] = cm.toJson()
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
    data["msgs"] = cm.toJson()
    resp pageAddGame(data)
  post "/add-game":
    create_webVisit(db, request)
    let parms = data["request"]["params"]
    let repo_url = parms["repo_url"].getStr.strip()
    let example_url = parms["example_url"].getStr.strip()
    let email = parms["email"].getStr.strip()
    let notes = parms["notes"].getStr.strip()
    if repo_url == "":
      cm.say("danger", "An URL for the source code repo is required.")
      redirect "/add-game"
    let html = dedent """
      repo: $1 <br />
      example: $2 <br />
      email: $3 <br />
      notes:<br />
      <pre>$4</pre>
    """.format(repo_url, example_url, email, notes)
    let emailResult = sendOneEmail(ADMIN_EMAIL, "NGO Admin", "NGO game submission", html, 9403)
    echo("email result = ", emailResult)
    cm.say("success", "Your game submission was just sent to the nimgame.online admin.")
    redirect "/"
