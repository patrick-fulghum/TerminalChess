## CHESS
###### Written in Ruby 2.4.2

![Alt Text](https://media.giphy.com/media/l4EoZkoVBFoEzJRkc/giphy.gif)
#### Table of Contents

* Features and Techniques
* Usage
* Complex Rule Implementation Details
* Issues

## Features and Techniques

This repository includes the source code for a terminal based chess game. The code uses the following techniques:

* Overloading operator

* MetaProgramming

* Module Mixins

* Class Inheritance

The game has robust error handling, so when a user makes an invalid input, an appropriate error message is flashed and the user is allowed to repeat their input.

# Complex Rule Implementation Details

* Fifty Move Rule is done by seeing if a capture was initiated on the last move and either resetting the counter or incrementing the counter

* Castling is determined to be a legal move in the class King and the board move method is what is responsible for moving the rook and king.

* En Passant is handled by assigning an instance variable pass to either true of false of a pawn. Again the move function has the responsibility of removing the passed pawn and capturing pawn.

* Stalemate uses the same method as checkmate,and simply passes in the opposite color.

```ruby
def checkmate?(color)
  return false unless in_check?(color)
  my_pieces = pieces.select{ |piece| piece.color == color }
  my_pieces.all?{ |piece| piece.reject_moves_into_check.length == 0 }
end
```

* Queen promotion is done automatically upon a pawn reaching the final rank, and is done by checking the first and last rank for pawn presence and converting any discovered pieces into Queens immediately.

```ruby
def ensure_promotion
  (board.grid.first + board.grid.last).each_with_index do |piece, file|
    if piece.class == Pawn
      position = file < 8 ? [0, file] : [7, file % 8]
      board[position] = Queen.new(board, position, piece.color, true)
    end
  end
end
```

## Usage

To play chess with yourself in your terminal, follow these steps:

1. Clone this repository
2. Navigate to the repository in your terminal
3. Run the following in your terminal if you don't have the colorize gem installed:
bundle install
4. Run the following in your terminal:
ruby game.rb
5. Use the left, right, up and down keys to move the cursor.
Use enter to select a piece, and enter again to select its destination. Errors will flash if you choose a piece that is not your own, try to move a piece in an illegal way, or fail to move out of check.
