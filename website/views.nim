import
  oids,
  macros,
  base64,
  times,
  re,
  strutils,
  system

import json except `[]`

import
  jester,
  nullable

import
  jsonextra,
  models,
  database,
  pages,
  misc,
  cookiehints,
  credentials

#
# local utils
#

template pageRedirect(url: string) =
  sendMessagesOnRedirect()
  redirect(url)

template pageResponse*(content: string, contentType = "text/html;charset=utf-8") =
  sendMessagesNow()
  resp content, contentType

template pageStart(body: untyped): untyped {.dirty.} =
  #
  # extra work to do up front
  #
  var data = newJObject()
  #
  # store cookies
  #
  data["cookies"] = newJObject()
  for k, v in request.cookies.pairs:
    data["cookies"][$k] = $v
  #
  # parse messages from previous pages
  #
  var newMessages = newJArray()  
  if data["cookies"].hasKey("messages"):
    let msgText = data["cookies"]["messages"].getStr()
    let jsonText = base64.decode(msgText)
    let j = parseJson(jsonText)
    data["messagesToDisplay"] = j
  else:
    data["messagesToDisplay"] = @[]
  #
  # handle parameters, if any
  #   we are combining both GET and POST parameters; keep that in mind
  #
  data["params"] = newJObject()
  for k, v in request.params.pairs:
    data["params"][$k] = $v
  #
  # base64-encoded URL of page (useful for passing as URL params)
  #
  data["encodedUrl"] = base64.encode(request.path)
  #
  create_webVisit(request)
  #
  body


const gameslistJSON = staticRead("gameslist.json")

routes:
  get "/":
    pageStart():
      data["gameslist"] = parseJson(gameslistJSON)["gameslist"]
      pageResponse pageIndex(data)
  get "/game/@game_id":
    pageStart():
      data["gamedetail"] = parseJson(gameslistJSON)["gameslist"].getObject("id", @"game_id")
      if data["gamedetail"].isNull:
        addDirectMessage(jdgDanger, "Unable to locate a game with ID $1".format(@"game_id"))
        pageRedirect("/")
      else:
        try:
          data["core"] = readFile("./gamecores/$1/core.html".format(@"game_id"))
          data["onload"] = data.safeStr(@["gamedetail","body_onload"])
          pageResponse pageGamePlay(data)
        except:
          echo getCurrentExceptionMsg()
          addDirectMessage(jdgDanger, "Internal Error: unable to load game data.")
          pageRedirect("/")

