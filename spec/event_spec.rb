require 'spec_helper'

RSpec.describe Betforker::Event do
  let(:sport) { 'tennis' }
  let(:addresses) do
    [ 'http://first-valid-address.com',
      'https://second-valid-address.com/en/bet',
      'http://third-valid-address.com/where-is-it?q=42424',
      'https://fourth-valid-address.com' ]
  end
  let(:event) { Event.new(addresses, sport) }
  let(:webpages) do
    { 'first' => fake_event_webpage,
      'second' => fake_event_webpage,
      'third' => fake_event_webpage,
      'fourth' => fake_event_webpage }
  end

  describe '#get_webpages' do
    it 'properly' do
      allow(Downloader).to receive(:download_event_pages).
	and_return(webpages)
      event.get_webpages
      pages = event.webpages

      expect(pages.size).to eq 4
      pages.each do |bookie_name, page|
	expect(page.size).to be > 1024
      end
    end

    it 'when returns only one page' do
      allow(Downloader).to receive(:download_event_pages).
	and_return({ 'marathon' => 'something interesting' })
      event.get_webpages
      pages = event.webpages

      expect(pages.size).to eq 1
    end

    it 'when returns no pages' do
      allow(Downloader).to receive(:download_event_pages).
	and_return({})
      event.get_webpages
      pages = event.webpages

      expect(pages.size).to eq 0
    end

  end

  describe '#parse_webpages' do
    let(:bookmakers) { [ 'Marathon'] }

    it 'successfully' do
      allow(Marathon).to receive(:parse_event).
	and_return(updated_event(event))

      event.webpages.merge! webpages
      event.parse_webpages(bookmakers)
      result = event.parsed_webpages

      expect(result.size).to eq 1
      expect(result.first.class).to eq Betforker::ParsedPage
    end
  end


  describe '#forking' do
    before do
      3.times { event.parsed_webpages << ParsedPage.new }
    end

    it 'find forks' do
      allow(Comparer).to receive(:compare).
	and_return([Fork.new, Fork.new])
      event.forking

      expect(event.forks.size).to eq 3
      expect(event.forks.flatten.size).to eq 6
      event.forks.each do |f|
	expect(f.class).to eq Array
      end
    end

    it 'find no forks' do
      allow(Comparer).to receive(:compare).
	and_return([])
      event.forking
      expect(event.forks.size).to eq 3
      expect(event.forks.flatten.size).to eq 0
    end
  end
end
