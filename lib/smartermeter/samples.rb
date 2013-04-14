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
        timestamp = reading.xpath("./timeperiod/start").first.content.to_i
        timestamp = Time.at(timestamp).utc

        value = reading.xpath("./value").first.content.to_i / 900.0
        value = ((value * 100).truncate / 100.0)

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
        self[date].map { |s| s.kwh || 0 }.reduce(:+)
      else
        0
      end
    end
  end
end
