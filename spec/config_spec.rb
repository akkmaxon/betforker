require 'spec_helper'

RSpec.describe Forker::Config do
  describe '.update' do
    before do
      $config = { a: 'cc', b: 10, c: true }
    end

    it 'user can update config' do
      allow(Config).to receive(:manual_enter).and_return(
	{ a: 'aa', b: 15, c: false })
      values = Config.manual_enter
      Config.update_config values

      expect($config.size).to eq 3
      expect($config.keys).to eq [:a, :b, :c]
      expect($config.values).to eq ['aa', 15, false]
    end
  end

  describe '.check_personal_configuration' do
    let!(:template) do
      { a: 'aa',
	b: true,
	c: false,
	d: 10,
	e: 1.0,
	f: [1,2,3] }
    end
    let!(:personal) { template.dup }

    before do
      allow(Config).to receive(:write_personal_config).and_return nil
    end

    it 'personal config equal template' do
      result = Config.check_personal_configuration(template, personal)

      expect(result).to eq personal
      expect(result.keys).to eq template.keys
    end

    it 'personal config have other valid values with the same keys' do
      personal[:a] = 'aaaa'
      personal[:b] = false
      personal[:c] = true
      personal[:d] = 1
      personal[:e] = 10.0
      personal[:f] = [1]
      result = Config.check_personal_configuration(template, personal)

      expect(result).to eq personal
      expect(result.keys).to eq template.keys
    end

    it 'personal config have other invalid values with the same keys' do
      personal[:a] = false
      personal[:b] = 'aaaa'
      personal[:c] = 10
      personal[:d] = 1.0
      personal[:e] = true
      personal[:f] = 'bbbb'
      result = Config.check_personal_configuration(template, personal)

      expect(result).to eq template
      expect(result.keys).to eq template.keys
    end

    it 'in personal config keys in other order' do
      personal = {}
      template.reverse_each { |k, v| personal[k] = v }
      result = Config.check_personal_configuration(template, personal)

      expect(result).to eq personal
      expect(result.keys).to eq template.keys
      expect(result.keys).to_not eq personal.keys
    end

    context 'personal config has not enough keys and values' do
      it 'with same order' do
	template[:g] = 'gggg'
	template[:h] = false
	result = Config.check_personal_configuration(template, personal)

	expect(result.keys).to eq template.keys
	expect(result.keys.count).to eq (personal.keys.count + 2)
	expect(result.values).to eq ((personal.values << 'gggg') << false)
      end

      it 'with other order' do
	reversed_template = {}
	template.reverse_each { |k, v| reversed_template[k] = v }
	reversed_template[:g] = 'gggg'
	result = Config.check_personal_configuration(reversed_template, personal)

	expect(result.keys).to eq reversed_template.keys
	expect(result.keys.count).to eq (personal.keys.count + 1)
	expect(result[:g]).to eq 'gggg'
	personal.each do |key, value|
	  expect(result[key]).to eq value
	end
      end
    end
  end
end
