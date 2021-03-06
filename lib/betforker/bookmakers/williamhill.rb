module Betforker
  module Bookmakers
    module WilliamHill
      module_function

      def parse_live_page(html, sport)
	nok = Nokogiri::HTML(html)
	links = Hash.new
	nok.css('#ip_sport_24_types .CentrePad a').each do |link|
	  next unless link['href']
	  href = link['href']
	  players = link.text
	  links[href] = concatenated_names players
	end
	links
      end

      def parse_event(event, sport)
	result = Betforker::ParsedPage.new bookie: 'WilliamHill'
	html = extract_html_from(event)
	return event if html.nil?
	nok = Nokogiri::HTML(html)
	nok.css('script').remove
	nok.css('#primaryCollectionContainer .marketHolderExpanded .tableData').each do |market|
	  market.css('thead div').remove
	  title = market.css('thead span').text
	  next if title =~ /Total|Point|Deuce|Score/
	  target_filler(market, title, 'home', result)
	  target_filler(market, title, 'away', result)
	end
	result.home_player[:name] ||= 'HomePlayer'
	result.away_player[:name] ||= 'AwayPlayer'
	event.parsed_webpages << result
      end

      def extract_html_from(event)
	arr = event.webpages.values_at 'williamhill'
	arr.first
      end

      def concatenated_names(string)
	w = []
	if string.include?(' v ')
	  string.split(' v ').each do |pl|
	    w += second_names_finder(pl)
	  end
	else
	  w += second_names_finder(string)
	end
	result = ""
	w.sort.each {|wh| result << wh}
	result
      end

      def second_names_finder(names)
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

      def target_filler(market, title, home_away, result)
	result = result
	case home_away
	when 'home'
	  priceholder = '.eventpriceholder-left'
	  pricecoeff = 'div.eventpriceup'
	  player = result.home_player
	when 'away'
	  priceholder = '.eventpriceholder-right'
	  pricecoeff = 'div.eventpricedown'
	  player = result.away_player
	end
	chunk = market.css("tbody #{priceholder}").each do |pl|
	  name = pl.css('div.eventselection').text.strip
	  coeff = pl.css('div.eventprice').text.strip.to_f
	  coeff = pl.css(pricecoeff).text.strip.to_f if coeff == 0.0
	  unless coeff == 0.0
	    player[:name] ||= concatenated_names name
	    if title.include? 'Match Betting'
	      player[:match] = coeff
	    elsif title.include? ' Set - Game '
	      player[:game] ||= {}
	      player[:game].merge!({title.scan(/\w+/)[-1] => coeff})
	    elsif title.include? ' Set Betting Live'
	      player[:set] ||= {}
	      player[:set].merge!({title.scan(/\w+/)[0].to_i.to_s => coeff})
	    end
	  end
	end
	result
      end

      def set_cookies
	domain = Betforker::WILLIAMHILL_CHANGABLE.split('//').last.gsub('sports', '')
	[{
	  name: 'cust_lang',
	  value: 'en-gb',
	  attr: { domain: domain }
	},
	{
	  name: 'cust_prefs',
	  value: 'en|DECIMAL|form|TYPE|PRICE|||0|SB|0|0||0|en|0|TIME|TYPE|0|1|A|0||0|0||TYPE||-|0',
	  attr: { domain: domain }
	}]
      end
    end
  end
end
