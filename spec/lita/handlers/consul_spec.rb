require 'spec_helper'

describe Lita::Handlers::Consul, lita_handler: true do
  describe 'lita routes' do
    it { is_expected.to route_command('consul get mykey').to(:consul_get) }
    it { is_expected.to route_command('consul set mykey myvalue').to(:consul_set) }
    it { is_expected.to route_command('consul members').to(:consul_members) }
  end

  before do
    allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(response)
    allow_any_instance_of(Faraday::Connection).to receive(:put).and_return(response)
  end

  let(:response) { double('Faraday::Response') }
  let(:single_key_response) do
    %(
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
    )
  end

  let(:null_value_response) do
    %(
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
    )
  end

  let(:new_key_response) do
    %(
      [
        {
          "CreateIndex":67,
          "ModifyIndex":67,
          "LockIndex":0,
          "Key":"myapp/config/url",
          "Flags":0,
          "Value":"d3d3LnRlc3QuY29t"
        }
      ]
    )
  end

  let(:members_response) do
    %(
      [
        {"Node":"node1.node.consul","Address":"192.168.0.33"},
        {"Node":"node2.node.consul","Address":"192.168.0.34"}
      ]
    )
  end

  describe '#consul members' do
    it 'should catch connection error' do
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(Faraday::ConnectionFailed.new('Connection refused - connect(2)'))
      send_command('consul members')
      expect(replies.last).to eq('Connection refused - connect(2)')
    end

    it 'should list member nodes' do
      allow(response).to receive(:body).and_return(members_response)
      send_command('consul members')
      expect(replies.last).to eq("node1.node.consul - 192.168.0.33\nnode2.node.consul - 192.168.0.34")
    end
  end

  describe '#consul get' do
    it 'should catch error when exception occurs' do
      allow_any_instance_of(Lita::Handlers::Consul).to receive(:get_key_value).and_raise(Faraday::ConnectionFailed.new('Connection refused - connect(2)'))
      send_command('consul get mykey')
      expect(replies.last).to eq('Connection refused - connect(2)')
    end

    it 'should return value for key' do
      allow(response).to receive(:body).and_return(single_key_response)
      send_command('consul get mykey')
      expect(replies.last).to eq('mykey = testing')
    end

    it 'should return null value for key' do
      allow(response).to receive(:body).and_return(null_value_response)
      send_command('consul get mykey')
      expect(replies.last).to eq('mykey = null')
    end
  end

  describe '#consul set' do
    it 'should catch error when exception occurs' do
      allow_any_instance_of(Lita::Handlers::Consul).to receive(:get_key_value).and_raise(Faraday::ConnectionFailed.new('Connection refused - connect(2)'))
      send_command('consul set mykey value')
      expect(replies.last).to eq('Connection refused - connect(2)')
    end

    it 'should set and return value for key' do
      allow(response).to receive(:body).and_return(new_key_response)
      allow(response).to receive(:status).and_return(200)
      send_command('consul set myapp/config/url www.test.com')
      expect(replies.last).to eq('myapp/config/url = www.test.com')
    end
  end
end
