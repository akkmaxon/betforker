require_relative 'test_helper'

class DownloaderTest < Minitest::Test

  def setup
    @downloader = Downloader.new
    @mar_domain = Forker::MARATHON_ADDRESS
  end

  def test_download_marathon_with_proper_cookies
    address = "https://#{@mar_domain}/en/live"
    page = @downloader.download(address)
    assert page.size > 1000
    assert page.include?('Marathonbet'), "There is no 'Marathonbet' in the page"
    assert page.include?('"oddsType":"Decimal"'), "Marathon cookies not found"
    assert page.include?('"locale_name":"en"'), "Language is not english(marathon)"
    assert_equal "https://#{@mar_domain}:443/en/login.htm",
    	Nokogiri::HTML(page).css("#auth").attribute("action").text
  end

  def test_download_williamhill_with_proper_cookies
    address = "http://sports#{Forker::WILLIAMHILL_ADDRESS}/bet/en-ie/betlive/all"
    page = @downloader.download(address)
    assert page.size > 1000
    assert page.include?(Forker::WILLIAMHILL_ADDRESS), "I can't find #{Forker::WILLIAMHILL_ADDRESS}"
    assert page.include?('Join Now'), "Language is not english(williamhill)"
    assert page.include?('priceFormat: "decimal"'), "WilliamHill cookies not found"
    assert_equal "https://sports#{Forker::WILLIAMHILL_ADDRESS}/bet/en-ie",
    	Nokogiri::HTML(page).css("#login").attribute("action").text
  end
=begin
  def test_download_parimatch
    address = 'http://www.parimatch.com/en/live.html'
    page = @downloader.download(address)
    assert page.size > 1000
    assert page.include?('parimatch.com'), "I can't find 'parimatch.com'"
    assert page.include?('Login'), "Language is not english(parimatch)"
    assert_equal "/en/live.html?login=1",
    	Nokogiri::HTML(page).css("#auth").attribute("action").text
  end

  def test_download_betfair_with_proper_cookies
    address = 'https://www.betfair.com/sport/inplay'
    page = @downloader.download(address)
    assert page.size > 1000
    assert page.include?('Betfair'), "I can't find 'Betfair'"
    refute page.include?('ui-fraction-price'), "Betfair cookies not found"
    assert_equal "https://identitysso.betfair.com/api/login",
    	Nokogiri::HTML(page).css("form.ssc-lif").attribute("action").text
  end
=end
end
