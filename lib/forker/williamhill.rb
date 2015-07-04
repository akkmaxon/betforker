require 'nokogiri'
class WilliamHill < Bookmaker

  def initialize
    @live_address = 'http://sports.williamhill.com/bet/en-gb/betlive/all'
    @parsed_event = {
      bookie: 'WilliamHill',
      score: '',
      home_player: Hash.new,
      away_player: Hash.new
    }
  end

  def live_page_parsed html_source
    nok = Nokogiri::HTML(html_source)
    links = Hash.new
    nok.css('#ip_sport_24_types .CentrePad a').each do |link|
      href = link['href']#.gsub('%2d', ' ')
      who = link.text
      links[href] = unified_names(who)
    end
    links
  end

  def event_parsed html_source
    nok = Nokogiri::HTML(html_source)
    nok.css('script').remove
    nok.css('#primaryCollectionContainer .marketHolderExpanded .tableData').each do |event|
      event.css('thead div').remove
      what = event.css('thead span').text
      next if what =~ /Total|Point|Deuce|Score/
      target_filler(event, what, 'home')
      target_filler(event, what, 'away')
    end
    @parsed_event[:home_player][:name] ||= 'HomePlayer'
    @parsed_event[:away_player][:name] ||= 'AwayPlayer'
    @parsed_event.clone
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
    else
      w << names.scan(/\w+/)[-1]
    end
    w
  end

  def target_filler event, what, h_or_a
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
    chunk = event.css("tbody #{priceholder}").each do |pl|
      name = pl.css('div.eventselection').text.strip
      coeff = pl.css('div.eventprice').text.strip.to_f
      coeff = pl.css(pricecoeff).text.strip.to_f if coeff == 0.0
      unless coeff == 0.0
        @parsed_event[player][:name] ||= unified_names(name)
        if what.include? 'Match Betting'
          @parsed_event[player][:match] = coeff
        elsif what.include? ' Set - Game '
          @parsed_event[player][:game] ||= Hash.new
          @parsed_event[player][:game].merge!({what.scan(/\w+/)[-1] => coeff})
        elsif what.include? ' Set Betting Live'
          @parsed_event[player][:set] ||= Hash.new
          @parsed_event[player][:set].merge!({what.scan(/\w+/)[0].to_i.to_s => coeff})
        end
      end
    end
  end

end
