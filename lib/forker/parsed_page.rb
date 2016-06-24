module Forker
  class ParsedPage
    attr_accessor :home_player, :away_player
    attr_accessor :score
    attr_accessor :match, :set, :game

    def initialize()
      @home_player = ''
      @away_player = ''
      @score = ''
      @match = nil
      @set = nil
      @game = nil
    end

  end
end
