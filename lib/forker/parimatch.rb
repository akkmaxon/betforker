class Parimatch < Bookmaker

  def initialize
    @live_address = ''
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
      who = link.text
      links[href] = unified_names(who)
    end
    links
  end

  def event_parsed html_source
    nok = Nokogiri::HTML(html_source)
    score = nok.css('.l .l').text
    games = score.split(')')[-1].strip
    sets = score.split(')')[0].slice(-3..-1)
    home_set = sets.scan(/\d+/)[0]
    away_set = sets.scan(/\d+/)[-1]
    home_game = games.scan(/\d+/)[0]
    away_game = games.scan(/\d+/)[-1]
    @parsed_event[:score] = "#{home_game}:#{away_game} (#{home_set}:#{away_set})"
    
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
