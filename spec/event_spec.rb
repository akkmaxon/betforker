require 'spec_helper'

RSpec.describe Forker::Event do
  let(:addresses) do
    [ 'http://first-valid-address.com',
      'https://second-valid-address.com/en/bet',
      'http://third-valid-address.com/where-is-it?q=42424',
      'https://fourth-valid-address.com' ]
  end
  let(:event) { Event.new(addresses) }
  let(:webpages) do
    { 'first' => fake_event_webpage,
      'second' => fake_event_webpage,
      'third' => fake_event_webpage,
      'fourth' => fake_event_webpage }
  end

  before do
    allow(Downloader).to receive(:download_event_pages).
      and_return(webpages)
  end
  
  describe '#get_webpages' do
    it 'properly' do
      event.get_webpages
      pages = event.webpages

      expect(pages.size).to eq 4
      pages.each do |bookie_name, page|
	expect(page.size).to be > 1024
      end
    end
  end

  describe '#parse_webpages' do
    let(:bookmakers) { [ 'Marathon'] }
    it 'successfully' do
      allow(Marathon).to receive(:parse_event).
	and_return(updated_event(event))
      event.get_webpages
      event.parse_webpages(bookmakers)
      result = event.parsed_webpages

      expect(result.size).to eq 1
      expect(result.first.class).to eq ParsedPage
    end
  end


  describe '#find_forks'

end
