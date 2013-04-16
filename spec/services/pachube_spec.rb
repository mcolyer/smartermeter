$:.unshift File.join(File.dirname(__FILE__), "..")
require 'spec_helper'

describe SmarterMeter::Services::Pachube do
  before(:each) do
    @ui = mock("UI")
    @subject = SmarterMeter::Services::Pachube.new(@ui,
                                                   :api_key => "secret",
                                                   :feed_id => "1",
                                                   :datastream_id => "1")
    data = File.read(File.join($FIXTURES_DIR, 'data.xml'))
    @results = SmarterMeter::Samples.parse_espi(data)
  end

  it "can format a request for the API" do
    fixture_file = File.join(File.dirname(__FILE__), "..", "fixtures", "expected_pachube_request.csv")
    expected_result = File.read(fixture_file)

    samples = @results.on(DateTime.new(2013, 4, 9, 0, 0, 0, -7))
    @subject.request_body(samples).should == expected_result
  end
end
