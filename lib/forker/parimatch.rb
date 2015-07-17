class Parimatch < Bookmaker

  def initialize
    @live_address = 'http://www.parimatch.com/en/live.html'
    @parsed_event = {
      bookie: 'Parimatch',
      score: '',
      home_player: Hash.new,
      away_player: Hash.new
    }
  end

  def live_page_parsed html_source
    nok = Nokogiri::HTML(html_source)
    links = Hash.new
    nok.css('#liveContentHolder0 #tennisItem tbody .td_n a').each do |link|
      next unless link['href']
      link.css('span').remove
      href = link['href']
      domain = 'http://www.parimatch.com/en/'
      href = domain + href unless href.include?(domain)
      who = link.text
      links[href] = unified_names(who)
    end
    links
  end

  def event_parsed html_source
    nok = Nokogiri::HTML(html_source)
    score = nok.css('.l .l').text.split(/\(|\)|,/)
    if not score.empty? and score[-1].include? ':'
      games = score.pop.strip
      sets = score.pop
    elsif score.empty?
      games = ""
      sets = ""
    else
      games = '0:0'
      sets = score.pop
    end
    home_set, away_set = sets.scan(/\d+/)
    home_game, away_game = games.split(':')
    @parsed_event[:score] = "#{home_game}:#{away_game} (#{home_set}:#{away_set})"
    names_chunk = nok.css('.l')
    names_chunk.css('img').remove
    names_chunk.css('span').remove
    h_pl, a_pl = names_chunk.inner_html.split('<br>')
    h_pl = Nokogiri::HTML(h_pl).text if h_pl.include? '<small>'
    a_pl = Nokogiri::HTML(a_pl).text if a_pl.include? '<small>'
    h_pl.strip!
    a_pl.strip!
    unless h_pl.empty? or a_pl.empty?
      @parsed_event[:home_player][:name] = unified_names(h_pl)
      @parsed_event[:away_player][:name] = unified_names(a_pl)
    end
    nok.css('.gray tr').each do |line|
      games_line = line.css('.dyn')
      if games_line.empty?
        next
        #wins & sets processing
      else
        next if games_line.text =~ /point|score|who/i
        num = games_line.css('.p2r').text.scan(/\d+/)[-1]
        c1, c2 = games_line.css('nobr')
        coeff1 = c1.text.split(/ /)[-1].to_f
        coeff2 = c2.text.split(/ /)[-1].to_f
        @parsed_event[:home_player][:game] ||= Hash.new
        @parsed_event[:away_player][:game] ||= Hash.new
        @parsed_event[:home_player][:game][num] = coeff1
        @parsed_event[:away_player][:game][num] = coeff2
      end
    end
    @parsed_event[:home_player][:name] ||= 'HomePlayer'
    @parsed_event[:away_player][:name] ||= 'AwayPlayer'
    @parsed_event
  end

  def unified_names who
    w = []
    if who.include?(' - ')
      who.split(' - ').each do |pl|
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
    if names.include?('/')
      nn = names.split(/\//)
      nn.each do |n|
        w << n.scan(/\w+/)[0]
      end
    else
      w << names.scan(/\w+/)[0]
    end
    w
  end
end
