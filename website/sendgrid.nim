import
  httpClient,
  strutils

import json except `[]`

import
  jsonextra,
  misc,
  credentials

const
  SENDGRID_BASE_URL = "https://api.sendgrid.com/v3"
  SENDGRID_SENDMAIL_URL = SENDGRID_BASE_URL & "/mail/send"

const
  FROM_EMAIL = "donotreply@nimgame.online"
  FROM_NAME = "NimGame.Online Admin"

# https://sendgrid.com/docs/api-reference/

# type
#   SendGridEmail = object
#     personalizations


proc sendOneEmail*(to_email, to_name, subject, html_message: string, group_id: int): string = 
  ## returns a tracking string unless an error
  ## If an error, returns "ERROR: error message"
  result = "ERROR: unknown."
  var client = newHttpClient()
  var tracker = generate_passcode(30)

  client.headers = newHttpHeaders({
   "Content-Type": "application/json",
   "Authorization": "Bearer " & SENDGRID_ACCESS_TOKEN
  })
  let body = %*{
    "personalizations": [
      {
        "to": [
          {
            "email": to_email,
            "name": to_name
          }
        ],
        "subject": subject,
        "headers": {
          "x-rs-email-tracker": tracker
        }
      }
    ],
    "from": {
      "email": FROM_EMAIL,
      "name": FROM_NAME
    },
    "content": [
      {
        "type": "text/html",
        "value": html_message
      }
    ],
    "asm": {
      "group_id": group_id
    }    
  }
  let response = client.request(SENDGRID_SENDMAIL_URL, httpMethod = HttpPost, body = $body)
  if response.code in @[Http200, Http201, Http202]:
    result = tracker
    echo "SENDGRID response.code = ", $response.code
  else:
    echo "SENDGRID response.body = ", $response.body
    var r = parseJson($response.body)
    result = "ERROR: $1".format($r.getOrDefault("errors"))


