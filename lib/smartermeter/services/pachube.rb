require 'net/https'

module SmarterMeter
  module Services
    class Pachube
      def initialize(config)
        @config = config
        raise "The Pachube token must be configured" unless @config[:api_key]
        raise "The Pachube feed id must be configured" unless @config[:feed_id]
        raise "The Pachube datastream id must be configured" unless @config[:datastream_id]
      end

      # Public: Uploads an array of Samples to Google PowerMeter
      #
      # samples - An array of samples to upload
      #
      # Returns true on success and false otherwise
      def upload(samples)
        url = URI.parse("https://api.pachube.com/v2/feeds/#{@config[:feed_id]}/datastreams/#{@config[:datastream_id]}/datapoints.csv")
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.ca_file = File.join(File.dirname(__FILE__), "cacert.pem")
        res, body = http.post(url.path, request_body(samples), {"X-PachubeApiKey" => @config[:api_key], "Content-Type" => "text/csv"})
        case res
        when Net::HTTPSuccess
          true
        else
          false
        end
      end

      # Creates the proper XML request to send to Google.
      #
      # Returns the proper atom/xml response to send to google
      def request_body(samples)
        template = ERB.new(File.read(File.join(File.dirname(__FILE__), "pachube.erb")))
        template.result(binding).gsub(/^\n/, '')
      end
    end
  end
end
