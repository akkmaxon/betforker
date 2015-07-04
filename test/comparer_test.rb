require 'test/unit'
require 'forker'

$config = { min_percent: 1.1}
class TestComparer < Test::Unit::TestCase

  def setup
    @comparer = Comparer.new
    @first = {
      bookie: WilliamHill,
      score: "",
      home_player: {
        name: "Home_Player",
        match: 1.6,
        game: {
          "4" => 2.2
        },
        set: {
          "1" => 1.4
        }
      },
      away_player: {
        name: "Away_Player",
        match: 2.3,
        game: {
          "4" => 1.7
        },
        set: {
          "1" => 2.9
        }
      }
    }
    @second = {
      bookie: Betfair,
      score: "3:3",
      home_player: {
        name: "Home_Player",
        match: 1.3,
        game: {
          "4" => 2.9
        },
        set: {
          "1" => 1.6
        }
      },
      away_player: {
        name: "Away_Player",
        match: 3.3,
        game: {
          "4" => 1.4
        },
        set: {
          "1" => 2.2
        }
      }
    }
    @bad_hash = {
      bookie: Betfair,
      score: "3:3",
      home_player: {
        name: "Away_Player",
        match: 1.3,
        game: {
          "4" => 2.9
        },
        set: {
          "1" => 1.01
        }
      },
      away_player: {
        name: "Home_Player",
        match: 3.3,
        game: {
          "4" => 1.4
        },
        set: {
          "1" => 1.01
        }
      }
    }
  end

  def teardown
  end

  def test_compare
    forks = @comparer.compare(@first, @second)
    refute(forks.empty?)
    forks.each do |fork|
      assert_equal("WilliamHill - Betfair", fork[:bookies])
      assert_equal("Home_Player  VS  Away_Player", fork[:players])
      assert_equal("3:3", fork[:score])
      assert(fork[:what] =~ /match|game4|set1/)
      assert_equal(String, fork[:percent].class)
    end
  end

  def check_return
    forks = @comparer.compare(@first, @bad_hash)
    assert(forks.empty?)
  end
end
