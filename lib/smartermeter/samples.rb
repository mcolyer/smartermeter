require 'date'
require 'time'

module SmarterMeter
  class Samples < Hash
    # Parses the CSV returned by PG&E
    #
    # data - The string containing the CSV returned by PG&E
    #
    # Returns a Hash of with keys as Date objects and values of Arrays of samples.
    def self.parse_csv(data)
      samples = Samples.new
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

    # Public: Calculates the total number of kilowatt hours
    #
    # Returns a floating point number representing the sum of kilowatt hours
    #   for all samples within this collection. If no samples are found 0 is
    #   returned.
    def total_kwh
      self.keys.reduce(0) { |sum, d| sum + total_kwh_on(d) }
    end

    # Public: Calculates the total number of kilowatt hours
    #
    # date - The date of the samples to include within the total.
    #
    # Returns a floating point number representing the sum of kilowatt hours
    #   for samples made of the given day. If none are found 0 is returned.
    def total_kwh_on(date)
      if self[date]
        self[date].reduce(0) { |sum, s| sum + (s.kwh or 0) }
      else
        0
      end
    end
  end
end
