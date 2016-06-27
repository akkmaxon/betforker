module Forker
  module Downloader
    def download_live_page(bookie)
      browser, live_address = case bookie
			      when 'Marathon'
				[ marathon_cookies(Mechanize.new),
				MARATHON_TENNIS_LIVE ]
			      when 'WilliamHill'
				[ williamhill_cookies(Mechanize.new),
				WILLIAMHILL_LIVE ]
			      end
      begin
	html = browser.get(live_address).body
	html = approved_page html
      rescue OpenSSL::SSL::SSLError
	raise 'You are blocked by provider!!!'
      rescue SocketError
	raise 'The address is wrong!!!'
      end
      html
    end

    def download_event_pages(addresses)
      # [ 'http..', 'http..'..]
      # returns { 'marathon' => html, 'williamhill' => html }
    end

    def marathon_cookies(crawler)
      Forker::Bookmakers::Marathon.set_cookies.each do |cookie|
	crawler.cookie_jar << Mechanize::Cookie.new(cookie)
      end
      crawler
    end


    def williamhill_cookies(crawler)
      Forker::Bookmakers::WilliamHill.set_cookies.each do |cookie|
	crawler.cookie_jar << Mechanize::Cookie.new(cookie)
      end
      crawler
    end

    def approved_page(html)
      blocked = is_blocked? html
      if blocked
	raise OpenSSL::SSL::SSLError
      else
	html
      end
    end

    def is_blocked?(html)
      words_if_blocked = ['minjust.ru', 'eais', 'gov.ru']
      words_if_blocked.each do |word|
	return true if html.include? word
      end
      false
    end
  end
end
