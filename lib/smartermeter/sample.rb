require 'date'
require 'time'

module SmarterMeter
  class Sample
    attr_accessor :time, :kwh

    def initialize(time, kwh)
      @time = time
      @kwh = kwh
    end

    # Public: The start time of this measurement
    #
    # Returns the time in the format of 2011-01-06T09:00:00.000Z
    def utc_start_time
      @time.utc.strftime("%Y-%m-%dT%H:%M:%S.000Z")
    end

    # Public: The stop time of this measurement, it's assumed to be 1 hour after
    # the start.
    #
    # Returns the time in the format of 2011-01-06T09:00:00.000Z
    def utc_stop_time
      (@time + 60*60).utc.strftime("%Y-%m-%dT%H:%M:%S.000Z")
    end

    def inspect
      "<Sample #{@time} #{@kwh}>"
    end
  end
end
