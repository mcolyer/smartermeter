require 'date'
require 'time'
require 'nokogiri'

module SmarterMeter
  # Represents a collection of samples. In some cases it's useful to operate on
  # groups of samples and this class provides that functionality.
  class Samples < Array
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

        samples << Sample.new(timestamp, value)
      end

      samples
    end

    # Calculates the total number of kilowatt hours for all samples.
    #
    # @return [Float] the sum of kilowatt hours for all samples within this collection. If no samples are found 0 is  returned.
    def total_kwh
      map { |s| s.kwh || 0 }.reduce(:+) || 0
    end

    # Selects all samples starting from the given time until 24 hours into the future.
    #
    # @param [DateTime] date_time The start date of the samples to include within the total.
    #
    # @return [Samples] a sample collection containing only the selected samples. If none are found, a samples object with no samples is returned.
    def on(date_time)
      start_time = date_time.to_time
      end_time = (date_time + 1).to_time
      Samples.new(select { |s| start_time <= s.time && s.time < end_time })
    end

    # Calculates the total number of kilowatt hours
    #
    # @param [DateTime] date_time The start date of the samples to include within the total.
    #
    # @return [Float] the sum of kilowatt hours for samples made of the given day. If none are found 0 is returned.
    def total_kwh_on(date_time)
      on(date_time).total_kwh
    end
  end
end
