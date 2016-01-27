require_relative 'test_helper'

$config = { min_percent: 1.1, filtering: true, log_file: "test/logfile"}
class ComparerTest < Minitest::Test

  def setup
    @comparer = Comparer.new
    @first = {
      bookie: 'WilliamHill',
      score: "",
      home_player: { name: "Home_Player", match: 1.6, game: {"5" => 2.2 }, set: {"1" => 1.4 }},
      away_player: { name: "Away_Player", match: 2.3, game: {"5" => 1.7 }, set: {"1" => 2.9 }}
    }
    @second = {
      bookie: 'Betfair',
      score: "0:0 (2:1)",
      home_player: { name: "Home_Player", match: 1.3, game: {"5" => 2.9 }, set: {"1" => 1.6 }},
      away_player: { name: "Away_Player", match: 3.3, game: {"5" => 1.4 }, set: {"1" => 2.2 }}
    }
  end

  def test_all_forks
    forks = @comparer.compare(@first, @second)
    refute forks.empty?
    forks.each do |fork|
      assert_equal("WilliamHill - Betfair", fork[:bookies])
      assert_equal("Home_Player  VS  Away_Player", fork[:players])
      assert_equal("0:0 (2:1)", fork[:score])
      assert(fork[:what] =~ /match|game5|set1/)
      assert_equal(String, fork[:percent].class)
    end
  end

  def test_bad_hashes_formed
    second_pl = @second.clone
    second_pl[:home_player] = @second[:away_player].clone
    second_pl[:away_player] = @second[:home_player].clone
    forks = @comparer.compare(@first, second_pl)
    assert(forks.empty?)
  end

  def test_filter_not_break
    scores = ["0:0 (2:2)", "15:30 (2:3)", "0:0 (6:6)"]
    scores.each do |s|
      @second[:score] = s
      forks = @comparer.compare(@first, @second)
      assert(forks.empty?)
    end
  end

  def test_it_is_break
    scores = ["0:0 (0:0)", "0:0 (2:3)", "0:0 (6:2)", "0:0 (5:7)"]
    scores.each do |s|
      @second[:score] = s
      @second[:home_player][:game]["5"] = 2.2
      forks = @comparer.compare(@first, @second)
      refute(forks.empty?)
      assert(forks.size > 1)
      forks.each do |fork|
        assert(fork[:what] =~ /match|set1/)
      end
    end
  end

  def test_only_game_fork
    scores = ["15:0 (2:1)", "30:0 (0:3)", "0:0 (0:2)", "0:0 (1:1)"]
    scores.each do |s|
      @second[:score] = s
      forks = @comparer.compare(@first, @second)
      refute(forks.empty?)
      assert_equal(1, forks.size)
      forks.each do |fork|
        assert(fork[:what] == 'game5')
      end
    end
  end
end
