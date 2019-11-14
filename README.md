# nimgame.online

https://nimgame.online/

a web site for hosting open-source javascript-based games written in the Nim programming language.

## Submitting A Game

Games are submitted via this repo by making changes to the [`website/gameslist.json`](https://github.com/JohnAD/nimgame.online/blob/master/website/gameslist.json)
file.

Simply fork this repo and send a PR.

While this repo does contain the source code to nimgame.online, you
should be generally avoiding changes to the remainder of the repo.

An entry in the **gameslist.json** object array should look like this:

``` json
    {
        "id": "game-of-knights",
        "version": "v1.0.0",
        "title": "Game Of Knights",
        "license": "MIT",
        "copyright_owner": "John Dupuy",
        "keys": ["js", "webterminal"],
        "picture_url": "https://github.com/JohnAD/webterminal/blob/master/knights_example/splash-card-image.png?raw=true",
        "repo_url": "https://github.com/JohnAD/webterminal/tree/master/knights_example",
        "description": "On a 5 x 5 chessboard, one knight faces another knight. Each turn, a knight can only jump to a place never before occupied. Last knight moving wins.",
        "js": [
            {
                "short": "tiny-pre-tty.js", 
                "url": "https://raw.githubusercontent.com/JohnAD/webterminal/master/knights_example/tiny_pre_tty.js"
            },
            {
                "short": "game-of-knights.js",
                "url": "https://raw.githubusercontent.com/JohnAD/webterminal/master/knights_example/game_of_knights.js"
            }
        ],
        "wget_html_url": "https://raw.githubusercontent.com/JohnAD/webterminal/master/knights_example/core.html",
        "body_onload": "initTerminal(30)"
    }
```

For further notes for this content, [go here](https://github.com/JohnAD/nimgame.online/blob/master/gameslist-json.md)

Once you have sent this repo the pull request (PR) with the change, I will:

* pull the files to cache
* test the results offline
* place the results online into the docker image hosted at Digital Ocean

Please allow me 3 days to do this. I do this as a volunteer effort, so my time is limited.

## What Kind of Games?

As a requirement, the following conditions must be met:

* must use client-side JavaScript to function
* must be open source and available on a linkable hosted repo
* must be written, at least in part, in Nim.

You can certainly also use other languages and frameworks (in addition to Nim.) For example, I would consider hosting an app written with the Godot framework or Unity framework; as long as it still meets the above conditions.

Technically, I can refuse any game if it is extremely offensive; but I'm actually pretty lax about that kind of thing.

If your game is written to run in a shell environment, I have written a library to help move it to Javascript: [webterminal](https://nimble.directory/pkg/webterminal)

## Contact

If you have any questions, feel free to leave a message on the repo.support forum.

[![repo.support](https://repo.support/img/rst-banner.png)](https://repo.support/gh/JohnAD/nimgame.online)

*(BTW, repo.support is also written in Nim.)*
