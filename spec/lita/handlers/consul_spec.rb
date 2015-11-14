require "spec_helper"

describe Lita::Handlers::Consul, lita_handler: true do
  describe 'lita routes' do
    it { is_expected.to route_command('consul get mykey').to(:consul_get) }
  end

  before do
    allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(response)
  end
    
  let(:response) { double("Faraday::Response") }
  let(:single_key_response) {
    %{
      [
        {
          "CreateIndex":67,
          "ModifyIndex":67,
          "LockIndex":0,
          "Key":"mykey",
          "Flags":0,
          "Value":"dGVzdGluZw=="
        }
      ]
    }
  }

  let(:null_value_response) {
    %{
      [
        {
          "CreateIndex":67,
          "ModifyIndex":67,
          "LockIndex":0,
          "Key":"mykey",
          "Flags":0,
          "Value":null
        }
      ]
    }
  }

  describe '#consul get' do
    it 'return value for key' do
      allow(response).to receive(:body).and_return(single_key_response)
      send_command('consul get mykey')
      expect(replies.last).to eq("mykey = testing")
    end
    it 'return null value for key' do
      allow(response).to receive(:body).and_return(null_value_response)
      send_command('consul get mykey')
      expect(replies.last).to eq("mykey = null")
    end
  end
end
