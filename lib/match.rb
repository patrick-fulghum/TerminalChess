require_relative 'game.rb'
require_relative 'knight_travails.rb'

class Match
  def initialize
    @match_standing = {white: 0, black: 0, draw: 0}
  end

  def play
      puts ("Press N to do Knights Traverse Problem or anything else to play chess.")
      kappachinos = gets.chomp
      if kappachinos == "N"
        KnightTravails.new.play
      else
        Game.new.play
      end
  end
end

if $0 == __FILE__
  Match.new.play
end
