require 'spec_helper'

RSpec.describe Marathon do
  describe '#parse_live_page' do
    let(:sport) { 'tennis' }
    let(:result) { Marathon.parse_live_page(webpage, sport) }

    context 'tennis successfully' do
      let(:webpage) { open_right_live_page 'marathon' }

      specify { expect(result.instance_of?(Hash)).to be true }
      specify { expect(result.size).not_to eq 0 }

      it "every hash key contains address" do
	result.keys.each do |key|
	  expect(key).to include Forker::MARATHON_ADDRESS
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
    let(:result) { Marathon.parse_event(webpage, sport) }
    context 'tennis Pliskova vs Beygelzimer' do
      let(:webpage) { open_event_page('marathon', 'plis_beyg.html') }
      it 'all must be good' do
	expect(result[:home_player][:name]).to eq 'Pliskova'
	expect(result[:away_player][:name]).to eq 'Beygelzimer'
	expect(result[:home_player][:match]).to eq 1.68
	expect(result[:away_player][:match]).to eq 2.2
	expect(result[:score]).to eq '15:40 (0:1 (4:6, 4:2))'
	expect(result[:home_player][:set]['2']).to eq 1.2
	expect(result[:away_player][:set]['2']).to eq 4.55
	expect(result[:home_player][:game]['8']).to eq 2.05
	expect(result[:away_player][:game]['8']).to eq 1.77
      end
    end

    context 'tennis Humbert vs Haylaz' do
      let(:webpage) { open_event_page('marathon', 'humb_hayl.html') }
      it 'all must be good' do
	expect(result[:home_player][:name]).to eq 'Humbert'
	expect(result[:away_player][:name]).to eq 'Haylaz'
	expect(result[:home_player][:match]).to eq 1.009
	expect(result[:away_player][:match]).to eq 20.00
	expect(result[:home_player][:set]['2']).to eq 1.055
	expect(result[:away_player][:set]['2']).to eq 9.00
	expect(result[:home_player][:game]['6']).to eq 1.25
	expect(result[:away_player][:game]['6']).to eq 3.90
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
