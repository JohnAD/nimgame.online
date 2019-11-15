#
# NIM
#
# Description: Players take turns removing any number of discs from just one of
# three heaps.
#
# In traditional play, the goal is to force the other player to be the last person
# to remove a disc.
#
# For this version, the discs have 6, 7, and 8 disks at the start.
#

import strutils
import turn_based_game

#
# 1. define our game object
#

const
  HEAP_COUNT = 3
  FIRST_STACK_SIZE = 6
  HEAP_LETTER: array[HEAP_COUNT, string] = ["A", "B", "C"]

type
  ActualNim* = ref object of Game
    heaps*: array[HEAP_COUNT, int]


proc letter_to_number(move: string): int =
  if len(move) != 2:
    raise newException(ValueError, "move $1 not valid".format(move))
  if move[0] == 'A':
    result = 0
  elif move[0] == 'B':
    result = 1
  elif move[0] == 'C':
    result = 2
  else:
    raise newException(ValueError, "move $1 not valid".format(move))

#
#  2. add our rules (methods)
#

########################################################################
#
# STANDARD METHODS EXPECTED OF ALL `turn_based_game`
#
########################################################################

method setup*(self: ActualNim, players: seq[Player]) =
  self.default_setup(players)
  for n in 0 ..< HEAP_COUNT:
    self.heaps[n] = FIRST_STACK_SIZE + n


method set_possible_moves*(self: ActualNim, moves: var seq[string]) =
  moves = @[]
  for n in 0 ..< HEAP_COUNT:
    if self.heaps[n] > 0:
      for qty in 1 .. self.heaps[n]:
        moves.add("$1$2".format(HEAP_LETTER[n], qty))


method make_move*(self: ActualNim, move: string): string =
  let heapNumber = letter_to_number(move)
  let qty = parseInt($move[1])
  self.heaps[heapNumber] -= qty
  return "Removed $1 discs from heap $2 leaving $3.".format(qty, HEAP_LETTER[heapNumber], self.heaps[heapNumber])


# the following method is not _required_, but makes it nicer to read
method status*(self: ActualNim): string =
  result = "\nHeaps:\n\n"
  for n in 0 ..< HEAP_COUNT:
    result &= HEAP_LETTER[n] & " -> " & $self.heaps[n] & " "
    result &= '|'.repeat(self.heaps[n])
    result &= "\n"


# the `determine_winner` method was moved after `scoring` because it is called by `determine_winner`

########################################################################
#
# ADDITIONAL METHODS EXPECTED OF NEGAMAX AI
#
########################################################################

method scoring*(self: ActualNim): float =
  var total = 0
  for n in 0 ..< HEAP_COUNT:
    total += self.heaps[n]
  if total == 1:
    return -1000.0
  if total == 0:  # this is a rare border case where the previous player voluntarily removed the remaining discs
    return 1000.0
  #
  # otherwise, we will "play safe" be preferring moves that leave more discs
  return float(total) * 2.0


method determine_winner*(self: ActualNim) =
  if self.winner_player_number > 0:
    return
  let score = 0.0 - self.scoring()  # this value is reversed because `determine_winner` is called AFTER the move is made
  if score == 1000.0:
    self.winner_player_number = self.current_player_number
  if score == -1000.0:
    self.winner_player_number = self.next_player_number()
  # else, no winner yet


method get_state*(self: ActualNim): string =
  # note: we only support single-digit counts
  if self.current_player_number == 1:
    result = "1"
  else:
    result = "2"
  for n in 0 ..< HEAP_COUNT:
    result &= $self.heaps[n]


method restore_state*(self: ActualNim, state: string): void =
  # note: we only support single-digit counts
  if state.startsWith("1"):
    self.current_player_number = 1
  else:
    self.current_player_number = 2
  for n in 0 ..< HEAP_COUNT:
    self.heaps[n] = parseInt($state[1+n])


# var game = ActualNim()

# game.setup(@[Player(name: "A"), Player(name: "B")])

# game.play()