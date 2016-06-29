require 'spec_helper'

RSpec.describe Forker::Config do
  describe '#update' do
    before do
      $config = { a: 'cc', b: 'bb', c: 'aa' }
    end

    it 'user can update config' do
      allow(Config).to receive(:manual_enter).and_return(
	{ a: 'aa', b: 'bb', c: ['c', 'cc', 'ccc'] })
      values = Config.manual_enter
      Config.update_config values

      expect($config.size).to eq 3
      expect($config.keys).to eq [:a, :b, :c]
      expect($config.values).to eq ['aa', 'bb', ['c', 'cc', 'ccc']]
    end
  end
end
