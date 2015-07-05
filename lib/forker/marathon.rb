require 'nokogiri'
class Marathon < Bookmaker

  def initialize
    #only tennis live page!!
    @live_address = 'https://www.betmarathon.com/en/live/22723'
    @parsed_event = {
      bookie: 'Marathon',
      score: '',
      home_player: Hash.new,
      away_player: Hash.new
    }
  end

  def live_page_parsed html_source
    nok = Nokogiri::HTML(html_source)
    links = Hash.new
    nok.css('.live-today-name .command').each do |link|
      num = link.attribute('onclick').text.scan(/\d+/)
      number = num.first if num.class == Array
      href = "https://www.betmarathon.com/en/live/#{number}?openedMarkets=#{number}"
      who = link.css('.live-today-member-name')[0].text.strip + " v " + link.css('.live-today-member-name')[1].text.strip
      links[href] = unified_names(who)
    end
    links
  end

  def event_parsed html_source
    nok = Nokogiri::HTML(html_source)
    nok.css('script').remove
    games_score = nok.css('.cl-left .result-description-part').text.strip[1...-1]
    nok.css('.cl-left .result-description-part').remove
    sets_score = nok.css('.cl-left').text.strip
    @parsed_event[:score] = "#{games_score} (#{sets_score})"
    h_pl = nok.css('.live-today-name .live-today-member-name')[0].text.strip
    a_pl = nok.css('.live-today-name .live-today-member-name')[1].text.strip
    unless h_pl.empty? or a_pl.empty?
      @parsed_event[:home_player][:name] = unified_names(h_pl)
      @parsed_event[:away_player][:name] = unified_names(a_pl)
    end
    sets_nums = ['1st', '2nd', '3rd', '4th', '5th']
    nok.css('span.selection-link').each do |link|
      if link.attribute('data-selection-key').text.include? 'Match_Result.1'
        @parsed_event[:home_player][:match] = link.text.to_f
      elsif link.attribute('data-selection-key').text.include? 'Match_Result.3'
        @parsed_event[:away_player][:match] = link.text.to_f
      end
      sets_nums.each do |v|
        if link.attribute('data-selection-key').text.include? "#{v}_Set_Result.RN_H"
          @parsed_event[:home_player][:set] ||= Hash.new
          @parsed_event[:home_player][:set][v[0]] = link.text.to_f
        elsif link.attribute('data-selection-key').text.include? "#{v}_Set_Result.RN_A"
          @parsed_event[:away_player][:set] ||= Hash.new
          @parsed_event[:away_player][:set][v[0]] = link.text.to_f
        end
      end
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

  def second_names_finder names#works only with singles not doubles
    w = []
    names.gsub!('-', ' ')
    w << names.split(',')[0].scan(/\w+/)[-1]
    w
  end

end
