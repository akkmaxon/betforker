module Forker
  module Downloader
    def download_from_marathon(address)
      message_before_download address
      browser= marathon_cookies Mechanize.new
      html = browser.get(address).body
      message_after_download html
      approved_page html
    end

    def download_from_williamhill(address)
      message_before_download address
      browser= williamhill_cookies Capybara.current_session
      browser.visit(address)
      message_after_download browser.html
      approved_page browser.html
    end

    def download_live_page(bookie)
      begin
	html = case bookie
	       when 'Marathon' then download_from_marathon Forker::MARATHON_TENNIS_LIVE
	       when 'WilliamHill' then download_from_williamhill Forker::WILLIAMHILL_LIVE
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
	if address.include? Forker::MARATHON_BASE
	  result['marathon'] = download_from_marathon address
	elsif address.include? Forker::WILLIAMHILL_BASE
	  result['williamhill'] = download_from_williamhill address
	end
      end
      result
    end

    def prepare_phantomjs
      logger = if $config[:phantomjs_logger]
		 STDOUT
	       else
		 File.open('/dev/null', 'a')
	       end
      Capybara.register_driver :poltergeist do |app|
	opts = { js_errors: false,
	  phantomjs_logger: logger,
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

    def message_before_download(address)
      print "\nProcessing #{address}..."
    end

    def message_after_download(page)
      puts "ready (size: #{page.size})"
    end
  end
end
