module Betforker
  class Fork
    attr_reader :bookmakers, :players, :score, :what, :percent

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
      Market: #{@what}
      Percent: #{@percent}

      EOF
    end

    def desktop_show
      `notify-send -t #{$config[:time_of_notification] * 1000} "#{show}"`
      `paplay /usr/share/sounds/freedesktop/stereo/complete.oga` if $config[:sound_notification]
    end
  end
end
