=begin
quick vpn servers are
United Kingdom except Birmingam
Russia S-P 3
Russia M 2 3 4(very good)
=end
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
    if address =~ /williamhill|sbobet|winlinebet/
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

  def capybara_init
  end

  def cookie_setter crawler
    case crawler
    when 'phantomjs'
      @browser.page.driver.set_cookie('cust_lang', 'en-gb', {domain: '.williamhill.com'})
      @browser.page.driver.set_cookie('cust_prefs', 'en|DECIMAL|form|TYPE|PRICE|||0|SB|0|0||0|en|0|TIME|TYPE|0|31|A|0||0|1|0||TYPE|', {domain: '.williamhill.com'})
      @browser.page.driver.set_cookie('vid', '20691c80-5359-4b9a-98ab-20c363ae65bb', {domain: '.betfair.com'})
      @browser.page.driver.set_cookie('panbet.oddstype', 'Decimal', {domain: 'www.betmarathon.com'})
    when 'mechanize'
      @browser.cookie_jar << Mechanize::Cookie.new(domain: 'www.marathonbet.com', name: 'panbet.oddstype', value: 'Decimal', path: '/')
      @browser.cookie_jar << Mechanize::Cookie.new(domain: '.betfair.com', name: 'vid', value: '20691c80-5359-4b9a-98ab-20c363ae65bb', path: '/')
      @browser.cookie_jar << Mechanize::Cookie.new(domain: '.whbetting.com', name: 'cust_lang', value: 'en-gb', path: '/')
      @browser.cookie_jar << Mechanize::Cookie.new(domain: '.whbetting.com', name: 'cust_prefs', value: 'en|DECIMAL|form|TYPE|PRICE|||0|SB|0|0||0|en|0|TIME|TYPE|0|31|A|0||0|1|0||TYPE|', path: '/')
    end
  end

  def headers_setter
    @browser.page.driver.headers = { 'User-Agent' => 'Opera/9.80 (X11; Linux x86_64; Edition Linux Mint) Presto/2.12.388 Version/12.16'}
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
      'https://cdnbf.net',
      'https://uservoice.com',
      'http://mediaplex.com',
      'http://rnengage.com',
      'https://betfair.it',
      'http://dgmdigital.com',
      'http://googletagmanager.com',
      #winlinebet
      'http://livetex.ru',
      'https://www.betradar.com',
      'http://ctnsnet.com'
    ]
  end
end
