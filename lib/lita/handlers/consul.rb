require "base64"

module Lita
  module Handlers
    class Consul < Handler

      config :consul_host
      config :consul_port

      route /^consul get ([a-zA-Z0-9\-\/_]+)/, :consul_get, command: true, help: {
        "consul get <key>" => "Return value for <key>"
      }

      def consul_get(response)
        key = response.matches.first.first

        begin
          resp = http.get("#{api_url}/kv/#{key}")
          obj = MultiJson.load(resp.body)
          unless obj[0]["Value"].nil?
            value = Base64.decode64(obj[0]["Value"])
            response.reply "#{key} = #{value}"
          else
            response.reply "#{key} = null"
          end
        rescue Faraday::ConnectionFailed=> e
          response.reply e.to_s
        end
      end

      private
      
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
