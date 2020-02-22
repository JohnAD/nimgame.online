import
  json,
  md5,
  random,
  times,
  # oids,
  unicode

import strutils except strip

import
  moustachu,
  markdown


const
  TOP_THREAD_COUNT* = 4
  PAGE_ONE_THREAD_COUNT* = 20
  TOP_ARTICLE_COUNT* = 4
  PAGE_ONE_ARTICLE_COUNT* = 20
  COIL_OID* = "5d813d280da9a3483c04da4f"
  SITEMAP_URL_LIMIT* = 500
  NULLTIME* = Time()

proc render*(tmplate: string, j: JsonNode, partialsDir="."): string =
  var context = newContext(j)
  result = render(tmplate, context, partialsDir)

proc generate_gravatar_url*(email: string, size=32, default="identicon"): string =
  let lower_email = email.strip().toLowerAscii()
  let hash = $toMD5(lower_email)
  result = "https://www.gravatar.com/avatar/$1?s=$2&r=pg".format(hash, size)
  if default!="":
    result &= "&d=" & default

randomize()


proc generate_passcode*(length: int): string =
  const GOODPASSCHARS = ["a","b","c","d","e","f","g","h","j","k","m","n","p","q",
                         "r","s","t","u","v","w","x","y","z","2","3","4","5","6",
                         "7","8","9","A","B","C","D","E","F","G","H","J","K","L",
                         "M","N","P","Q","R","S","T","U","V","W","X","Y","Z"]
  for _ in 1..length:
    result &= sample(GOODPASSCHARS)


proc age_abbr*(past: Time): string =
  let diff = getTime() - past
  let yr = diff.inDays() div 365
  if diff.inMinutes() == 0:
    if diff.inSeconds == 1:
      result = "$1 sec".format(diff.inSeconds)
    else:
      result = "$1 secs".format(diff.inSeconds)
  elif diff.inHours() == 0:
    if diff.inMinutes == 1:
      result = "$1 min".format(diff.inMinutes)
    else:
      result = "$1 mins".format(diff.inMinutes)
  elif diff.inDays() == 0:
    if diff.inHours == 1:
      result = "$1 hr".format(diff.inHours)
    else:
      result = "$1 hrs".format(diff.inHours)
  elif diff.inWeeks() == 0:
    if diff.inDays == 1:
      result = "$1 day".format(diff.inDays)
    else:
      result = "$1 days".format(diff.inDays)
  elif yr == 0:
    if diff.inWeeks == 1:
      result = "$1 wk".format(diff.inWeeks)
    else:
      result = "$1 wks".format(diff.inWeeks)
  else:
    if yr == 1:
      result = "$1 yr".format(yr)
    else:
      result = "$1 yrs".format(yr)


proc emailCleanup*(email: string): string =
  # returns "" if invalid.
  # otherwise returns a "cleaned up" email address.
  result = ""
  #
  # take off extra outside spaces
  #
  let raw1 = email.strip
  #
  # If in the form of "blah blah <user@domain.com>"
  # then take off everything before the "<".
  #
  let temp = raw1.split('<')
  let raw2 = temp[temp.high].strip
  #
  # take off any > (if any)
  #
  result = raw2.split('>')[0].strip
  #
  # at this point, we are done manipulating. the rest is verification
  #
  #
  # verify only one "@" symbol anywhere and then split it
  #
  if result.count('@') != 1:
    result = ""
    return
  let parts = result.split('@')
  let username = parts[0]
  let domain = parts[1]
  #
  # verify username part
  #
  if len(username) == 0:
    result = ""
    return
  #
  # verify domain part
  #
  if len(domain) < 4:
    result = ""
    return
  if domain.startsWith("."):
    result = ""
    return
  if domain.count('.') == 0:
    result = ""
    return
  #
  # otherwise, all is good!
  #

const OKAYPASSCHARS* = "abcdefghijklmnopqrstuvwxyz" &
                      "ABDDEFGHIJKLMNOPQRSTUVWXYZ" &
                      "0123456789" &
                      "!#$%&*+-/=?^_{|}~].,"

proc isBadPassword*(password: string): string = 
  result = ""
  if len(password) < 8:
    result = "must have at least 8 characters."
  for ch in password:
    if not OKAYPASSCHARS.contains(ch):
      result = "has characters that are not allowed."
      return

