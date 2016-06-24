module Forker
  class Fork

    def initialize(bookmakers: '', players: '', score: '', what: '', percent: '')
      @bookmakers = bookmakers
      @players = players
      @score = score
      @what = what
      @percent = percent
    end

    def show
      <<-EOF
      #{@bookmakers}
      #{@players}
      Score: #{@score}
      On #{@what} percent: #{@percent}
      EOF
    end
  end
end
