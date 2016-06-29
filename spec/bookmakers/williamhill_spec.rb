require 'spec_helper'

RSpec.describe Forker::Bookmakers::WilliamHill do
  describe '#parse_live_page' do
    let(:sport) { 'tennis' }
    let(:result) { WilliamHill.parse_live_page(webpage, sport) }

    context 'tennis successfully' do
      let(:webpage) { open_right_live_page 'williamhill' }

      specify { expect(result.instance_of?(Hash)).to be true }
      specify { expect(result.size).not_to eq 0 }

      it "every hash key contains address" do
	result.keys.each do |key|
	  expect(key).to include Forker::WILLIAMHILL_BASE
	end
      end
    end

    context 'tennis with no events' do
      let(:webpage) { williamhill_live_page_without_events }
      specify { expect(result.size).to eq 0 }
    end

    context 'tennis with wrong webpage' do
      let(:webpage) { open_right_live_page 'marathon' }
      specify { expect(result.size).to eq 0 }
    end
  end

  describe '#parse_event' do
    let(:sport) { 'tennis' }
    let(:result) do 
      event = Event.new [1,2,3], sport
      event.webpages.merge!({ 'williamhill' => webpage })
      WilliamHill.parse_event(event, sport)
      event.parsed_webpages.first
    end

    context 'tennis Motti/Peng vs Donati/Sonego' do
      let(:webpage) { open_event_page('williamhill', 'first.html') }
      it 'all must be good' do
	expect(result.home_player[:name]).to eq 'MottiPeng'
	expect(result.away_player[:name]).to eq 'DonatiSonego'
	expect(result.home_player[:match]).to eq 3.75
	expect(result.away_player[:match]).to eq 1.25
	expect(result.home_player[:game]['4']).to eq 4.00
	expect(result.away_player[:game]['4']).to eq 1.22
      end
    end

    context 'tennis Schmiedlova vs Argyelan' do
      let(:webpage) { open_event_page('williamhill', 'second.html') }
      it 'all must be good' do
	expect(result.home_player[:name]).to eq 'Schmiedlova'
	expect(result.away_player[:name]).to eq 'Argyelan'
	expect(result.home_player[:match]).to eq 1.73
	expect(result.away_player[:match]).to eq 2.00
	expect(result.home_player[:game]['1']).to eq 2.00
	expect(result.away_player[:game]['1']).to eq 1.73
	expect(result.home_player[:game]['2']).to eq 1.40
	expect(result.away_player[:game]['2']).to eq 2.75
      end
    end
  end

  describe '#concatenated_names' do
    let(:result) { WilliamHill.concatenated_names(names) }

    context 'Luna Meers v Steffii Distelmans' do
      let(:names) { 'Luna Meers v Steffii Distelmans' }
      specify { expect(result).to eq 'DistelmansMeers' }
    end

    context 'Oleksandr Bielinsky/Michail Fufygin v Vitaly Kozyukov/Aleksander Ovcharov' do
      let(:names) { 'Oleksandr Bielinsky/Aleksander Ovcharov v Vitaly Kozyukov/Michail Fufygin' }
      specify { expect(result).to eq 'BielinskyFufyginKozyukovOvcharov' }
    end
  end
end
