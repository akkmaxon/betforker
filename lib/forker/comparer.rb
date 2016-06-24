module Comparer

  def self.same_players?(first, second)
    first[:home_player][:name] == second[:home_player][:name] && first[:away_player][:name] == second[:away_player][:name]
  end

  def change_names hashik #!!!!!!!!LOOK AT THIS
    new_hashik = {
      bookie: hashik[:bookie],
      score: hashik[:score],
      home_player: hashik[:away_player],
      away_player: hashik[:home_player]
    }
  end

  def self.compare(first, second)
    forks = []
    return forks unless same_players? first, second

    # here is a header from message in output
    header = {
      bookies: "#{first[:bookie]} - #{second[:bookie]}",
      players: "#{first[:home_player][:name]}  VS  #{first[:away_player][:name]}",
    }
    header[:score] = first[:score].empty? ? second[:score] : first[:score]

    if $config[:filtering]
      break_now = is_a_break?(header[:score])
      filtering = true
    else
      break_now = true
      filtering = false
    end
    #match processing
    if first[:home_player].has_key?(:match) and second[:home_player].has_key?(:match) and break_now
      if first[:home_player][:match].class == Float and second[:home_player][:match].class == Float
        respond = match_win(first, second)
        unless respond.empty?
          forks << header.merge(respond)
        end
      end
    end
    #set processing
    if first[:home_player].has_key?(:set) and second[:home_player].has_key?(:set) and break_now
      respond = game_or_set_win(:set, first, second)
      unless respond.empty?
        respond.each do |set|
          forks << header.merge(set)
        end
      end
    end
    #game processing
    if first[:home_player].has_key?(:game) and second[:home_player].has_key?(:game)
      respond = game_or_set_win(:game, first, second)
      unless respond.empty?
        respond.each do |game|
          forks << header.merge(game)
        end
      end
    end
    forks = score_analyzer(forks, filtering)

    Output.comparer_log(first[:bookie], second[:bookie], forks, break_now)
    forks
  end

  def self.calculate_forks(x, y)
    return -3.5 if x == 0.0 or y == 0.0
    x_bet = 100.0
    sum_of_win = x * x_bet
    y_bet = sum_of_win / y
    sum_of_bet = x_bet + y_bet
    profit = sum_of_win - sum_of_bet
    percent = (profit / sum_of_bet) * 100
    percent = -3.5 if percent > 25
    percent
  end

  def self.match_win(first, second)
    respond = {}
    percent_straight = calculate_forks(first[:home_player][:match], second[:away_player][:match])
    percent_reverse = calculate_forks(first[:away_player][:match], second[:home_player][:match])
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
    first[:home_player][param].each do |first_key, first_val|
      second[:away_player][param].each do |second_key, second_val|
        if first_key == second_key
          percent_straight[first_key] = calculate_forks(first_val, second_val)
        end
      end
    end

    first[:away_player][param].each do |first_key, first_val|
      second[:home_player][param].each do |second_key, second_val|
        if first_key == second_key
          percent_reverse[first_key] = calculate_forks(first_val, second_val)
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
    return if forks.empty? or !filtering
    forks.each do |fork|
      next unless fork[:what].include?('game')
      g1, g2, s1, s2 = score_parser(fork[:score])
      game_in_fork = fork[:what].scan(/\d+/)[0].to_i
      not_a_time = game_in_fork > (s1 + s2 + 1) ? false : true
      if not_a_time
        Output.thrown_forks(fork)
        forks.delete(fork)
      end
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
