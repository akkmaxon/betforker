require 'capybara/poltergeist'

class Downloader

  def download address
    browser = capybara_init
    browser.visit address
    browser.html
  end

  def capybara_init
    Capybara.register_driver :poltergeist do |app|
      opts = {
        js_errors: false,
        phantomjs_options: ['--load-images=false', '--ignore-ssl-errors=true'],
        timeout: 45
      }
      Capybara::Poltergeist::Driver.new(app, opts)
    end
    Capybara.default_driver = :poltergeist
    browser = Capybara
    cookie_setter(browser)
    headers_setter(browser)
    #actions for light pages
    browser
  end

  def cookie_setter browser
    browser.page.driver.set_cookie('cust_lang', 'en-gb', {domain: '.williamhill.com'})
    browser.page.driver.set_cookie('cust_prefs', 'en|DECIMAL|form|TYPE|PRICE|||0|SB|0|0||0|en|0|TIME|TYPE|0|31|A|0||0|1|0||TYPE|', {domain: '.williamhill.com'})
    browser.page.driver.set_cookie('vid', '20691c80-5359-4b9a-98ab-20c363ae65bb', {domain: '.betfair.com'})
    browser
  end

  def headers_setter browser
    browser.page.driver.headers = { 'User-Agent' => 'Opera/9.80 (X11; Linux x86_64; Edition Linux Mint) Presto/2.12.388 Version/12.16'}
  end
end
