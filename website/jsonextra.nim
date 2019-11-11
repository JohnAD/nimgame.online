import
  json,
  tables,
  oids,
  strutils

proc isNull*(obj: JsonNode): bool =
  return obj.kind == JNull

proc isTrue*(obj: JsonNode): bool =
  if obj.kind != JBool:
    result = false
  else:
    if obj.getBool == true:
      result = true
    else:
      result = false

proc isFalse*(obj: JsonNode): bool =
  if obj.kind != JBool:
    result = false
  else:
    if obj.getBool == true:
      result = false
    else:
      result = true

proc extend*(obj: var JsonNode, listToAdd: JsonNode) =
  if isNil(obj):
    return
  if obj.kind != JArray:
    return
  if isNil(listToAdd):
    return
  if listToAdd.kind != JArray:
    return
  for item in listToAdd.items:
    obj.add(item)

proc applyDefaults*(obj: JsonNode, defaults: JsonNode) =
  ## Applies defaults to Json document.
  ##
  ## For each of the fields in 'default', a corresponding field in 'obj'
  ## is searched. If the field is missing, the field in default is added
  ## to obj. If not missing, the field is left alone (even if the field is empty, such as
  ## an string of "")
  if obj.kind != JObject:
    return
  if defaults.kind != JObject:
    return
  for key, value in defaults.pairs:
    if not obj.hasKey(key):
      obj[key] = value

proc default*(obj: JsonNode, field: string, value: string) =
  ## Applies default to a Json object field
  ##
  ## If the field 'field' does not exist in 'obj', then it is added with
  ## the string value.
  if obj.kind != JObject:
    return
  if not obj.hasKey(field):
    obj[field] = newJString(value)


proc `%`*(o: Oid): JsonNode =
  ## Changes the marshalling of OIDs
  ##
  ## Without this more-specific version of `%`, an OID will marshal to JSON in
  ## the form of:
  ##
  ##   "id":{"time":-1709551779,"fuzz":1246555667,"count":1320578160}
  ##
  ## this proc converts that to:
  ##
  ##   "id":{"$oid":"5d4f1a9a13ee4c4a706cb64e"}
  ##
  ## which is more accurate and useful. It also meets MongoDB specifications:
  ##   https://docs.mongodb.com/manual/reference/mongodb-extended-json/#oid
  ##
  result = newJObject()
  result["$oid"] = newJString($o)

proc `[]=`*(obj: JsonNode; key: string; val: string) =
  obj[key] = newJString(val)

proc `[]=`*(obj: JsonNode; key: string; val: int) =
  obj[key] = newJInt(val)

proc `[]=`*(obj: JsonNode; key: string; val: float) =
  obj[key] = newJFloat(val)

proc `[]=`*(obj: JsonNode; key: string; val: bool) =
  obj[key] = newJBool(val)

proc `[]=`*(obj: JsonNode; key: string; val: Oid) =
  obj[key] = newJString($val)

proc `[]=`*[T](obj: JsonNode; key: string; val: seq[T]) =
  obj[key] = newJArray()


proc `[]`*(node: JsonNode, name: string): JsonNode {.inline.} =
  ## Gets a field from a `JObject`
  ## If the value at `name` does not exist or if the node is
  ## not an object, it returns null.
  if isNil(node):
    result = newJNull()
    return
  if node.kind != JObject:
    result = newJNull()
    return
  if node.fields.hasKey(name):
    result = node.fields[name]
  else:
    result = newJNull()

proc `[]`*(node: JsonNode, index: int): JsonNode {.inline.} =
  ## Gets the node at `index` in an Array.
  ## If index is out of bounds or node it not an array, it
  ## returns null
  if isNil(node):
    result = newJNull()
    return
  if node.kind != JArray:
    result = newJNull()
    return
  if index<0 or index>node.elems.high:  # TODO: make a unit test to check edges
    result = newJNull()
  else:
    result = node.elems[index]


proc objectToArray*(node: JsonNode, keyName="key", valueName="value"): JsonNode =
  ## Converts a JSON object, with it's key/value pairs and turns it into
  ## an array of objects, where each object has two items, "key": original key
  ## and "value": original value.
  ##
  ## for example:
  ##
  ##   {"a": "hello", "b": 3.14}.objectToArray
  ##
  ## would become:
  ##
  ##   [{"key": "a", "value": "hello"}, {"key": "b", "value": 3.14}]
  ##
  ## A different ``key`` key and ``value`` key can be specified in the parameters.
  result = newJArray()
  if node.kind != JObject:
    return
  for key, value in node.pairs:
    result.add %*{keyName: key, valueName: value}


#
#       ORIGINAL CODE FROM JSON
#
# proc `[]`*(node: JsonNode, name: string): JsonNode {.inline, deprecatedGet.} =
#   ## Gets a field from a `JObject`, which must not be nil.
#   ## If the value at `name` does not exist, raises KeyError.
#   ##
#   ## **Note:** The behaviour of this procedure changed in version 0.14.0. To
#   ## get a list of usages and to restore the old behaviour of this procedure,
#   ## compile with the ``-d:nimJsonGet`` flag.
#   assert(not isNil(node))
#   assert(node.kind == JObject)
#   when defined(nimJsonGet):
#     if not node.fields.hasKey(name): return nil
#   result = node.fields[name]

