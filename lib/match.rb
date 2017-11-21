require_relative 'game.rb'
class Match
  def initialize
    @match_standing = {white: 0, black: 0, draw: 0}
  end

  def play
    ecsdee = 7
    while ecsdee > 0
      ecsdee -= 1
      return_value = Game.new.play
      if return_value == "draw"
        @match_standing[:draw] += 1
      else
        @match_standing[return_value] += 1
      end
    end
    print @match_standing
  end
end

if $0 == __FILE__
  Match.new.play
end
