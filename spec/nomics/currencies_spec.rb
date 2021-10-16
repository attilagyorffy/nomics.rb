require 'spec_helper'

RSpec.describe Nomics::Currencies do
  describe '.new' do
    context 'with a single currency symbol' do
      it 'holds a list of currencies' do
        currencies = described_class.new(:BTC)

        expect(currencies.first).to be_a(Nomics::Currency)
        expect(currencies.count).to eql(1)
      end
    end

    context 'with multiple currency symbols' do
      it 'holds a list of currencies' do
        currencies = described_class.new(:BTC, :ETH)

        expect(currencies.first).to be_a(Nomics::Currency)
        expect(currencies.last).to be_a(Nomics::Currency)
        expect(currencies.count).to eql(2)
      end
    end
  end
end
