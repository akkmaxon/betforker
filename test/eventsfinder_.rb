require 'forker'
require 'capybara/poltergeist'
require 'mechanize'
require 'yaml'

$bookies = [
  'WilliamHill',
  'Betfair',
  'Marathon'
]
$config = YAML.load(open('/home/gentoo/Projects/ruby/forker/config.yml'))

##############CHANGE TO FALSE WHEN ALL CODE WILL BE READY FOR INTERNET TESTING#############
$local = true #open saved files

class LocalDownloader
  def download add
    open(add).read
  end
end
if $local
  class WilliamHill
    def initialize
      @live_address = 'test/html/wh_live.htm'
    end
  end
  class Betfair
    def initialize
      @live_address = 'test/html/bf_live.htm'
    end
  end
  class Marathon
    def initialize
      @live_address = 'test/html/mar_live.html'
    end
  end
end
class EventsFinderTest < Minitest::Test

  def setup
    downloader = $local ? LocalDownloader.new : Downloader.new
    @ev = Eventsfinder.new({
                             bookies: $bookies,
                             downloader: downloader
                           })
  end

  def teardown
  end

  def test_events
    ready_hash = @ev.events
    refute(ready_hash.empty?)
    ready_hash.each do |key, val|
      assert_equal(Array, val.class)
      assert_equal(String, key.class)
      assert(val.size > 1)
    end
  end
end
