## CHESS
###### Written in Ruby 2.4.2

![Alt Text](https://media.giphy.com/media/l4EoZkoVBFoEzJRkc/giphy.gif)
#### Table of Contents

* Features and Techniques
* Usage
* Issues

## Features and Techniques

This repository includes the source code for a terminal based chess game. The code uses the following techniques:

* Overloading operator

* Module Mixins

* Class Inheritance

The game has robust error handling, so when a user makes an invalid input, an appropriate error message is flashed and the user is allowed to repeat their input.

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

## Issues.

* There is no computer AI yet implemented.

* You cannot choose what piece to promote to; any pawn that makes it to the end of the board is automatically promoted to a Queen.

* Fifty Move Rule, 3 move repetition and the capacity to offer a draw to
your opponent

* Does not highlight the available squares for a piece when selected