proc get*(s: seq[string], index: int, default=""): string =
  if index > s.high:
    result = default
  else:
    result = s[index]

const SHORT_MAX = 80
const SHORT_HIGH = SHORT_MAX - 1
const SHORT_CUT = SHORT_HIGH - 2

proc makeShortVersion*(s: string, firstLine = false): string =
  # set firstLine = true if you just want to parse the first line
  #
  # TODO: make unicode aware
  let lines = s.split("\n")
  if firstLine:
    result = lines[0].strip
    if result.runeLen > SHORT_MAX:
      result = runeSubStr(result, 0, SHORT_CUT).strip
      result &= " …"
  else:
    result = ""
    for line in lines:
      result &= " " & line
      result = result.strip
      if result.runeLen > SHORT_MAX:
        result = runeSubStr(result, 0, SHORT_HIGH).strip
        break


proc safeStr*(j: JsonNode, a: openArray[string]): string =
  # a perfectly safe way to move through a json tree.
  # if anything is wrong, an empty string is returned.
  result = ""
  try:
    let sz = a.len
    var ctr = 1
    var place = j
    for key in a:
      if ctr == sz: # this is the last item
        result = place[key].getStr
      else:
        place = place[key]
      ctr += 1
  except:
    discard


proc safeBool*(j: JsonNode, a: openArray[string]): bool =
  # a perfectly safe way to move through a json tree.
  # if anything is wrong, an empty string is returned.
  result = false
  try:
    let sz = a.len
    var ctr = 1
    var place = j
    for key in a:
      if ctr == sz: # this is the last item
        result = place[key].getBool
      else:
        place = place[key]
      ctr += 1
  except:
    discard


proc gmarkdown*(doc: string): string =
  result = markdown(doc, config=initGfmConfig())


# special thanks to:
#
# https://github.com/status-im/nim-json-serialization/blob/master/tests/utils.nim
#
# for this outstandingly useful procedure
#
proc dedent*(s: string): string =
  var s = s.strip(leading = false)
  var minIndent = 99999999999
  for l in s.splitLines:
    let indent = count(l, ' ')
    if indent == 0: continue
    if indent < minIndent: minIndent = indent
  result = s.unindent(minIndent)


when isMainModule:
  echo "emailCleanup testing..."
  assert emailCleanup("joe@r.co") == "joe@r.co"
  assert emailCleanup("  joe@r.co  ") == "joe@r.co"
  assert emailCleanup("billy_bob&2.3@a.b.c.domain.silly") == "billy_bob&2.3@a.b.c.domain.silly"
  assert emailCleanup(" blah blah @ blah > home <joe@r.co>") == "joe@r.co"
  assert emailCleanup("< joe@r.co >") == "joe@r.co"
  assert emailCleanup("<<<joe@r.co>>>") == "joe@r.co"

  assert emailCleanup("joer.co") == ""
  assert emailCleanup("joe@@r.co") == ""
  assert emailCleanup("@r.co") == ""
  assert emailCleanup("joe@") == ""
  assert emailCleanup("<joe@.domain.com>") == ""

  echo "safeStr testing..."
  var myj = newJObject()
  myj["first"] = newJString("boing")
  myj["aaa"] = newJObject()
  myj["aaa"]["second"] = newJString("blah")
  myj["aaa"]["nsec"] = newJInt(4)
  myj["aaa"]["bbb"] = newJObject()
  myj["aaa"]["bbb"]["ccc"] = newJString("bling")

  assert myj.safeStr(@["first"]) == "boing"
  assert myj.safeStr(["first"]) == "boing"
  assert myj.safeStr(["not_first"]) == ""
  assert myj.safeStr(["aaa"]) == ""
  assert myj.safeStr(["aaa", "second"]) == "blah"
  assert myj.safeStr(["aaa", "nsec"]) == ""
  assert myj.safeStr(["aaa", "notsecond"]) == ""
  assert myj.safeStr(["aaa", "bbb", "ccc"]) == "bling"
  assert myj.safeStr(["aaa", "bbb", "ccc", "ddd", "eee"]) == ""
  assert myj["aaa"].safeStr(["bbb", "ccc"]) == "bling"
  assert myj["first"].safeStr(["bbb", "ccc"]) == ""

