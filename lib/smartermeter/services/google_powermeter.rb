require 'net/https'
require 'erb'

module SmarterMeter
  module Transports
    class GooglePowerMeter
      def initialize(config)
        @config = config
        raise "The Google PowerMeter token must be configured" unless @config[:token]
        raise "The Google PowerMeter variable must be configured" unless @config[:variable]
      end

      # Public: Uploads an array of Samples to Google PowerMeter
      #
      # samples - An array of samples to upload
      #
      # Returns true on success and false otherwise
      def upload(samples)
        url = URI.parse('https://www.google.com/powermeter/feeds/event')
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.ca_file = File.join(File.dirname(__FILE__), "cacert.pem")
        res, body = http.post(url.path, request_body(samples), {"Authorization" => 'AuthSub token="CMCc9puFFRDKivjpAhjgiZLuAg"', "Content-Type" => "application/atom+xml"})
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
        template = ERB.new(File.read(File.join(File.dirname(__FILE__), "google_powermeter.erb")))
        template.result(binding)
      end
    end
  end
end
