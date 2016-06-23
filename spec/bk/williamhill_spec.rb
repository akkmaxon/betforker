require 'spec_helper'

RSpec.describe WilliamHill do
  describe '#parse_live_page' do
    let(:sport) { 'tennis' }
    let(:result) { WilliamHill.parse_live_page(webpage, sport) }

    context 'tennis successfully' do
      let(:webpage) { open_right_live_page 'williamhill' }

      specify { expect(result.instance_of?(Hash)).to be true }
      specify { expect(result.size).not_to eq 0 }

      it "every hash key contains address" do
	result.keys.each do |key|
	  expect(key).to include Forker::WILLIAMHILL_ADDRESS
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
    let(:result) { WilliamHill.parse_event(webpage, sport) }

    context 'tennis Bedene vs Ramanathan' do
      let(:webpage) { open_event_page('williamhill', 'bed_ram.html') }
      it 'all must be good' do
	expect(result[:home_player][:name]).to eq 'Bedene'
	expect(result[:away_player][:name]).to eq 'Ramanathan'
	expect(result[:home_player][:match]).to eq 1.85
	expect(result[:away_player][:match]).to eq 1.85
	expect(result[:home_player][:set]['2']).to eq 1.36
	expect(result[:away_player][:set]['2']).to eq 3.00
	expect(result[:home_player][:game]['9']).to eq 1.12
	expect(result[:away_player][:game]['9']).to eq 5.50
      end
    end

    context 'tennis Melzer vs Casanova' do
      let(:webpage) { open_event_page('williamhill', 'mel_cas.html') }
      it 'all must be good' do
	expect(result[:home_player][:name]).to eq 'Melzer'
	expect(result[:away_player][:name]).to eq 'Casanova'
	expect(result[:home_player][:match]).to eq 1.10
	expect(result[:away_player][:match]).to eq 6.50
	expect(result[:home_player][:game]['2']).to eq 2.37
	expect(result[:away_player][:game]['2']).to eq 1.53
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
