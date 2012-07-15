require 'spec_helper'

describe 'Gem Setup' do
  context :gem_configuration do
    it 'has a version number' do
      expect(AttributeStats::VERSION).not_to be nil
    end
  end

  context :test_setup do
    it { expect(Identity.is_a?(Class)).to eq true }
    it { expect(Identity.column_names).to include('first_name') }
    it { expect(Address.column_names).to include('line_1')}
  end
end