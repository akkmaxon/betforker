module Forker
  class ParsedPage
    attr_accessor :home_player, :away_player, :score

    def initialize()
      @home_player = {}
      @away_player = {}
      @score = ''
    end

  end
end
