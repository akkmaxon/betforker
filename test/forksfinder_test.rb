require 'test/unit'
require 'forker'

$config = {min_percent: 1.1}
#######CHANGE TO FALSE WHEN ALL CODE WILL BE READY#############
$addresses = Hash.new
(1..8).each do |num|
  $addresses[num.to_s] = []
  $addresses[num.to_s] << "test/html/williamhill#{num}.html"
  $addresses[num.to_s] << "test/html/betfair#{num}.html"
end
$local = false

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
    @finder.parsed_bookies = $parsed_bookies.clone if $local
  end

  def teardown
  end

  def test_parse
    return if $local
    $addresses.each do |key,addresses|
      @finder = Forksfinder.new({
                                downloader: LocalDownloader.new
                              })
      @finder.parsed_bookies = $parsed_bookies.clone if $local

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

  def test_good_parsed_bookies
    while @finder.parsed_bookies.size > 1
      first_bookie = @finder.parsed_bookies.shift
      @finder.parsed_bookies.each do |second_bookie|
        assert(first_bookie[:home_player][:name] == second_bookie[:home_player][:name])
        assert(first_bookie[:away_player][:name] == second_bookie[:away_player][:name])
      end
    end

  end

  def test_forking
    @finder.parse($addresses["5"]) unless $local
    Display.new.debug_parsed_bookies(@finder.parsed_bookies)
    @finder.forking
    Display.new.to_screen(@finder.forks)
    assert_equal(Array, @finder.forks.class)
    unless @finder.forks.empty?
      @finder.forks.size.times do |num|
        [:bookies, :players, :score, :what, :percent].each do |key|
          assert(@finder.forks[num].include?(key))
          assert_equal(String, @finder.forks[num][key].class)
        end
      end
    end

  end

end

$parsed_bookies = [
  { bookie: 'williamhill',
    address: 'http://sports.williamhill.com',
    score: '',
    home_player: {
      name: 'First',
      match: 1.1,
      game: {
        '7' => 1.51,
        '8' => 3.3
      }
    },
    away_player: {
      name: 'Second',
      match: 6.85,
      game: {
        '7' => 2.9,
        '8' => 1.4
      }
    }
  },
  { bookie: 'bet365',
    address: 'http://www.bet365.com',
    score: '0:3',
    home_player: {
      name: 'First',
      match: 1.24,
      set: {
        '2' => 1.01,
        '3' => 1.01
      },
      game: {
        '7' => 1.3,
        '8' => 4.4
      }
    },
    away_player: {
      name: 'Second',
      match: 4.8,
      set: {
        '3' => 1.01
      },
      game: {
        '7' => 2.7,
        '8' => 1.25
      }
    }
 },
  { bookie: 'betfair',
    address: 'http:/www.betfair.com',
    score: '0:3 (15:30)',
    home_player: {
      name: 'First',
      match: 1.01,
      set: {
        '2' => 1.01,
        '3' => 1.01
      },
      game: {
        '7' => 1.01
      }
    },
    away_player: {
      name: 'Second',
      match: 1.01,
      set: {
        '2' => 1.01,
        '3' => 1.01
      },
      game: {
        '7' => 3.71
      }
    }
 }
]
