module WilliamHill

  def self.parse(html, sport, type)
    case type
    when :live
      parse_live_page html, sport
    when :event
      parse_event html, sport
    else
      raise 'Not clever!'
    end
  end

  def self.parse_live_page(html, sport)
    nok = Nokogiri::HTML(html)
    links = Hash.new
    nok.css('#ip_sport_24_types .CentrePad a').each do |link|
      next unless link['href']
      href = link['href']
      players = link.text
      links[href] = concatenated_names players
    end
    links
  end

  def self.parse_event(html, sport)
    result = init_result
    nok = Nokogiri::HTML(html)
    nok.css('script').remove
    nok.css('#primaryCollectionContainer .marketHolderExpanded .tableData').each do |market|
      market.css('thead div').remove
      title = market.css('thead span').text
      next if title =~ /Total|Point|Deuce|Score/
      target_filler(market, title, 'home', result)
      target_filler(market, title, 'away', result)
    end
    result[:home_player][:name] ||= 'HomePlayer'
    result[:away_player][:name] ||= 'AwayPlayer'
    result
  end

  def self.init_result
    { bookie: 'WilliamHill',
      score: '0:0 (0:0)',
      home_player: {},
      away_player: {} }
  end

  def self.concatenated_names(string)
    w = []
    if string.include?(' v ')
      string.split(' v ').each do |pl|
        w += second_names_finder(pl)
      end
    else
      w += second_names_finder(string)
    end
    result = ""
    w.sort.each {|wh| result << wh}
    result
  end

  def self.second_names_finder(names)
    w = []
    names.gsub!('-', ' ')
    if names.include? '/'
      names.split('/').each {|n| w << n.scan(/\w+/)[-1]}
    elsif names.include?('Doubles')
      w << names.scan(/\w+/)[-2]
    else
      w << names.scan(/\w+/)[-1]
    end
    w
  end

  def self.target_filler(market, title, home_away, result)
    result = result
    case home_away
    when 'home'
      priceholder = '.eventpriceholder-left'
      pricecoeff = 'div.eventpriceup'
      player = :home_player
    when 'away'
      priceholder = '.eventpriceholder-right'
      pricecoeff = 'div.eventpricedown'
      player = :away_player
    end
    chunk = market.css("tbody #{priceholder}").each do |pl|
      name = pl.css('div.eventselection').text.strip
      coeff = pl.css('div.eventprice').text.strip.to_f
      coeff = pl.css(pricecoeff).text.strip.to_f if coeff == 0.0
      unless coeff == 0.0
        result[player][:name] ||= concatenated_names name
        if title.include? 'Match Betting'
          result[player][:match] = coeff
        elsif title.include? ' Set - Game '
          result[player][:game] ||= {}
          result[player][:game].merge!({title.scan(/\w+/)[-1] => coeff})
        elsif title.include? ' Set Betting Live'
          result[player][:set] ||= {}
          result[player][:set].merge!({title.scan(/\w+/)[0].to_i.to_s => coeff})
        end
      end
    end
    result
  end

end
