import json except `[]`
import times

import
  nullable

import
  jsonextra

#
#   FUNCTION FOR STORING MESSAGES IN COOKIE STRINGS
#

proc hint_to_json*(hint: Hint): JsonNode =
  result = newJObject()
  #
  result["m"] = hint.msg
  #
  case hint.judgement:
  of jdgSuccess:
    result["j"] = "s"
  of jdgWarning:
    result["j"] = "w"
  of jdgDanger:
    result["j"] = "d"
  of jdgInfo:
    result["j"] = "i"
  #
  case hint.level:
  of lvlAll:
    result["l"] = "a"
  of lvlInfo:
    result["l"] = "i"
  of lvlNotice:
    result["l"] = "n"
  of lvlWarn:
    result["l"] = "w"
  of lvlError:
    result["l"] = "e"
  of lvlFatal:
    result["l"] = "f"
  of lvlNone:
    result["l"] = "-"
  of lvlDebug:
    result["l"] = "d"
  #
  case hint.audience:
  of audOps:
    result["a"] = "o"
  of audAdmin:
    result["a"] = "a"
  of audUser:
    result["a"] = "u"
  of audPublic:
    result["a"] = "p"

proc addTemplateHintNotes*(hints: var JsonNode) =
  for hint in hints.mitems:
    case hint["j"].getStr():
    of "s":
      hint["_j"] = "success"
      hint["_jicon"] = "&#x2713;"   # checkmark
    of "w":
      hint["_j"] = "warning"
      hint["_jicon"] = "&#x26a0;"   # exclamation triangle
    of "d":
      hint["_j"] = "danger"
      hint["_jicon"] = "&#x274c;"   # cross mark
    of "i":
      hint["_j"] = "info"
      hint["_jicon"] = "&#x2139;"   # 'i' symbol

proc add_errors*[T](hintList: var JsonNode, obj: N[T]) =
  for error in obj.errors:
    if error.level in [lvlDebug, lvlNone]:
      continue
    if error.audience in [audOps, audAdmin]:
      continue
    var hint = Hint(
      msg: error.msg,
      judgement: jdgDanger,
      level: lvlAll,
      audience: audUser
    )
    hintList.add(hint_to_json(hint))

proc add_hints*[T](hintList: var JsonNode, obj: N[T]) =
  for hint in obj.hints:
    hintList.add(hint_to_json(hint))

proc add_one_hint*(hintList: var JsonNode, j: Judgement, msg: string) =
  var hint = newJObject()
  hint["m"] = msg
  case j:
  of jdgSuccess:
    hint["j"] = "s"
  of jdgWarning:
    hint["j"] = "w"
  of jdgDanger:
    hint["j"] = "d"
  of jdgInfo:
    hint["j"] = "i"
  hint["l"] = "w"
  hint["a"] = "u"
  hintList.add hint

template addErrorMessages*[T](obj: N[T]): untyped {.dirty.} =
  case obj.kind:
  of nlkError:
    if len(obj.errors) > 0:
      add_errors(newMessages, obj)
  else:
    discard

template addHintMessages*[T](obj: N[T]): untyped {.dirty.} = 
  if len(obj.hints) > 0:
    add_hints(newMessages, obj)

template addDirectMessage*(j, msg: untyped) =
  add_one_hint(newMessages, j, msg)

template sendMessagesOnRedirect*(): untyped {.dirty.} =
  newMessages.extend(data["messagesToDisplay"])
  var jsonText = ""
  toUgly(jsonText, newMessages)
  # echo jsonText
  jsonText = encode(jsonText)
  # echo jsonText
  setCookie("messages", jsonText, daysForward(1), path="/")

template sendMessagesNow*(): untyped {.dirty.} =
  newMessages.extend(data["messagesToDisplay"])
  if len(newMessages) > 0:
    data["msgBoxes"] = true
    addTemplateHintNotes(newMessages)
    data["_msgBoxes"] = newMessages
    # echo newMessages.pretty
  setCookie("messages", "", parse("1970-01-01", "yyyy-MM-dd"), path="/")
