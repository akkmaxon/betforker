require 'spec_helper'

RSpec.describe Forker::Bookmakers::Marathon do
  describe '#parse_live_page' do
    let(:sport) { 'tennis' }
    let(:result) { Marathon.parse_live_page(webpage, sport) }

    context 'tennis successfully' do
      let(:webpage) { open_right_live_page 'marathon' }

      specify { expect(result.instance_of?(Hash)).to be true }
      specify { expect(result.size).not_to eq 0 }

      it "every hash key contains address" do
	result.keys.each do |key|
	  expect(key).to include Forker::MARATHON_BASE_ADDRESS
	end
      end
    end

    context 'tennis with no events' do
      let(:webpage) { marathon_live_page_without_events }
      specify { expect(result.size).to eq 0 }
    end

    context 'tennis with wrong webpage' do
      let(:webpage) { open_right_live_page 'williamhill' }
      specify { expect(result.size).to eq 0 }
    end
  end

  describe '#parse_event' do
    let(:sport) { 'tennis' }
    let(:result) do 
      event = Event.new [1,2,3]
      event.webpages.merge!({ 'marathon' => webpage })
      Marathon.parse_event(event, sport)
      event.parsed_webpages.first
    end

    context 'tennis C.Cianci/P.Martins vs B.Luz/J.Vale Costa' do
      let(:webpage) { open_event_page('marathon', 'ciamar_luzcos.html') }
      it 'all must be good' do
	expect(result.home_player[:name]).to eq 'CianciMartins'
	expect(result.away_player[:name]).to eq 'CostaLuz'
	expect(result.home_player[:match]).to eq 3.05
	expect(result.away_player[:match]).to eq 1.37
	expect(result.score).to eq '30:0 (1:0)'
	expect(result.home_player[:set]['1']).to eq 2.14
	expect(result.away_player[:set]['1']).to eq 1.70
	expect(result.home_player[:game]['3']).to eq 3.00
	expect(result.away_player[:game]['3']).to eq 1.38
      end
    end

    context 'tennis Melzer vs Skugor' do
      let(:webpage) { open_event_page('marathon', 'mel_sku.html') }
      it 'all must be good' do
	expect(result.home_player[:name]).to eq 'Melzer'
	expect(result.away_player[:name]).to eq 'Skugor'
	expect(result.home_player[:match]).to eq 1.89
	expect(result.away_player[:match]).to eq 1.909
	expect(result.home_player[:set]['2']).to eq 7.20
	expect(result.away_player[:set]['2']).to eq 1.095
	expect(result.home_player[:game]['7']).to eq 4.40
	expect(result.away_player[:game]['7']).to eq 1.21
      end
    end
  end

  describe '#concatenated_names' do
    let(:result) { Marathon.concatenated_names(names) }

    context 'First, Player v Second, Player' do
      let(:names) { 'First, Player v Second, Player' }
      specify { expect(result).to eq 'FirstSecond' }
    end

    context 'R.Klaasen / R.Ram v O.Marach / F.Martin' do
      let(:names) { 'R.Klaasen / R.Ram v O.Marach / F.Martin' }
      specify { expect(result).to eq 'KlaasenMarachMartinRam' }
    end
  end
end
