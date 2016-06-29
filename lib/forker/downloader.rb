module Forker
  module Downloader
    def download_from_marathon(address)
      begin
	browser= marathon_cookies prepare_mechanize
	browser.get(address).body
      rescue OpenSSL::SSL::SSLError
	abort 'You are blocked by provider!!!'
      rescue SocketError
	abort 'The address is wrong!!!'
      end
    end

    def download_from_williamhill(address)
      begin
	browser= williamhill_cookies Capybara.current_session
	browser.visit(address)
	browser.html
      rescue OpenSSL::SSL::SSLError
	abort 'You are blocked by provider!!!'
      rescue SocketError
	abort 'The address is wrong!!!'
      end
    end

    def download_live_page(bookie)
      html = case bookie
	     when 'Marathon'
	       address = Forker::MARATHON_TENNIS_LIVE
	       print_message_before_download address if $config[:log]
	       download_from_marathon address
	     when 'WilliamHill'
	       address = Forker::WILLIAMHILL_LIVE
	       print_message_before_download address if $config[:log]
	       download_from_williamhill address
	     else
	       raise RuntimeError, 'Unknown bookie in Download.download_live_page'
	     end
      print_message_after_download html if $config[:log]
      approved_page html
    end

    def download_event_pages(addresses)
      result = {}
      addresses.each do |address|
        print_message_before_download address if $config[:log]
	if address.include? Forker::MARATHON_CHANGABLE
	  html = download_from_marathon address
	  result['marathon'] = html
	elsif address.include? Forker::WILLIAMHILL_CHANGABLE
	  html = download_from_williamhill address
	  result['williamhill'] = html
	else
	  next
	end
	print_message_after_download html if $config[:log]
	approved_page html
      end
      result
    end

    def browsers_timeout
      $config[:download_timeout]
    end

    def prepare_mechanize
      agent = Mechanize.new
      agent.read_timeout = browsers_timeout
      agent
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
	  timeout: browsers_timeout }
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

    def print_message_before_download(address)
      $beginning = Time.now
      print "\nProcessing #{address}..."
    end

    def print_message_after_download(page)
      time = (Time.now - $beginning).round 2
      puts "ready in #{time} seconds (size: #{page.size})"
    end
  end
end
