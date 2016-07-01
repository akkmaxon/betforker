module Betforker
  class ParsedPage
    attr_accessor :bookie, :home_player, :away_player, :score

    def initialize(bookie: '')
      @bookie = bookie
      @home_player = {}
      @away_player = {}
      @score = ''
    end

  end
end
