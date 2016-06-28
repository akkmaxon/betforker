require 'spec_helper'

RSpec.describe Forker::Downloader do
  before do
    Downloader.prepare_phantomjs
  end

  after do
    Capybara.current_session.reset!
  end

  describe '#download_live_page' do
    it 'for marathon properly' do
      $marathon_live_page = Downloader.download_live_page 'Marathon'
      page = Nokogiri::HTML($marathon_live_page)
      login_attr = page.css('#auth').attribute('action').text
      script_with_data = page.css('script').find {|s| s.text.include? 'initData'}.text

      expect(page.text.size).to be > 1024
      expect(login_attr).to eq Forker::MARATHON_CHANGABLE + ':443/en/login.htm'
      expect(page.title).to include 'betting odds'
      expect(script_with_data).to include '"oddsType":"Decimal"'
      expect(script_with_data).to include '"locale_name":"en"'
    end

    it 'for williamhill properly' do
      $williamhill_live_page = Downloader.download_live_page 'WilliamHill'
      page = Nokogiri::HTML($williamhill_live_page)
      login_text = page.css('#login').text
      script_with_data = page.css('script').find {|s| s.text.include? 'flashvars'}.text

      expect(page.text.size).to be > 1024
      expect(login_text).to include 'Join Now'
      expect(script_with_data).to include 'priceFormat: "decimal"'
      expect(script_with_data).to include 'WilliamHill'
    end

    it 'marathon without cookies' do
      allow(Forker::Bookmakers::Marathon).to receive(:set_cookies).
	and_return([])
      live_page = Downloader.download_live_page 'Marathon'
      script_with_data = 
	Nokogiri::HTML(live_page).css('script').find {|s| s.text.include? 'initData'}.text

      expect(script_with_data).to include '"oddsType":"Fractions"'
    end

    it 'williamhill without cookies' do
      allow(Forker::Bookmakers::WilliamHill).to receive(:set_cookies).
	and_return([])
      live_page = Downloader.download_live_page 'WilliamHill'
      script_with_data = 
	Nokogiri::HTML(live_page).css('script').find {|s| s.text.include? 'flashvars'}.text

      expect(script_with_data).to include 'priceFormat: "fraction"'
    end
  end

  describe '#download_event_pages' do
    let(:sport) { 'tennis' }
    let(:addresses) do
      %w[ Marathon WilliamHill].map do |bookie|
	live_page = if bookie == 'Marathon' then $marathon_live_page
		    else $williamhill_live_page
		    end
	links = eval(bookie).parse_live_page(live_page, sport)
	links.keys.first
      end
    end

    specify { expect(addresses.size).to eq 2 }
    specify { expect(addresses[0]).to include Forker::MARATHON_CHANGABLE }
    specify { expect(addresses[1]).to include Forker::WILLIAMHILL_CHANGABLE }

    it 'marathon properly' do
      result = Downloader.download_event_pages addresses
      page = Nokogiri::HTML(result['marathon'])
      script_with_data = page.css('script').find {|s| s.text.include? 'initData'}.text

      expect(page.text.size).to be > 1024
      expect(page.title).to include 'betting odds'
      expect(page.css('.live-today-member-name').size).to eq 2
      expect(page.css('.active-shortcut-menu-link').text).to include 'All Markets'
      expect(script_with_data).to include '"oddsType":"Decimal"'
      expect(script_with_data).to include '"locale_name":"en"'
    end

    it 'williamhill properly' do
      result = Downloader.download_event_pages addresses
      page = Nokogiri::HTML(result['williamhill'])

      expect(page.css('#selectedLive').text).to include 'All Markets'
      expect(page.css('#primaryCollectionContainer').text).to include 'Match Betting Live'
    end
  end
end
