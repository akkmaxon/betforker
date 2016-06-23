require 'spec_helper'

RSpec.describe Comparer do
  $config = { min_percent: 1.1, filtering: true, log_file: 'spec/support/logfile'}
  describe '#compare' do
    let(:first) do
      {	
	bookie: 'WilliamHill',
	score: '',
	home_player: { name: 'Home_Player', match: 1.6, game: {'5' => 2.2 }, set: {'1' => 1.4 }},
	away_player: { name: 'Away_Player', match: 2.3, game: {'5' => 1.7 }, set: {'1' => 2.9 }} 
      }
    end

    let(:second) do
      {	
	bookie: 'Betfair',
	score: '0:0 (2:1)',
	home_player: { name: 'Home_Player', match: 1.3, game: {'5' => 2.9 }, set: {'1' => 1.6 }},
	away_player: { name: 'Away_Player', match: 3.3, game: {'5' => 1.4 }, set: {'1' => 2.2 }} 
      }
    end

    it 'find forks' do
      forks = Comparer.compare first, second
      expect(forks).not_to be_empty
      forks.each do |fork|
	expect(fork[:bookies]).to eq 'WilliamHill - Betfair'
	expect(fork[:players]).to eq 'Home_Player  VS  Away_Player'
	expect(fork[:score]).to eq '0:0 (2:1)'
	expect(fork[:what]).to match /match|game5|set1/
      end
    end

    it 'find only one fork(game)' do
      scores = ['15:0 (2:1)', '30:0 (0:3)', '0:0 (0:2)', '0:0 (1:1)']
      scores.each do |s|
	second[:score] = s
	forks = Comparer.compare first, second
	expect(forks).not_to be_empty
	expect(forks.size).to eq 1
	expect(forks[0][:what]).to eq 'game5'
      end
    end

    it 'find if it is break' do
      scores = ['0:0 (0:0)', '0:0 (2:3)', '0:0 (6:2)', '0:0 (5:7)']
      scores.each do |s|
	second[:score] = s
	second[:home_player][:game]['5'] = 2.2
	forks = Comparer.compare first, second
	expect(forks).not_to be_empty
	expect(forks.size).to eq 2
	forks.each do |fork|
	  expect(fork[:what]).to match /match|set1/
	end
      end
    end

    it 'do not find forks' do
      other_second = second.dup
      other_second[:home_player] = second[:away_player]
      other_second[:away_player] = second[:home_player]
      forks = Comparer.compare first, other_second
      expect(forks).to be_empty
    end

    it 'do not find when not break' do
      scores = ['0:0 (2:2)', '15:30 (2:3)', '0:0 (6:6)']
      scores.each do |s|
	second[:score] = s
	forks = Comparer.compare first, second
	expect(forks).to be_empty
      end
    end

  end
end
