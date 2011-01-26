require 'date'
require 'time'

module SmarterMeter
  class Sample
    attr_accessor :time, :kwh

    # Parses the CSV returned by PG&E
    #
    # data - The string containing the CSV returned by PG&E
    #
    # Returns a Hash of with keys as Date objects and values of Arrays of samples.
    def self.parse_csv(data)
      samples = {}
      date_re = /([0-9]{1,2})\/([0-9]{1,2})\/([0-9]{4})/

      # Apparently they felt the need to put a = outside of the correct place
      data = data.gsub('=','')

      hour_increment = 60*60
      CSV.parse(data) do |row|
        next unless row.length > 0 and date_re.match row[0]

        month, day, year = date_re.match(row[0]).captures
        month = month.to_i
        day = day.to_i
        year = year.to_i

        timestamp = Time.local(year, month, day, 0) - hour_increment
        next if row[1].include? "$"
        hourly_samples = row[1..24].map do |v|
          if v == "-"
            kwh = nil
          else
            kwh = v.to_f
          end

          timestamp = timestamp + hour_increment
          Sample.new(timestamp, kwh)
        end
        samples[Date.new(year, month, day)] = hourly_samples
      end
      samples
    end

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
