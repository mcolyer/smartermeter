$:.unshift File.join(File.dirname(__FILE__), "..")
require 'spec_helper'

describe SmarterMeter::Services::BrighterPlanet do
  it "can determine kilograms of carbon produced from the number of killowatt hours" do
    VCR.use_cassette('brighterplanet', :record => :new_episodes) do
      subject.calculate_kg_carbon(1).should be_within(0.1).of(7132.42)
    end
  end

  it "can query for electricity from a specific zipcode"
end
