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
    <h1>Add Your Game</h1>
    <p>
      If your game
      <ol>
        <li>is written in <a href="https://nim-lang.org/">Nim</a> (at least partly),</li>
        <li>compiles to JavaScript, and</li>
        <li>is open source,</li>
      </ol>
      then I will happily consider adding your game to this website.
    </p>

    <div class="card">
      <div class="card-header">
        Send Suggested Game Details
      </div>
      <div class="card-body">
        <form action="" method="POST">
          <div class="form-group">
            <label for="repo_url">URL of public source code repo</label>
            <input type="text" class="form-control" id="repo_url" name="repo_url" aria-describedby="repo_urlHelp" placeholder="Enter the web address of the repo">
            <small id="repo_urlHelp" class="form-text text-muted">I need this address to even get started.</small>
          </div>
          <div class="form-group">
            <label for="example_url">URL of playable page (optional)</label>
            <input type="text" class="form-control" id="example_url" name="example_url" aria-describedby="repo_urlHelp" placeholder="Enter the web address of the game">
            <small id="example_urlHelp" class="form-text text-muted">Having a working example makes importing the game easier.</small>
          </div>
          <div class="form-group">
            <label for="email">Email address (optional)</label>
            <input type="email" class="form-control" id="email" name="email" aria-describedby="emailHelp" placeholder="email address">
            <small id="emailHelp" class="form-text text-muted">Sending me your email let's me ask questions in case I have problems.</small>
          </div>
          <div class="form-group">
            <label for="notes">Useful notes</label>
            <textarea class="form-control" id="notes" name="notes" rows="10" aria-describedby="notesHelp"></textarea>
            <small id="notesHelp" class="form-text text-muted">Each project is different. Add extra detail here.</small>
          </div>      
          <button type="submit" class="btn btn-primary">Submit</button>
        </form>
      </div>
    </div>
  """, data)
  data["core"] = core
  result = render(PageTemplate, data)
