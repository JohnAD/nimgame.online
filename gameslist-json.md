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

Notes regarding this content:

### "id"

A sequence of lowercase letters, numbers, and dashes. No spaces or punctuation other than dash. Used for internal reference. Once you
post your game, please don't change the id later.

### "version"

Typical semvar style version string.

### "title"

A title for Humans to read.

### "license"

The open source license. Not used right now; mostly for documentation.

### "copyright_owner"

Your name or company; mostly used for documentation.

### "keys"

Free-form keywords. Simply displayed in the card representing the game.

If you are using a framework, please include that.

### "picture_url"

This is where my script will grab the picture for the display card. It should represent the game. Ideally, it is 320x240 pixels. My
script will manipulate it and cache it on the main site.

### "repo_url"

This is where the user will go when they want to view the source code of your game.

### "description"

A human readable description of the game. Try to limit your self to under 200 characters.

### "js"

A list of javascript files for my script to pull and cache on the main site. They will be loaded in the HTML header in the order provided.

### "wget_html_url"

This is where the "core" of your web page should be pulled from. See X for detail.

This website uses Bootstrap 4 fonts/css/javascript. Feel free to decorate using Bootstraps CSS.

### "body_onload": "initTerminal(30)"

This is the procedure to run once the website has loaded.
