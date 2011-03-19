require 'date'
require 'time'

module SmarterMeter
  # Represents a single hourly sample taken from the PG&E hourly electricity
  # data. It's the most basic data unit of SmarterMeter.
  class Sample
    attr_accessor :time, :kwh

    # Creates a new Sample.
    #
    # @param [Time] time the start of the sample period.
    # @param [Float] kwh the number of killowatt hours used during the period of this sample.
    # @return [Sample] the new Sample.
    def initialize(time, kwh)
      @time = time
      @kwh = kwh
    end

    # The start time of this measurement in UTC.
    #
    # @return [String] the time in the format of 2011-01-06T09:00:00.000Z
    def utc_start_time
      @time.utc.strftime("%Y-%m-%dT%H:%M:%S.000Z")
    end

    # The stop time of this measurement in UTC. It's assumed to be 1 hour after
    # the start as that is the current resolution of PG&E's data.
    #
    # @return [String] the time in the format of 2011-01-06T09:00:00.000Z
    def utc_stop_time
      one_hour = 60*60
      (@time + one_hour).utc.strftime("%Y-%m-%dT%H:%M:%S.000Z")
    end

    # Interrogates the current state of the Sample.
    #
    # Returns [String] a compact representation of the Sample.
    def inspect
      "<Sample #{@time} #{@kwh}>"
    end
  end
end
