module Forker
  module Comparer

    UNREAL_PERCENT = 25
    FAKE_PERCENT = -3.5

    def self.compare(first, second)
      return [] if first.bookie == second.bookie
      forks = []
      check_sorting first, second
      return forks unless same_players? first, second

      filtering, break_now = if $config[:filtering]
			       [ true, is_a_break?(init_score(first, second)) ]
			     else
			       [ false, true ]
			     end

      forks << market_processing(:match, first, second, break_now)
      forks << market_processing(:set, first, second, break_now)
      forks << market_processing(:game, first, second)

      forks = score_analyzer forks.flatten, filtering

      forks.map do |f|
	Fork.new f
      end
    end

    def self.same_players?(first, second)
      first.home_player[:name] == second.home_player[:name] && 
	first.away_player[:name] == second.away_player[:name]
    end

    def self.change_names(object)
      object.home_player, object.away_player =
	object.away_player, object.home_player
    end
    
    def self.check_sorting(first, second)
      [first, second].each do |k|
	if k.home_player[:name] > k.away_player[:name]
	  change_names k
	end
      end
    end

    def self.init_score(first, second)
      if first.score.empty? then second.score else first.score end
    end

    def self.fork_template(first, second)
      {
	bookmakers: "#{first.bookie} - #{second.bookie}",
	players: "#{first.home_player[:name]}  VS  #{first.away_player[:name]}",
	score: init_score(first, second)
      }
    end

    def self.market_processing(market, first, second, break_now = true)
      result = []
      if first.home_player.key?(market) and second.home_player.key?(market) and break_now
	respond = case market
		  when :match then match_win first, second
		  when :set then game_or_set_win :set, first, second
		  when :game then game_or_set_win :game, first, second
		  end
	unless respond.empty? 
	  if respond.instance_of? Array
	    respond.each do |m|
	      result << fork_template(first, second).merge(m)
	    end
	  else
	    result << fork_template(first, second).merge(respond)
	  end
	end
      end
      result
    end

    def self.calculate(x, y)
      return FAKE_PERCENT if x == 0.0 or y == 0.0
      x_bet = 100.0
      sum_of_win = x * x_bet
      y_bet = sum_of_win / y
      sum_of_bet = x_bet + y_bet
      profit = sum_of_win - sum_of_bet
      percent = (profit / sum_of_bet) * 100
      percent = FAKE_PERCENT if percent >= UNREAL_PERCENT
      percent
    end

    def self.match_win(first, second)
      respond = {}
      percent_straight = calculate(first.home_player[:match], second.away_player[:match])
      percent_reverse = calculate(first.away_player[:match], second.home_player[:match])
      percent = percent_straight > percent_reverse ? percent_straight : percent_reverse
      if percent > $config[:min_percent]
	respond[:what] = 'match'
	respond[:percent] = percent.round(2).to_s
      end
      respond
    end

    def self.game_or_set_win(param, first, second)
      respond = []
      percent_straight = {}
      percent_reverse = {}
      first.home_player[param].each do |first_key, first_val|
	second.away_player[param].each do |second_key, second_val|
	  if first_key == second_key
	    percent_straight[first_key] = calculate(first_val, second_val)
	  end
	end
      end

      first.away_player[param].each do |first_key, first_val|
	second.home_player[param].each do |second_key, second_val|
	  if first_key == second_key
	    percent_reverse[first_key] = calculate(first_val, second_val)
	  end
	end
      end

      percent_straight.each do |key_str,val_str|
	percent_reverse.each do |key_rev,val_rev|
	  if key_str == key_rev
	    percent = val_str > val_rev ? val_str : val_rev
	    if percent > $config[:min_percent]
	      respond << { what: (param.to_s + key_str), percent: percent.round(2).to_s }
	    end
	  end
	end
      end
      respond
    end

    def self.is_a_break?(score)
      g1, g2, s1, s2 = score_parser(score)
      end_of_set = ((s1 + s2) == 12 and s1 != s2) || ((s1 == 6 and (s1 - s2) > 1) || (s2 == 6 and (s2 - s1) > 1))
      if (g1 + g2) == 0 and ((s1 + s2) == 0 or (s1 + s2).odd? or end_of_set)
	return true
      else
	return false
      end
    end

    def self.score_analyzer(forks, filtering)
      return forks if forks.empty? or not filtering
      forks.each do |f|
	next unless f[:what].include?('game')
	g1, g2, s1, s2 = score_parser(f[:score])
	game_in_fork = f[:what].scan(/\d+/)[0].to_i
	not_a_time = game_in_fork > (s1 + s2 + 1) ? false : true
	forks.delete(f) if not_a_time
      end
      forks
    end

    def self.score_parser(score)
      s = score.split(/\(|\)|,/)
      if s.size == 1 or score[0] == ' '
	games = '0:0'
	sets = s[0].strip
      else
	games = s[0].strip
	sets = s[-1].strip
      end
      g1, g2 = games.scan(/\d+/)
      s1, s2 = sets.scan(/\d+/)
      return g1.to_i, g2.to_i, s1.to_i, s2.to_i
    end

  end
end
