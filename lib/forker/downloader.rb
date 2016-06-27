module Forker
  module Downloader
    def download_from_marathon(address)
      browser= marathon_cookies Mechanize.new
      html = browser.get(address).body
      approved_page html
    end

    def download_from_williamhill(address)
      browser= williamhill_cookies Capybara.current_session
      browser.visit(address)
      approved_page browser.html
    end

    def download_live_page(bookie)
      begin
	html = case bookie
	       when 'Marathon' then download_from_marathon MARATHON_TENNIS_LIVE
	       when 'WilliamHill' then download_from_williamhill WILLIAMHILL_LIVE
	       end
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
	  result['marathon'] = download_from_marathon address
	elsif address.include? WILLIAMHILL_BASE
	  result['williamhill'] = download_from_williamhill address
	end
      end
      result
    end

    def prepare_phantomjs
      Capybara.register_driver :poltergeist do |app|
	opts = { js_errors: false,
	  phantomjs_logger: File.open('/dev/null', 'a'),
	  phantomjs_options: ['--load-images=false', '--ignore-ssl-errors=true'],
	  timeout: 10 }
	Capybara::Poltergeist::Driver.new(app, opts)
      end
      Capybara.default_driver = :poltergeist
      Capybara.current_session
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
