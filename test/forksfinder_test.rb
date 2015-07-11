require 'test/unit'
require 'forker'
require 'yaml'
require 'nokogiri'

$config = YAML.load(open('config.yml'))

$addresses = Hash.new
(1..8).each do |num|
  $addresses[num.to_s] = []
  $addresses[num.to_s] << "test/html/williamhill#{num}.html"
  $addresses[num.to_s] << "test/html/betfair#{num}.html"
end

class LocalDownloader
  def download add
    open(add).read
  end
end

class TestForksFinder < Test::Unit::TestCase

  def setup
    @finder = Forksfinder.new({
                                downloader: LocalDownloader.new
                              })
  end

  def teardown
  end

  def test_parse
    $addresses.each do |key,addresses|
      @finder = Forksfinder.new({
                                downloader: LocalDownloader.new
                              })

      @finder.parse(addresses)
#      puts @finder.parsed_bookies
      assert_equal(Array, @finder.parsed_bookies.class)
      @finder.parsed_bookies.each do |pb|
        assert_equal(Hash, pb.class)
        assert_equal(String, pb[:bookie].class)
        assert_equal(String, pb[:score].class)
        assert_equal(Hash, pb[:home_player].class)
        assert_equal(Hash, pb[:away_player].class)
        assert_equal(String, pb[:home_player][:name].class)
        assert_equal(String, pb[:away_player][:name].class)
        ################################################
        h_pl = pb[:home_player]
        a_pl = pb[:away_player]
        if h_pl.has_key? :win and a_pl.has_key? :win
          assert_equal(Float, h_pl[:win].class)
          assert_equal(Float, a_pl[:win].class)
        end
        [:set, :game].each do |what|
          if h_pl.has_key?(what) and a_pl.has_key?(what)
            assert_equal(Hash, h_pl[what].class)
            assert_equal(Hash, a_pl[what].class)
            assert(h_pl[what].size > 0 && a_pl[what].size > 0)
            h_pl[what].each {|key,val| assert_equal(Float, val.class)}
            a_pl[what].each {|key,val| assert_equal(Float, val.class)}
          end
        end
      end
    end
  end


  def test_forking
    (6..8).each do |num|
    @finder = Forksfinder.new({
                                downloader: LocalDownloader.new
                              })
      @finder.parse($addresses[num.to_s])
#      puts @finder.parsed_bookies
      @finder.forking
#      Output.new.to_screen(@finder.forks)
      assert_equal(Array, @finder.forks.class)
      @finder.forks.size.times do |num|
        [:bookies, :players, :score, :what, :percent].each do |key|
          assert(@finder.forks[num].include?(key))
          assert_equal(String, @finder.forks[num][key].class)
        end
      end
    end
  end

end
