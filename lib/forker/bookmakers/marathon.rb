module Forker
  module Bookmakers
    module Marathon

      def self.parse_live_page(html, sport)
	nok = Nokogiri::HTML(html)
	links = {}
	nok.css('tbody').each do |table|
	  next unless table.attribute('data-event-treeid')
	  number = table.attribute('data-event-treeid').text.to_i
	  href = "#{Forker::MARATHON_BASE}live/#{number}?openedMarkets=#{number}"
	  players = table.css('.live-today-member-name')[0].text.strip + " v " + table.css('.live-today-member-name')[1].text.strip
	  links[href] = concatenated_names(players)
	end
	links
      end

      def self.parse_event(event, sport)
	result = Forker::ParsedPage.new bookie: 'Marathon'
	html = extract_html_from(event)
	return event if html.nil?
	nok = Nokogiri::HTML(html)
	nok.css('script').remove
	games_score = nok.css('.cl-left .result-description-part').text.strip[1...-1]
	nok.css('.cl-left .result-description-part').remove
	sets_score = nok.css('.cl-left').text.strip
	result.score = "#{games_score} (#{sets_score})"
	h_pl = nok.css('.live-today-name .live-today-member-name')[0].text.strip
	a_pl = nok.css('.live-today-name .live-today-member-name')[1].text.strip
	unless h_pl.empty? or a_pl.empty?
	  result.home_player[:name] = concatenated_names(h_pl)
	  result.away_player[:name] = concatenated_names(a_pl)
	end
	#find sets & match
	sets_nums = %w{ 1st 2nd 3rd 4th 5th }
	nok.css('span.selection-link').each do |link|
	  if link.attribute('data-selection-key').text.include? 'Match_Result.1'
	    result.home_player[:match] = link.text.to_f
	  elsif link.attribute('data-selection-key').text.include? 'Match_Result.3'
	    result.away_player[:match] = link.text.to_f
	  end
	  sets_nums.each do |v|
	    if link.attribute('data-selection-key').text.include? "#{v}_Set_Result.RN_H"
	      result.home_player[:set] ||= Hash.new
	      result.home_player[:set][v[0]] = link.text.to_f
	    elsif link.attribute('data-selection-key').text.include? "#{v}_Set_Result.RN_A"
	      result.away_player[:set] ||= Hash.new
	      result.away_player[:set][v[0]] = link.text.to_f
	    end
	  end
	end
	#find games
	nok.css('.block-market-wrapper').each do |chunk|
	  next unless chunk.attribute('data-mutable-id').text =~ /B82|Block_82/
	  chunk.css('.market-inline-block-table-wrapper').each do |ch|
	    next unless ch.css('.name-field').text.include? 'To Win Game'
	    ch.css('table tr').each do |t|
	      next if t.to_s.include?('<th')
	      num = t.css('.market-table-name b').text
	      coeff1, coeff2 = t.css('.price .selection-link').collect {|c| c.text.to_f}
	      if coeff1 and coeff2
		result.home_player[:game] ||= {}
		result.away_player[:game] ||= {}
		result.home_player[:game][num] = coeff1
		result.away_player[:game][num] = coeff2
	      end
	    end
	  end
	end
	result.home_player[:name] ||= 'HomePlayer'
	result.away_player[:name] ||= 'AwayPlayer'
	event.parsed_webpages << result
      end

      def self.extract_html_from(event)
	arr = event.webpages.values_at 'marathon'
	arr.first
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
	who = ""
	w.sort.each { |wh| who << wh }
	who
      end

      def self.second_names_finder(names)
	second_name = []
	if names.include?('/')
	  nn = names.split(/\//)
	  nn.each do |n|
	    second_name << n.scan(/\w+/)[-1]
	  end
	elsif names.include?('Doubles')
	  second_name << names.scan(/\w+/)[-2]
	else
	  second_name << names.split(',')[0].scan(/\w+/)[-1]
	end
	second_name
      end

      def self.set_cookies
	domain = Forker::MARATHON_CHANGABLE.gsub('https://www', '')
	[{
	  domain: domain,
	  name: 'panbet.oddstype',
	  value: 'Decimal',
	  path: '/'
	}]
      end
    end
  end
end