# proc `[]`*(node: JsonNode, index: int): JsonNode {.inline.} =
#   ## Gets the node at `index` in an Array. Result is undefined if `index`
#   ## is out of bounds, but as long as array bound checks are enabled it will
#   ## result in an exception.
#   assert(not isNil(node))
#   assert(node.kind == JArray)
#   return node.elems[index]


proc xmlstr_between(label: string, middle: string, tab: int, tight=false): string =
  let sp = " ".repeat(tab)
  result = ""
  if tight:
    result &= "\n$1<$2>$3</$2>".format(sp, label, middle)
  else:
    result &= "\n$1<$2>".format(sp, label)
    result &= "\n$1  $2".format(sp, middle)
    result &= "\n$1</$2>".format(sp, label)


proc jsonObjectToXML(node: JsonNode, hints: JsonNode, tab: int): string =
  # converts a JsonNode Object to XML
  var treeName = "object"
  var subHint = %*{}
  if hints.kind == Jobject:
    if "label" in hints:
      treeName = hints["label"].getStr
  var middle = ""
  for key, value in node.pairs:
    var part = ""
    var tight = false
    case value.kind:
    of JString:
      part = value.getStr
      tight = true
    # ####
    # for unknown reasons, the uncommenting the following generates "not GC-Safe" error messages
    # ####
    # of JArray:
    #   if hints.hasKey(key):
    #     subHint = hints[key]
    #   else:
    #     subHint = %*{}
    #   if not subHint.hasKey("label"):
    #     subHint["label"] = key
    #   part = jsonArrayToXML(value, subHint, tab+2)
    # of JObject:
    #   if hints.hasKey(key):
    #     subHint = hints[key]
    #   else:
    #     subHint = %*{}
    #   if not subHint.hasKey("label"):
    #     subHint["label"] = key
    #   part = jsonObjectToXML(value, subHint, tab+2)
    else:
      part = $value
      tight = true
    if tight:
      middle &= xmlstr_between(key, part, tab+2, tight=true)
    else:
      middle &= part
  middle = middle.strip
  result = xmlstr_between(treeName, middle, tab)


proc jsonArrayToXML(node: JsonNode, hints: JsonNode, tab: int): string =
  ## converts a JsonNode Array (list) to XML
  var treeName = "object"
  var key = "value"
  var subHint = %*{}
  if hints.kind == Jobject:
    if hints.hasKey("label"):
      treeName = hints["label"].getStr
    if hints.hasKey("array"):
      key = hints["array"].getStr
  var middle = ""
  for value in node:
    var part = ""
    var tight = false
    case value.kind:
    of JString:
      part = value.getStr
      tight = true
    of JArray:
      if hints.hasKey(key):
        subHint = hints[key]
      else:
        subHint = %*{}
      if not subHint.hasKey("label"):
        subHint["label"] = key
      part = jsonArrayToXML(value, subHint, tab+2)
    of JObject:
      if hints.hasKey(key):
        subHint = hints[key]
      else:
        subHint = %*{}
      if not subHint.hasKey("label"):
        subHint["label"] = key
      part = jsonObjectToXML(value, subHint, tab+2)
    else:
      part = $value
      tight = true
    if tight:
      middle &= xmlstr_between(key, part, tab+2, tight=true)
    else:
      middle &= part
  middle = middle.strip
  result = xmlstr_between(treeName, middle, tab)


proc jsonToXMLString*(node: JsonNode, hints: JsonNode): string =
  ## converts a JsonNode Object or Array to XML to a string
  if isNil(node):
    result = "ERR"
    return
  result = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
  case node.kind:
  # of JObject:
  #   result &= jsonObjectToXML(node, hints, 0)
  of JArray:
    result &= jsonArrayToXML(node, hints, 0)
  else:
    result &= "<err />"

# type
#   bling = object
#     x: int
#   tempobj = object
#     hello: string
#     world: int
#     joe: seq[string]
#     b: bling
#     spoon: seq[bling]

# var temp = tempobj()
# temp.hello = "a"
# temp.world = 3
# temp.joe = @["blah1", "blah2"]
# temp.b = bling(x: 5)
# temp.spoon = @[bling(x: 6), bling(x: 7)]

# var testJson = %*temp
# var nameHints = %*{"label": "test", "spoon": {"array": "bling"}}
# echo "JSON"
# echo $testJson
# echo "HINTS"
# echo $nameHints
# let final = jsonToXMLString(testJson, hints = nameHints)

# echo "REF"
# echo """
# <test>
#   <hello>a</hello>
#   <world>3</world>
#   <joe>
#     <value>blah1</value>
#     <value>blah2</value>
#   </joe>
#   <b><x>5</x></b>
#   <spoon>
#     <bling><x>6</x></bling>
#     <bling><x>7</x></bling>
#   </spoon>
# </test>
# """
# echo "FINAL"
# echo final