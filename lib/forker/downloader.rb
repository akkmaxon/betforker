module Forker
  module Downloader
    def init_capybara
      Capybara.register_driver :poltergeist do |app|
	opts = {
	  js_errors: false,
	  phantomjs_options: ['--load-images=false', '--ignore-ssl-errors=true'],
	  timeout: 20
	}
	Capybara::Poltergeist::Driver.new(app, opts)
      end
      Capybara.javascript_driver = :poltergeist
      Capybara.default_driver = :poltergeist
      Capybara::Poltergeist::Driver
    end

    def self.get_live_events
      # returns hash addr => players
      events = Hash.new
      bookie_under_filter = Array.new
      bookies.each do |bookmaker|
	who = eval "#{bookmaker}.new"
	begin
	  html = downloader.download who.live_address
	rescue Mechanize::ResponseCodeError
	  puts "#{bookmaker} is not available now"
	  next
	end
	events.merge! who.live_page_parsed html
	bookie_under_filter << bookmaker if html.include? 'minjust.ru'
      end
      Output.new.provider_filter(bookie_under_filter) unless bookie_under_filter.empty?
      events
    end

    def download_live_page(bookie)
      case bookie
      when 'Marathon'
	browser = Mechanize.new
	browser = set_cookies_for browser
	begin
	  html = browser.get(MARATHON_TENNIS_LIVE).body
	rescue => e
	  raise e
	end
	html 
      when 'WilliamHill'
	browser = init_capybara
	browser = set_cookies_for browser
	browser = set_headers_for browser
	begin
	  html = browser.visit(WILLIAMHILL_LIVE).html
	rescue => e
	  raise e
	end
	html
      end
    end

    def download_event_pages(addresses)
      # [ 'http..', 'http..'..]
      # returns { 'marathon' => html, 'williamhill' => html }
    end

    def old_download address
      puts "Processing #{address}"
      if address =~ /williamhill|sbobet|winlinebet|whbetting|bukstavki/
	@browser = Capybara
	cookie_setter('phantomjs')
	headers_setter
	@browser.visit address
	page = @browser.html
	@browser.reset!
	page
      else
	@browser = Mechanize.new
	cookie_setter('mechanize')
	page = @browser.get(address).body
      end
      page
    end

    def set_cookies_for(crawler)
      case crawler.class
      when Mechanize
	crawler.cookie_jar << Mechanize::Cookie.new(domain: Forker::MARATHON_CHANGABLE, name: 'panbet.oddstype', value: 'Decimal', path: '/')
	crawler.cookie_jar << Mechanize::Cookie.new(domain: '.betfair.com', name: 'vid', value: '20691c80-5359-4b9a-98ab-20c363ae65bb', path: '/')
	crawler.cookie_jar << Mechanize::Cookie.new(domain: Forker::WILLIAMHILL_CHANGABLE, name: 'cust_lang', value: 'en-ie', path: '/')
	crawler.cookie_jar << Mechanize::Cookie.new(domain: Forker::WILLIAMHILL_CHANGABLE, name: 'cust_prefs', value: 'ie|DECIMAL|form|TYPE|PRICE|||0|SB|0|0||0|ie|0|TIME|TYPE|0|31|A|0||0|1|0||TYPE|', path: '/')
      else
	crawler.page.driver.set_cookie('cust_lang', 'en-ie', {domain: Forker::WILLIAMHILL_CHANGABLE})
	crawler.page.driver.set_cookie('cust_prefs', 'ie|DECIMAL|form|TYPE|PRICE|||0|SB|0|0||1|ie|0|TIME|TYPE|0|10|A|0||0|1|0||TYPE|', {domain: Forker::WILLIAMHILL_CHANGABLE})
      end
      crawler
    end

    def set_headers_for(crawler)
      crawler.page.driver.browser.url_blacklist = [
	'https://zz.connextra.com',
	'http://envoytransfers.com',
	'https://www.brightcove.com',
	'http://ethn.io',
	'http://www.staticcache.org',
	'http://www.ensighten.com',
	'http://scoreboards.williamhill.com',
	'http://amazonaws.com',
	'http://whdn.williamhill.com',
	'http://whdn.whbetting.com',
	'https://cdnbf.net',
	'https://uservoice.com',
	'http://mediaplex.com',
	'http://rnengage.com',
	'https://betfair.it',
	'http://dgmdigital.com',
	'http://googletagmanager.com',
	'https://mpsnare.iesnare.com/snare.js',
	'https://mpsnare.iesnare.com/script/logo.js',
	'https://mpsnare.iesnare.com/stmgwb2.swf',
	#winlinebet
	'http://livetex.ru',
	'https://www.betradar.com',
	'http://ctnsnet.com'
      ]
      crawler
    end
  end
end
