class Betfair < Bookmaker

  def initialize
    @live_address = 'https://www.betfair.com/sport/inplay'
    @parsed_event = {
      bookie: 'Betfair',
      score: '',
      home_player: Hash.new,
      away_player: Hash.new
    }
  end

  def live_page_parsed html_source
    nok = Nokogiri::HTML(html_source)
    links = Hash.new
    nok.css('.sport-2 .section .details-event').each do |chunk|
      href = ""
      chunk.css('a').map {|link| href = link['href']}
      domain = 'https://www.betfair.com'
      href = domain + href unless href.include?(domain)
      who_home = chunk.css('.home-team-name').text.strip
      who_away = chunk.css('.away-team-name').text.strip
      links[href] = unified_names("#{who_home} v #{who_away}")
    end
    links
  end

  def event_parsed html_source
    nok = Nokogiri::HTML(html_source)
    nok.css('script').remove
    home_set = nok.css('.runners-table .home-header .active-set').text.strip
    away_set = nok.css('.runners-table .away-header .active-set').text.strip
    home_game = nok.css('.runners-table .ui-score-home').text.strip
    away_game = nok.css('.runners-table .ui-score-away').text.strip
    @parsed_event[:score] = "#{home_game}:#{away_game} (#{home_set}:#{away_set})"
    nok.css('.list-minimarkets .mod-minimarketview').each do |event|
      what = event.css('.minimarketview-header span.title').text
      next if what =~ /Point|Handicap|Set Betting|Games|A Set/
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
    if names.include? ',' #remove names for beginning
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

  def target_filler event, what, h_or_a
    case h_or_a
    when 'home'
      num = 0
      player = :home_player
    when 'away'
      num = 1
      player = :away_player
    end
    name = event.css('.minimarketview-content .runner-item .runner-name')[num]
    name = name.text if name
    @parsed_event[player][:name] ||= unified_names(name)
    coeff = event.css('.minimarketview-content .runner-item span.ui-runner-price')[num]
    if coeff
      coeff = coeff.text.strip.to_f
      return if coeff == 0.0
      if what.include? 'Match Odds'
        @parsed_event[player][:match] = coeff
      elsif what.include? 'Game '
        @parsed_event[player][:game] ||= Hash.new
        @parsed_event[player][:game].merge!({what.scan(/\w+/)[-2] => coeff})
      elsif what.include? 'Set' and what.include? 'Winner'
        @parsed_event[player][:set] ||= Hash.new
        @parsed_event[player][:set].merge!({what.scan(/\w+/)[-2].to_i.to_s => coeff})
      end
    end
  end

end
