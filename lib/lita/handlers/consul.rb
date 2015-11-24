require "base64"

module Lita
  module Handlers
    class Consul < Handler

      config :consul_host
      config :consul_port

      route /^consul get ([a-zA-Z0-9\-\/_]+)/, :consul_get, command: true, help: {
        "consul get <key>" => "Return value for <key>"
      }

      route /^consul set ([a-zA-Z0-9\-\/_]+) ([a-zA-Z0-9\-\/_]+)/, :consul_set, command: true, help: {
        "consul set <key> <value>" => "Set <value> for <key>"
      }
  
      route /^consul members/, :consul_members, command: true, help: {
        "consul members" => "Return consul nodes"
      }

      def consul_members(response)
          begin
            resp = http.get("#{api_url}/catalog/nodes")
            replies = []
            MultiJson.load(resp.body).each do | node |
              replies << "#{node['Node']} - #{node['Address']}"
            end 
            response.reply replies.join("\n")
          rescue Faraday::ConnectionFailed => e
            response.reply e.message
          end
      end

      def consul_get(response)
        key = response.matches.first.first
        begin
          value = get_key_value(key)
          response.reply "#{key} = #{value}"
        rescue Faraday::ConnectionFailed => e
          response.reply e.message
        end
      end

      def consul_set(response)
        key = response.matches.first.first
        value = response.matches.first.last
        begin
          resp = http.put("#{api_url}/kv/#{key}", value)
          value = get_key_value(key)
          response.reply "#{key} = #{value}"
        rescue Faraday::ConnectionFailed => e
          response.reply e.message
        end
      end

      private

      def get_key_value(key)
          resp = http.get("#{api_url}/kv/#{key}")
          obj = MultiJson.load(resp.body)
          unless obj[0]["Value"].nil?
            value = Base64.decode64(obj[0]["Value"])
            "#{value}"
          else
            "null"
          end
      end
      
      def api_url
        host = "http://127.0.0.1"
        port = "8500" 
        
        host = config.consul_host if config.consul_host
        port = config.consul_port if config.consul_port

        "#{host}:#{port}/v1"
      end

      Lita.register_handler(self)
    end
  end
end
