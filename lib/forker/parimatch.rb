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
