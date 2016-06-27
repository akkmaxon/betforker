module Forker
  module Downloader
    def prepare_phantomjs
      Capybara.register_driver :poltergeist do |app|
	opts = { js_errors: false,
	  phantomjs_options: ['--load-images=false', '--ignore-ssl-errors=true'],
	  timeout: 20 }
	Capybara::Poltergeist::Driver.new(app, opts)
      end
      Capybara.default_driver = :poltergeist
      Capybara.current_session
    end

    def download_live_page(bookie)
      begin
	case bookie
	when 'Marathon'
	  browser, live_address = [marathon_cookies(Mechanize.new), MARATHON_TENNIS_LIVE]
	  html = browser.get(live_address).body
	when 'WilliamHill'
	  browser, live_address = [williamhill_cookies(prepare_phantomjs), WILLIAMHILL_LIVE]
	  browser.visit(live_address)
	  html = browser.html
	end
	  html = approved_page html
      rescue OpenSSL::SSL::SSLError
	raise 'You are blocked by provider!!!'
      rescue SocketError
	raise 'The address is wrong!!!'
      end
      html
    end

    def download_event_pages(addresses)
      result = {}
      addresses.each do |address|
	if address.include? MARATHON_BASE
	  browser, live_address = [marathon_cookies(Mechanize.new), MARATHON_TENNIS_LIVE]
	  result['marathon'] = browser.get(address).body
	elsif address.include? WILLIAMHILL_BASE
	  browser, live_address = [williamhill_cookies(prepare_phantomjs), WILLIAMHILL_LIVE]
	  browser.visit(live_address)
	  result['williamhill'] = browser.html
	end
      end
      result
    end

    def marathon_cookies(crawler)
      Forker::Bookmakers::Marathon.set_cookies.each do |cookie|
	crawler.cookie_jar << Mechanize::Cookie.new(cookie)
      end
      crawler
    end

    def williamhill_cookies(crawler)
      Forker::Bookmakers::WilliamHill.set_cookies.each do |cookie|
	crawler.driver.set_cookie cookie[:name], cookie[:value], cookie[:attr]
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
