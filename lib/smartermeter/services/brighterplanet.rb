require 'restclient'
require 'json'
require 'erb'

module SmarterMeter
  module Services
    # Allows users to calculate the carbon produced by their energy usage by
    # accessing the Brighter Planet CM1 Electricity API.
    #
    # More details can be found here:
    # http://carbon.brighterplanet.com/models/electricity_use
    #
    # Example:
    #   api = SmarterMeter::Services::BrighterPlanet.new
    #   puts api.calculate_kg_carbon(10.1)
    #
    # Prints:
    #   0.6460529833458619
    #
    class BrighterPlanet
      # The api key required for commericial access to the API. For more detail see:
      # http://carbon.brighterplanet.com/pricing
      attr_accessor :api_key

      # Initializes the Brigher Planet CM1 Electricity API.
      #
      # Example:
      #
      #   SmarterMeter::Services::BrighterPlanet.new do |c|
      #     c.api_key = "key"
      #   end
      #
      # @return [BrighterPlanet]
      def initialize
        yield self if block_given?
      end

      # Calculates the number of kilograms of carbon produced from the given
      # electrical energy usage.
      #
      # Note: this is an estimate and depends on many factors, to improve
      # accuracy include an optional zipcode of where this energy was consumed.
      #
      # @param [Float] kwh the number of kilowatt hours consumed.
      # @params [Hash] opts can include `:zip_code` to increase the accuracy of the estimate.
      # @return [Float] kilograms of carbon produced by this much energy.
      def calculate_kg_carbon(kwh, opts={})
        allowed_keys = [:zip_code]
        non_permitted_keys = opts.keys.reject { |k| allowed_keys.include? k }
        raise ArgumentError, "opts contains keys not found in #{allowed_keys}" unless non_permitted_keys.empty?

        params = {:energy => kwh}
        params.merge!(opts)
        response = RestClient.get 'http://carbon.brighterplanet.com/electricity_uses.json', :params => params
        JSON.parse(response.body)["emission"]
      end
    end
  end
end
