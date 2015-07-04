=begin
forks_hash = {
bookies: 'wh' - 'betfair',      String
players: 'First' - 'Second',    String
score: '0:0',                  String
what: 'game 4',                 String
percent: '2.2'                  String
 }
=end

class Comparer

  def initialize
    @forks_found = Array.new
  end

  def compare first, second
    @forks_found = [] unless @forks_found.empty?
    unless first[:home_player][:name] == second[:home_player][:name] && first[:away_player][:name] == second[:away_player][:name]
      return @forks_found
    end

    header = {
      bookies: "#{first[:bookie]} - #{second[:bookie]}",
      players: "#{first[:home_player][:name]}  VS  #{first[:away_player][:name]}",
    }
    unless first[:score].empty?
      header[:score] = first[:score]
    else
      header[:score] = second[:score]
    end
    #match processing
    if first[:home_player].has_key?(:match) and second[:home_player].has_key?(:match)
      if first[:home_player][:match].class == Float and second[:home_player][:match].class == Float
        respond = match_win(first, second)
        unless respond.empty?
          @forks_found << header.merge(respond)
        end
      end
    end
    #game processing
    if first[:home_player].has_key?(:game) and second[:home_player].has_key?(:game)
      respond = game_or_set_win(:game, first, second)
      unless respond.empty?
        respond.each do |game|
          @forks_found << header.merge(game)
        end
      end
    end
    #set processing
    if first[:home_player].has_key?(:set) and second[:home_player].has_key?(:set)
      respond = game_or_set_win(:set, first, second)
      unless respond.empty?
        respond.each do |set|
          @forks_found << header.merge(set)
        end
      end
    end
    @forks_found
  end

  private

  def calculate_forks x, y
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

  def match_win first, second
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

  def game_or_set_win param, first, second
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

end
