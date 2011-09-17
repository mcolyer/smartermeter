$:.unshift File.join(File.dirname(__FILE__), "..")
require 'spec_helper'

describe SmarterMeter::Services::Pachube do
  before(:each) do
    @subject = SmarterMeter::Services::Pachube.new(:api_key => "secret",
                                                   :feed_id => "1",
                                                   :datastream_id => "1")
    data = File.read(File.join($FIXTURES_DIR, 'data.csv'))
    @results = SmarterMeter::Samples.parse_csv(data)
  end

  it "can format a request for the API" do
    fixture_file = File.join(File.dirname(__FILE__), "..", "fixtures", "expected_pachube_request.csv")
    expected_result = File.read(fixture_file)

    samples = @results.values.first
    @subject.request_body(samples).should == expected_result
  end
end
