# -*- coding: utf-8 -*-
class Winlinebet < Bookmaker

  def initialize
    @live_address = 'http://winlinebet.com/stavki/sport/tennis'
    @parsed_event = {
      bookie: 'Winlinebet',
      score: '0:0 (0:0)',
      home_player: Hash.new,
      away_player: Hash.new
    }
  end

  def live_page_parsed html_source
    nok = Nokogiri::HTML(html_source)
    links = Hash.new
    nok.css('#TABLEL .long').each do |link|
      who = link.text
      plushash = link.attribute('onclick').to_s.scan(/\d+/)[0]
      href = "http://winlinebet.com/plus/#{plushash}"
      links[href] = unified_names(who)
    end
    links
  end

  def event_parsed html_source
    nok = Nokogiri::HTML(html_source)
    nok.css('script').remove
    nok.css('style').remove
    #score extracting
    scores = nok.css('#radarscore4larg li').map {|s| s.text.strip}
    unless scores.size.odd?
      home_game_score = scores[0]
      away_game_score = scores[scores.size / 2]
      home_set_score = scores[(scores.size / 2) - 1]
      away_set_score = scores[-1]
      @parsed_event[:score] = "#{home_game_score}:#{away_game_score} (#{home_set_score}:#{away_set_score})"
    end
    #players
    h_pl = nok.css('#urad1larg').attribute('title').text.strip
    a_pl = nok.css('#urad2larg').attribute('title').text.strip
    unless h_pl.empty? or a_pl.empty?
      @parsed_event[:home_player][:name] = unified_names(h_pl)
      @parsed_event[:away_player][:name] = unified_names(a_pl)
    end
    #bets parsing
    nok.css('#tracker .left tbody tr').each do |event|
      what = event.css('.inf').text
      h_coeff, a_coeff = event.css('.betbox')
      if what =~ /матч/i
        @parsed_event[:home_player][:match] = h_coeff.text.split('#')[0].to_f

        @parsed_event[:away_player][:match] = a_coeff.text.split('#')[0].to_f
      elsif what =~ /\d сет/i
        @parsed_event[:home_player][:set] ||= Hash.new
        @parsed_event[:home_player][:set][what.to_i] = h_coeff.text.split('#')[0].to_f

        @parsed_event[:away_player][:set] ||= Hash.new
        @parsed_event[:away_player][:set][what.to_i] = a_coeff.text.split('#')[0].to_f
      elsif what =~/\d+ гейм/i
        if scores.size > 4 and what.to_i >= 6
          #home_player 40 6 3 1  =>  %w[40 6 3 1 30 3 6 4]
          #away_player 30 3 6 4
          scores.slice!(scores.size / 2)# removing away player game score
          scores.shift# removing home player game score
          scores.slice!((scores.size / 2) - 1)#removing home player current set score
          scores.pop# removing away player current set score
          sum_of_sets = 0
          scores.each { |a| sum_of_sets += a.to_i }
          num_of_game = what.to_i - sum_of_sets
        else
          num_of_game = what.to_i
        end
        @parsed_event[:home_player][:game] ||= Hash.new
        @parsed_event[:home_player][:game][num_of_game] = h_coeff.text.split('#')[0].to_f

        @parsed_event[:away_player][:game] ||= Hash.new
        @parsed_event[:away_player][:game][num_of_game] = a_coeff.text.split('#')[0].to_f
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
    w.map! { |name| changed_name(name) }
    w.sort.each { |wh| who << wh }
    who
  end

  def second_names_finder names
    w = []
    if names.include?('/')
      nn = names.split(/\//)
      nn.each do |n|
        w << n.strip.split(/ /)[0]
      end
    else
      w << names.strip.split(/ /)[0]
    end
    w
  end

  def changed_name name
    en_name = name
    Winline::NAMES.each do |rus,en|
#      en_name = en if name.eql? rus
    end
    en_name
  end

end
