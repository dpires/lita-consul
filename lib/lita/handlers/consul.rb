require 'base64'

module Lita
  module Handlers
    class Consul < Handler
      config :consul_host
      config :consul_port

      route(
        %r{^consul\sget\s(?<key>[\w\-\/]+)},
        :consul_get,
        command: true,
        help: {
          t('help.get.syntax') => t('help.get.desc')
        }
      )

      route(
        %r{^consul\sset\s(?<key>[\w\-\/]+)\s(?<value>[\w\-\/]+)},
        :consul_set,
        command: true,
        help: {
          t('help.set.syntax') => t('help.set.desc')
        }
      )

      route(
        /^consul\smembers$/,
        :consul_members,
        command: true,
        help: {
          t('help.members.syntax') => t('help.members.desc')
        }
      )

      def consul_members(response)
        resp = http.get("#{api_url}/catalog/nodes")
        replies = []
        MultiJson.load(resp.body).each do |node|
          replies << "#{node['Node']} - #{node['Address']}"
        end
        response.reply replies.join("\n")
      rescue Faraday::ConnectionFailed => e
        response.reply e.message
      end

      def consul_get(response)
        key = response.match_data['key']
        value = get_key_value(key)
        response.reply "#{key} = #{value}"
      rescue Faraday::ConnectionFailed => e
        response.reply e.message
      end

      def consul_set(response)
        key = response.match_data['key']
        value = response.match_data['value']
        http.put("#{api_url}/kv/#{key}", value)
        value = get_key_value(key)
        response.reply "#{key} = #{value}"
      rescue Faraday::ConnectionFailed => e
        response.reply e.message
      end

      private

      def get_key_value(key)
        resp = http.get("#{api_url}/kv/#{key}")
        obj = MultiJson.load(resp.body)
        if obj[0]['Value'].nil?
          'null'
        else
          Base64.decode64(obj[0]['Value'])
        end
      end

      def api_url
        host = 'http://127.0.0.1'
        port = '8500'

        host = config.consul_host if config.consul_host
        port = config.consul_port if config.consul_port

        "#{host}:#{port}/v1"
      end

      Lita.register_handler(self)
    end
  end
end
