class WilliamHill < Bookmaker

  def initialize
   #@live_address = 'http://sports.williamhill.com/bet/en-gb/betlive/all'
    @live_address = 'http://sports.whbetting.com/bet/en-gb/betlive/all'
    @parsed_event = {
      bookie: 'WilliamHill',
      score: '0:0 (0:0)',
      home_player: Hash.new,
      away_player: Hash.new
    }
  end

  def live_page_parsed html_source
    nok = Nokogiri::HTML(html_source)
    links = Hash.new
    nok.css('#ip_sport_24_types .CentrePad a').each do |link|
      next unless link['href']
      href = link['href']
      who = link.text
      links[href] = unified_names(who)
    end
    links
  end

  def event_parsed html_source
    nok = Nokogiri::HTML(html_source)
    nok.css('script').remove
    nok.css('#primaryCollectionContainer .marketHolderExpanded .tableData').each do |market|
      market.css('thead div').remove
      title = market.css('thead span').text
      next if title =~ /Total|Point|Deuce|Score/
      target_filler(market, title, 'home')
      target_filler(market, title, 'away')
    end
    @parsed_event[:home_player][:name] ||= 'HomePlayer'
    @parsed_event[:away_player][:name] ||= 'AwayPlayer'
    @parsed_event
  end

  def unified_names who
    w = []
    if who.include?(' v ')
      who.split(' v ').each do |pl|
        w += second_names_finder(pl)
      end
    else
      w += second_names_finder(who)
    end
    who = ""
    w.sort.each {|wh| who << wh}
    who
  end

  def second_names_finder names
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

  def target_filler market, title, h_or_a
    case h_or_a
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
        @parsed_event[player][:name] ||= unified_names(name)
        if title.include? 'Match Betting'
          @parsed_event[player][:match] = coeff
        elsif title.include? ' Set - Game '
          @parsed_event[player][:game] ||= Hash.new
          @parsed_event[player][:game].merge!({title.scan(/\w+/)[-1] => coeff})
        elsif title.include? ' Set Betting Live'
          @parsed_event[player][:set] ||= Hash.new
          @parsed_event[player][:set].merge!({what.scan(/\w+/)[0].to_i.to_s => coeff})
        end
      end
    end
  end

end
