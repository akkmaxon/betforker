require 'test/unit'
require 'forker'
require 'yaml'
open(File.dirname(__FILE__) + '/../config.yml') {|f| $config = YAML.load(f)}
class TestDown < Test::Unit::TestCase

  def setup
    @down = Downloader.new
  end

  def test_download
    addr = {
      wh: 'http://sports.williamhill.com/bet/en-gb',
      bf: 'https://www.betfair.com/sport/inplay',
      ya: 'http://ya.ru',
      pn: 'http://pinnaclesports.com'
    }
    addr.each do |who,link|
      page = @down.download(link)
      assert_equal(String, page.class)
      assert(page.size > 1000)
      assert(page.include? link[7, 5])
    end
  end
end
