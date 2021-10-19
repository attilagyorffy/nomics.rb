require 'bigdecimal'

RSpec.describe Nomics::Currency do
  describe '.new' do
    it 'takes a symbol' do
      expect(described_class.new(:BTC).symbol).to eql(:BTC)
    end

    it 'takes a string' do
      expect(described_class.new('BTC').symbol).to eql(:BTC)
    end

    it 'converts lower case symbols to uppercase' do
      expect(described_class.new(:btc).symbol).to eql(:BTC)
    end

    it 'converts lower case strings to uppercase' do
      expect(described_class.new('btc').symbol).to eql(:BTC)
    end

    context 'without a convert parameter' do
      it 'defaults to USD to quote ticker price, market cap, and volume values' do
        expect(described_class.new('btc').quote_currency).to eql(:USD)
      end
    end

    context 'with a convert parameter' do
      it 'takes the provided value to USD to quote ticker price, market cap, and volume values' do
        expect(described_class.new('btc', convert: 'eur').quote_currency).to eql(:EUR)
      end
    end
  end

  Nomics::Currency::ATTRIBUTES_WITH_TYPES.each do |attribute_name, _attribute_type|
    describe "##{attribute_name}" do
      let(:currency) { described_class.new('BTC') }

      it "responds to :#{attribute_name}" do
        expect(currency).to respond_to(attribute_name.to_sym)
      end
    end
  end

  describe '#attributes' do
    subject(:attributes) { currency.attributes }

    let(:currency) { described_class.new(:BTC) }

    context 'when data has NOT yet been loaded' do
      it 'loads data from the Nomics API' do
        VCR.use_cassette('btc-ticker') do
          currency.attributes
          currency.attributes
          expect(a_request(:get, %r{https://api.nomics.com})).to have_been_made.once
        end
      end
    end

    context 'when data has already been loaded' do
      before do
        VCR.use_cassette('btc-ticker') do
          currency.attributes
        end
      end

      it 'does NOT create subsequent requests to the Nomics API' do
        currency.attributes
        currency.attributes
        expect(a_request(:get, %r{https://api.nomics.com})).to have_been_made.once
      end
    end

    context 'with a reload: true parameter' do
      before do
        VCR.use_cassette('btc-ticker') do
          currency.attributes
        end
      end

      it 'reloads the data from the api and populates the currency with data' do
        expect do
          VCR.use_cassette('btc-ticker-updated') do
            currency.attributes(reload: true)
          end
        end.to change { currency.price }
      end
    end

    it 'returns a set of known attributes with type casting' do
      VCR.use_cassette('btc-ticker') do
        expect(attributes).to be_a Hash
      end

      expect(attributes['id']).to eql('BTC')
      expect(attributes['name']).to eql('Bitcoin')
      expect(attributes['currency']).to eql('BTC')
      expect(attributes['symbol']).to eql(:BTC)
      expect(attributes['price']).to eql(BigDecimal('61255.21807833'))
      expect(attributes['price_date']).to eql(Time.parse('2021-10-18T00:00:00Z'))
    end
  end

  describe 'memoization' do
    context 'when currency data has NOT yet been fetched' do
      let(:currency) { described_class.new(:BTC) }

      before do
        stub_request(:get, %r{https://api.nomics.com}).to_return(
          status: 200,
          body: [{'id' => 'BTC', 'price' => '2000'}].to_json
        )
      end

      it 'fetches the data from the Nomics API only once' do
        currency.price
        currency.price
        currency.price
        expect(a_request(:get, %r{https://api.nomics.com})).to have_been_made.once
      end
    end
  end
end
