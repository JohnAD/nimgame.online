import
  # strutils,
  # oids,
  times

import json except `[]`

import
  jsonextra,
  misc,
  templates


# #####################################
#
# INDEX PAGE
#
# #####################################

proc pageIndex*(data: var JsonNode): string =
  let core = render(dedent """
    <div class="jumbotron">
      <h1 class="display-4">Play Games, Learn Nim.</h1>
      <p class="lead">A collection of online games written in the programming language Nim</p>
      <hr class="my-4">
      <p>You can play the games. Then, visit the public repo where the open-source code is stored and examine how the game works.</p>
    </div>

    <div class="card-columns">
      {{#gameslist}}
      <div class="card">
        <img src="/img/{{id}}/splash.png" class="card-img-top" alt="pic for {{id}}">
        <div class="card-body">
          <h5 class="card-title">{{title}}</h5>
          <p class="card-text">
            {{description}}
          </p>
          <p class="card-text text-center">
            <a href="/game/{{id}}" class="btn btn-primary">Play</a>
            <a href="{{repo_url}}" class="btn btn-success">Code</a>
          </p>
        </div>
        <div class="card-footer text-muted">
          {{#keys}}
          {{.}}
          {{/keys}}
        </div>
      </div>
      {{/gameslist}}
    </div>
  """, data)
  data["core"] = core
  result = render(PageTemplate, data)


# #####################################
#
# GAME PAGE
#
# #####################################

proc pageGamePlay*(data: var JsonNode): string =
  result = render(PageTemplate, data)


proc pageAddGame*(data: var JsonNode): string =
  let core = render(dedent """
    <h1>Adding Your Game</h1>
    <p>
      If your game meets the following criteria:
    </p>
    <ol>
      <li>It uses client-side JavaScript to function.</li>
      <li>It is open source and available on a linkable hosted repo.</li>
      <li>It is written, at least in part, in <a href="https://nim-lang.org/">Nim</a>.</li>
    </ol>
    <p>
      Then I will happily consider adding your game to this website.
    </p>
    <p>
      Please visit the website's repo at <a href="https://github.com/JohnAD/nimgame.online">github.com/JohnAD/nimgame.online</a> for details.
    </p>
  """, data)
  data["core"] = core
  result = render(PageTemplate, data)
