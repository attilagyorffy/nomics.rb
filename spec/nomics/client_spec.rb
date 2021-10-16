require 'spec_helper'

RSpec.describe Nomics::Client do
  let(:client) { described_class.new }

  describe '#get' do
    subject(:get) { client.get('/some/path/on/the/serrver') }

    context 'when the request is successful' do
      before do
        stub_request(:get, %r{https://api.nomics.com}).to_return(
          status: 200,
          body: [{'foo' => 'bar'}].to_json
        )
      end

      it 'returns a JSON parsed response' do
        expect(get).to eql([{ 'foo' => 'bar' }])
      end
    end

    context 'when the request is unauthorized' do
      before do
        stub_request(:get, %r{https://api.nomics.com}).to_return(
          status: 401,
          body: "Authentication failed. Check your API key and our documentation at docs.nomics.com for details. If you don't have a key, you can get one at NomicsAPI.com"
        )
      end

      it 'raises an error with the message given by the server' do
        expect { get }.to raise_error(Nomics::HTTPAuthorizationError, /Authentication failed/)
      end
    end

    context 'when the api server encounters an error' do
      before do
        stub_request(:get, %r{https://api.nomics.com}).to_return(
          status: 503,
          body: "Service Unavailable"
        )
      end

      it 'raises an error with the message given by the server' do
        expect { get }.to raise_error(Nomics::APIServerError, /Service Unavailable/)
      end
    end
  end
end
