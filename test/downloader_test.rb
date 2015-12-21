require_relative 'test_helper'

class DownloaderTest < Minitest::Test

  def setup
    @downloader = Downloader.new
  end

  def test_download_marathon
    address = 'https://www.marathonbet.com/en/live/popular'
    page = @downloader.download(address)
    assert page.size > 1000
    assert page.include?('Marathonbet'), "There is no 'Marathonbet' in the page"
    assert_equal "https://www.marathonbet.com:443/en/login.htm",
    	Nokogiri::HTML(page).css("#auth").attribute("action").text
  end

  def test_download_williamhill
    address = 'http://sports.whbetting.com/bet/en-gb/betlive/all'
    page = @downloader.download(address)
    assert page.size > 1000
    assert page.include?('whbetting.com'), "I can't find 'whbetting.com'"
    assert_equal "https://sports.whbetting.com/bet/en-gb",
    	Nokogiri::HTML(page).css("#login").attribute("action").text
  end

  def test_download_parimatch
    address = 'http://www.parimatch.com/en/live.html'
    page = @downloader.download(address)
    assert page.size > 1000
    assert page.include?('parimatch.com'), "I can't find 'parimatch.com'"
    assert_equal "/en/live.html?login=1",
    	Nokogiri::HTML(page).css("#auth").attribute("action").text
  end

  def test_download_betfair
    address = 'https://www.betfair.com/sport/inplay'
    page = @downloader.download(address)
    assert page.size > 1000
    assert page.include?('Betfair'), "I can't find 'Betfair'"
    assert_equal "https://identitysso.betfair.com/api/login",
    	Nokogiri::HTML(page).css("form.ssc-lif").attribute("action").text
  end
end
