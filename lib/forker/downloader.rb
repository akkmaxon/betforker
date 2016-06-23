class Downloader

  def initialize
    Capybara.register_driver :poltergeist do |app|
      opts = {
        js_errors: false,
        phantomjs_options: ['--load-images=false', '--ignore-ssl-errors=true'],
        timeout: 20
      }
      Capybara::Poltergeist::Driver.new(app, opts)
    end
    Capybara.default_driver = :poltergeist
    @browser = Object.new
  end

  def download address
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

  def cookie_setter crawler
    case crawler
    when 'phantomjs'
      @browser.page.driver.set_cookie('cust_lang', 'en-ie', {domain: Forker::WILLIAMHILL_ADDRESS})
      @browser.page.driver.set_cookie('cust_prefs', 'ie|DECIMAL|form|TYPE|PRICE|||0|SB|0|0||1|ie|0|TIME|TYPE|0|10|A|0||0|1|0||TYPE|', {domain: Forker::WILLIAMHILL_ADDRESS})
    when 'mechanize'
      @browser.cookie_jar << Mechanize::Cookie.new(domain: Forker::MARATHON_ADDRESS, name: 'panbet.oddstype', value: 'Decimal', path: '/')
      @browser.cookie_jar << Mechanize::Cookie.new(domain: '.betfair.com', name: 'vid', value: '20691c80-5359-4b9a-98ab-20c363ae65bb', path: '/')
      @browser.cookie_jar << Mechanize::Cookie.new(domain: Forker::WILLIAMHILL_ADDRESS, name: 'cust_lang', value: 'en-ie', path: '/')
      @browser.cookie_jar << Mechanize::Cookie.new(domain: Forker::WILLIAMHILL_ADDRESS, name: 'cust_prefs', value: 'ie|DECIMAL|form|TYPE|PRICE|||0|SB|0|0||0|ie|0|TIME|TYPE|0|31|A|0||0|1|0||TYPE|', path: '/')
    end
  end

  def headers_setter
    @browser.page.driver.browser.url_blacklist = [
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
  end
end
