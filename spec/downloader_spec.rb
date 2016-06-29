require 'spec_helper'

RSpec.describe Forker::Downloader do
  describe '#download_live_page' do
    before do
      $config  = { log: false }
    end

    it 'for marathon properly' do
      allow(Downloader).to receive(:download_from_marathon).
	and_return open_right_live_page 'marathon'
      marathon_live_page = Downloader.download_live_page 'Marathon'
      page = Nokogiri::HTML(marathon_live_page)
      login_attr = page.css('#auth').attribute('action').text
      script_with_data = page.css('script').find {|s| s.text.include? 'initData'}.text

      expect(page.text.size).to be > 1024
      expect(login_attr).to include ':443/en/login.htm'
      expect(page.title).to include 'betting odds'
      expect(script_with_data).to include '"oddsType":"Decimal"'
      expect(script_with_data).to include '"locale_name":"en"'
    end

    it 'for williamhill properly' do
      allow(Downloader).to receive(:download_from_williamhill).
	and_return open_right_live_page 'williamhill'
      williamhill_live_page = Downloader.download_live_page 'WilliamHill'
      page = Nokogiri::HTML(williamhill_live_page)
      login_text = page.css('#login').text
      script_with_data = page.css('script').find {|s| s.text.include? 'flashvars'}.text

      expect(page.text.size).to be > 1024
      expect(login_text).to include 'Join Now'
      expect(script_with_data).to include 'priceFormat: "decimal"'
      expect(script_with_data).to include 'WilliamHill'
    end
    
    it 'block from provider' do
      allow(Downloader).to receive(:download_from_marathon).
	and_return page_from_provider
      
      expect { Downloader.download_live_page 'Marathon' }.to raise_error OpenSSL::SSL::SSLError
    end

    it 'get wrong argument' do
      expect { Downloader.download_live_page 'SomethingUnique' }.to raise_error RuntimeError
    end    
  end

  describe '#download_event_pages' do
    let(:sport) { 'tennis' }
    let(:addresses) { [ Forker::MARATHON_BASE, Forker::WILLIAMHILL_BASE ] }

    before do
      allow(Downloader).to receive(:download_from_marathon).
	and_return open_event_page('marathon', 'first.html')
      allow(Downloader).to receive(:download_from_williamhill).
	and_return open_event_page('williamhill', 'first.html')
    end

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

    it 'block from provider' do
      allow(Downloader).to receive(:download_from_marathon).
	and_return page_from_provider
      expect { Downloader.download_event_pages addresses }.to raise_error OpenSSL::SSL::SSLError
    end
  end
end
