import
  # oids,
  times,
  tables

#####################################
#
# WEB TRACKING
#
#####################################

type
  WebVisit* = object
    # id* {.dbCol: "_id".}: Oid
    url*: string
    user_agent*: string
    args*: string
    status_code*: int
    remote_addr*: string
    x_forwarded_for*: string
    date*: Time


type
  WebDay* = object
    # id* {.dbCol: "_id".}: Oid
    date*: Time
    url*: string
    count*: int

type
  WebMonth* = object
    # id* {.dbCol: "_id".}: Oid
    date*: Time
    url*: string
    count*: int
