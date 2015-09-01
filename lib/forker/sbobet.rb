class Sbobet < Bookmaker

  def initialize
    #with tennis works only!!
    @live_address = 'https://www.sbobet.com/euro/live-betting/tennis'
    @parsed_event = {
      bookie: 'Sbobet',
      score: '',
      home_player: Hash.new,
      away_player: Hash.new
    }
  end

  def live_page_parsed html_source
    nok = Nokogiri::HTML(html_source)
    links = Hash.new
    nok.css('tr').each do |event|
      href = "https://www.sbobet.com"
      event.css('.IconMarkets').map do |link|
        unless link['href'].include?(href)
          href += link['href']
        else
          href = link['href']
        end
      end
      h_p, a_p = event.css('.OddsL').map {|name| name.text }
      who = h_p + ' v ' + a_p
      links[href] = unified_names(who)
    end
    links
  end

  def event_parsed html_source
    nok = Nokogiri::HTML(html_source)
    @parsed_event[:home_player][:name] = unified_names(nok.css('.THomeName').text)
    @parsed_event[:away_player][:name] = unified_names(nok.css('.TAwayName').text)
    nok.css('#event-section .LiveMarket .Hdp tr').each do |what|
      #without scores and only bet on wins
      h_p_info = what.css('.OddsTabL')
      a_p_info = what.css('.OddsTabR')
      not_handicap = h_p_info.css('.OddsM').text.to_f == 0.0 && a_p_info.css('.OddsM').text.to_f == 0.0
      if not_handicap
        @parsed_event[:home_player][:match] = h_p_info.css('.OddsR').text.to_f
        @parsed_event[:away_player][:match] = a_p_info.css('.OddsR').text.to_f
      end
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
    if names.include? ',' #from betfair feature
      ss = names.split(/,/)
      w << ss[0].scan(/\w+/)[-1] #if singles play
      ss.each do |s|
        w << s.scan(/\w+/)[-1] if s.include? '/'
      end
    elsif names.include? '/'
      ss = names.split(/\//)
      ss.each do |s|
        w << s.scan(/\w+/)[-1]
      end
    else
      w << names.scan(/\w+/)[-1]
    end
    w
  end
end
