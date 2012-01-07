require 'date'
require 'time'
require 'nokogiri'

module SmarterMeter
  # Represents a collection of samples. In some cases it's useful to operate on
  # groups of samples and this class provides that functionality.
  class Samples < Hash
    # Parses the XML returned by PG&E and creates a Samples collection.
    #
    # @param [String] data the string containing the XML returned by PG&E
    # @return [Samples] creates a Samples collection from the given data.
    def self.parse_espi(data)
      samples = Samples.new

      doc = Nokogiri::HTML(data)

      doc.xpath("//intervalreading").each do |reading|
        # NOTE: This is a hack, the ESPI data seems to be assuming that
        # all users live in the Eastern Time Zone. The timestamps
        # returned in the ESPI should really be in UTC and not in local
        # time. I'm going to assume all PG&E customers are in the
        # pacific timezone and since the eastern timezone has the same
        # daylight savings time rules then we can use a constant
        # difference to correct the problem.
        pacific_timezone_correction = 60*60*3

        timestamp = Time.at(reading.xpath("./timeperiod/start").first.content.to_i + pacific_timezone_correction)
        value = reading.xpath("./value").first.content.to_i / 900.0

        year = timestamp.year
        month = timestamp.month
        day = timestamp.day

        (samples[Date.new(year, month, day)] ||= []) << Sample.new(timestamp, value)
      end

      samples
    end

    # Calculates the total number of kilowatt hours for all samples.
    #
    # @return [Float] the sum of kilowatt hours for all samples within this collection. If no samples are found 0 is  returned.
    def total_kwh
      self.keys.reduce(0) { |sum, d| sum + total_kwh_on(d) }
    end

    # Calculates the total number of kilowatt hours
    #
    # @param [Date] date The date of the samples to include within the total.
    #
    # @return [Float] the sum of kilowatt hours for samples made of the given day. If none are found 0 is returned.
    def total_kwh_on(date)
      if self[date]
        self[date].reduce(0) { |sum, s| sum + (s.kwh or 0) }
      else
        0
      end
    end
  end
end
