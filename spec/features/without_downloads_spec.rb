require 'spec_helper'

RSpec.describe 'Forker finds forks without downloads' do
  let(:sport) { 'tennis' }
  let(:event) { Forker::Event.new [1,2,3], sport }
  before do
    $config = { min_percent: 1.1, filtering: true }
  end

  describe 'beginning with parsed webpages' do
    it 'with many forks' do
      event.parsed_webpages << parsed_marathon
      event.parsed_webpages << parsed_williamhill
      event.forking
      forks = event.forks.flatten
      
      expect(forks.size).to eq 4
      expect(forks.first.what).to eq 'match'
      forks.each do |f|
	expect(f.what).to match /match|game|set/
	expect(f.score).to eq '0:0 (3:2)'
	expect(f.players).to eq 'AwayPlayer  VS  HomePlayer'
      end
    end

    it 'without any fork' do
      changed_parsed_williamhill = parsed_marathon
      changed_parsed_williamhill.bookie = 'WilliamHill'
      event.parsed_webpages << parsed_marathon 
      event.parsed_webpages << changed_parsed_williamhill
      event.forking
      forks = event.forks.flatten

      expect(forks.size).to eq 0
    end

    it 'no forks if all pages from one bookie' do
      changed_parsed_marathon = parsed_williamhill
      changed_parsed_marathon.bookie = 'Marathon'
      event.parsed_webpages << parsed_marathon
      event.parsed_webpages << changed_parsed_marathon
      event.forking
      forks = event.forks.flatten

      expect(forks.size).to eq 0
    end
  end

  describe 'beginning with parsing webpages' do
    let(:mar_with_forks) do
      { 'marathon' => open_event_page('marathon', 'with_forks.html') }
    end
    let(:wh_with_forks) do
      { 'williamhill' => open_event_page('williamhill', 'with_forks.html') }
    end
    let(:wh_without_forks) do
      { 'williamhill' => open_event_page('williamhill', 'without_forks.html') }
    end

    it 'successfully with 1 fork' do
      event.webpages.merge! mar_with_forks
      event.webpages.merge! wh_with_forks
      event.parse_webpages ['Marathon', 'WilliamHill']
      event.forking
      forks = event.forks.flatten

      expect(forks.size).to eq 1
      expect(forks.first.what).to eq 'game7'
    end

    it 'successfully with 2 forks' do
      $config = { min_percent: 1.1, filtering: false }
      event.webpages.merge! mar_with_forks
      event.webpages.merge! wh_with_forks
      event.parse_webpages ['Marathon', 'WilliamHill']
      event.forking
      forks = event.forks.flatten

      expect(forks.size).to eq 2
      expect(forks.first.what).to eq 'match'
      expect(forks.last.what).to eq 'game7'
      $config = { min_percent: 1.1, filtering: true }
    end

    it 'without forks' do
      event.webpages.merge! mar_with_forks
      event.webpages.merge! wh_without_forks
      event.parse_webpages ['Marathon', 'WilliamHill']
      event.forking
      forks = event.forks.flatten

      expect(forks.size).to eq 0
    end
  end

  describe 'beginning with created Events' do
    let(:event) { Event.new ['mar_with_forks', 'wh_with_forks'], sport }
    let(:return_from_downloader) do
      { 'marathon' => open_event_page('marathon', 'with_forks.html'),
	'williamhill' => open_event_page('williamhill', 'with_forks.html') }
    end
    
    it 'find a fork' do
      allow(Downloader).to receive(:download_event_pages).
	and_return(return_from_downloader)
      allow(event).to receive(:all_bookmakers).
	and_return(['Marathon', 'WilliamHill'])

      forks = event.find_forks
      f = forks.first

      expect(forks.size).to eq 1
      expect(f.what).to eq 'game7'
      expect(f.bookmakers).to eq 'Marathon - WilliamHill'
    end
  end
end
