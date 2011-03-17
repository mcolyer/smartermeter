require 'restclient'
require 'json'
require 'erb'

module SmarterMeter
  module Services
    class BrighterPlanet
      attr_accessor :api_key

      def initialize
        yield self if block_given?
      end

      def calculate_kg_carbon(kwh)
        response = RestClient.get 'http://carbon.brighterplanet.com/electricity_uses.json', :energy => kwh
        JSON.parse(response.body)["emission"]
      end
    end
  end
end
