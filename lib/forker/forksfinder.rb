module Forksfinder

  def forking parsed_hash, comparer
    forks = Array.new
    while parsed_hash.size > 1
      first_bookie = parsed_hash.shift
      parsed_hash.each do |second_bookie|
        forks_found = comparer.compare(first_bookie.clone, second_bookie.clone) || Array.new
        forks_found.each {|fork| forks << fork} unless forks_found.empty?
      end
    end
  end

  def change_names hashik
    new_hashik = {
      bookie: hashik[:bookie],
      score: hashik[:score],
      home_player: hashik[:away_player],
      away_player: hashik[:home_player]
    }
  end

  def init_bookmaker address
    bookie = ""
    $config[:bookies].each {|b| bookie = b if address.include?(b.downcase)}
    #####if whbetting.com 
    bookie = "WilliamHill" if bookie.empty?
    who = eval("#{bookie}.new")
  end

end
