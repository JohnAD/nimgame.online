import turn_based_game
import negamax
import webterminal
import strutils

import nim

let instructions = [
  "Players take turns removing any number of discs from just one of ",
  "three heaps.",
  " ",
  "The goal is to force the other player to be the last person ",
  "to remove a disc.",
  " ",
  "In this version, the heaps start with 6, 7, and 8 discs respectively.",
  " ",
  "You are playing against a negamax AI running in your browser. The algorithm ",
  "is set to look only 9 moves (plies) ahead, so with early wise moves, it is ",
  "possible to win."
]

type
  game_states = enum
    init, waiting_on_user, playing_ai, game_over

var
  game = ActualNim()
  current_state: game_states

proc handle_end(game: ActualNim) = 
  webterminal.send(" ")
  webterminal.send("-----------------")
  webterminal.send("GAME OVER")
  webterminal.send(game.status())
  webterminal.send(" ")
  if game.winner_player_number == 1:
    webterminal.send("YOU WON! The AI is left making a move.")
  else:
    webterminal.send("The AI won. You have no choice but to take the last disc.")
  webterminal.send("\nRefresh the browser page to play again.")
  current_state = game_over

proc show_turn_start(game: ActualNim) = 
  var moves_possible: seq[string]
  game.set_possible_moves(moves_possible)
  webterminal.send(" ")
  webterminal.send("-----------------")
  if game.current_player_number == 1:
    webterminal.send("Your turn")
  else:
    webterminal.send("AI's turn")
  webterminal.send(" ")
  webterminal.send(game.status())
  if game.current_player_number == 1:
    let move_display = moves_possible.join(", ")
    webterminal.send("Possible moves: " & move_display)
    webterminal.send(" ")
    webterminal.send("Send move:")
  else:
    webterminal.send("Thinking...")

proc on_load() =
  game.setup(@[
    Player(name: "User"),
    NegamaxPlayer(name: "NegamaxAI", depth: 9)
  ])
  current_state = waiting_on_user
  webterminal.send("The Ancient Game of Nim")
  webterminal.send(" ")
  for line in instructions:
    webterminal.send(line)
  game.show_turn_start()

webterminal.establish_terminal_on_start_function(on_load)

proc on_input(cmsg: cstring) = 
  var moves_possible: seq[string]
  var move: string
  let msg_str = $cmsg
  let msg = msg_str.toUpperAscii()
  case current_state:
  of waiting_on_user:
    game.set_possible_moves(moves_possible)
    if msg in moves_possible:
      webterminal.send(">>" & game.make_move(msg))
      game.determine_winner()
      if game.is_over():
        handle_end(game)
        current_state = game_over
      else:
        current_state = playing_ai
        game.current_player_number = game.next_player_number()
        show_turn_start(game)
        move = game.current_player.get_move(game)
        webterminal.send(">>" & game.make_move(move))
        game.determine_winner()
        if game.is_over():
          handle_end(game)
          current_state = game_over
        else:
          game.current_player_number = game.next_player_number()
          show_turn_start(game)
          current_state = waiting_on_user
    else:
      webterminal.send("\"" & msg & "\" is not a recognized move. Try again.")
  else:
    current_state = game_over
    webterminal.send("Internal error, reached an impossible state.")

webterminal.establish_terminal_on_input_function(on_input)
