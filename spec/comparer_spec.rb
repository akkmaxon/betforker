require 'spec_helper'

RSpec.describe Forker::Comparer do
  describe '#compare' do
    let(:first) do
      parsed = ParsedPage.new bookie: 'WilliamHill'
      parsed.score = ''
      parsed.home_player = 
	{ name: 'Home_Player', match: 1.6, game: {'5' => 2.2 }, set: {'1' => 1.4 } }
      parsed.away_player =
	{ name: 'Away_Player', match: 2.3, game: {'5' => 1.7 }, set: {'1' => 2.9 } } 
      parsed
    end

    let(:second) do
      parsed = ParsedPage.new bookie: 'Betfair'
      parsed.score = '0:0 (2:1)'
      parsed.home_player =
	{ name: 'Home_Player', match: 1.3, game: {'5' => 2.9 }, set: {'1' => 1.6 } }
      parsed.away_player =
	{ name: 'Away_Player', match: 3.3, game: {'5' => 1.4 }, set: {'1' => 2.2 } } 
      parsed
    end

    it 'find forks' do
      forks = Comparer.compare first, second
      expect(forks).not_to be_empty
      forks.each do |f|
	expect(f.class).to eq Fork
	expect(f.bookmakers).to eq 'WilliamHill - Betfair'
	expect(f.players).to eq 'Away_Player  VS  Home_Player'
	expect(f.score).to eq '0:0 (2:1)'
	expect(f.what).to match /match|game5|set1/
      end
    end

    it 'find only one fork(game)' do
      scores = ['15:0 (2:1)', '30:0 (0:3)', '0:0 (0:2)', '0:0 (1:1)']
      scores.each do |s|
	second.score = s
	forks = Comparer.compare first, second
	expect(forks).not_to be_empty
	expect(forks.size).to eq 1
	expect(forks[0].what).to eq 'game5'
      end
    end

    it 'find if it is break' do
      scores = ['0:0 (0:0)', '0:0 (2:3)', '0:0 (6:2)', '0:0 (5:7)']
      scores.each do |s|
	second.score = s
	second.home_player[:game]['5'] = 2.2
	forks = Comparer.compare first, second
	expect(forks).not_to be_empty
	expect(forks.size).to eq 2
	forks.each do |f|
	  expect(f.what).to match /match|set1/
	end
      end
    end

    it 'do not find forks' do
      other_second = second.dup
      other_second.home_player = second.away_player
      forks = Comparer.compare first, other_second
      expect(forks).to be_empty
    end

    it 'do not find when not break' do
      scores = ['0:0 (2:2)', '15:30 (2:3)', '0:0 (6:6)']
      scores.each do |s|
	second.score = s
	forks = Comparer.compare first, second
	expect(forks).to be_empty
      end
    end
  end

  describe '#check_sorting' do
    let(:homeplayer) { 'Aaaa' }
    let(:awayplayer) { 'Zzzz' }
    let(:first) do
      parsed = ParsedPage.new bookie: 'First'
      parsed.home_player[:name] = homeplayer
      parsed.away_player[:name] = awayplayer
      parsed
    end
    let(:second) do
      parsed = ParsedPage.new bookie: 'Second'
      parsed.home_player[:name] = homeplayer
      parsed.away_player[:name] = awayplayer
      parsed
    end

    it 'will not change anything' do
      Comparer.check_sorting first, second
      
      expect(first.home_player[:name]).to eq homeplayer
      expect(first.away_player[:name]).to eq awayplayer
      expect(second.home_player[:name]).to eq homeplayer
      expect(second.away_player[:name]).to eq awayplayer
    end

    it 'will change players' do
      Comparer.change_names(first)
      expect(first.home_player[:name]).to_not eq homeplayer
      expect(first.away_player[:name]).to_not eq awayplayer
      expect(second.home_player[:name]).to eq homeplayer
      expect(second.away_player[:name]).to eq awayplayer
      Comparer.check_sorting first, second
      expect(first.home_player[:name]).to eq homeplayer
      expect(first.away_player[:name]).to eq awayplayer
      expect(second.home_player[:name]).to eq homeplayer
      expect(second.away_player[:name]).to eq awayplayer
    end
  end

  describe '#calculate' do
    it 'when it is a fork' do
      x, y = 1.5, 4.0
      percent = Comparer.calculate x, y
      expect(percent).to be > 2.0
    end

    it 'when it is a fork(reverted x and y)' do
      x, y = 4.0, 1.5
      percent = Comparer.calculate x, y
      expect(percent).to be > 2.0
    end

    it 'when it is not a fork' do
      x, y = 1.2, 4.0
      percent = Comparer.calculate x, y
      expect(percent).to be < 2.0
    end

    it 'when x or y are 0' do
      x, y = 0.0, 0.0
      percent = Comparer.calculate x, y
      expect(percent).to be == -3.5
    end
  end

  describe '#is_a_break?' do
    it 'when a break' do
      ['0:0 (2:3)', '0:0 (5:2)', '0:0 (0:0)'].each do |score|
	state = Comparer.is_a_break? score
	expect(state).to be_truthy
      end
    end
    it 'when not a break' do
      ['0:0 (4:4)', '0:0 (6:6)', '30:15 (0:1)'].each do |score|
	state = Comparer.is_a_break? score
	expect(state).to be_falsey
      end
    end 
  end
end
