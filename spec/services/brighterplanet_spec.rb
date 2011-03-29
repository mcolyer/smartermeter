$:.unshift File.join(File.dirname(__FILE__), "..")
require 'spec_helper'

describe SmarterMeter::Services::BrighterPlanet do
  it "can determine kilograms of carbon produced from the number of killowatt hours" do
    VCR.use_cassette('brighterplanet', :record => :new_episodes) do
      subject.calculate_kg_carbon(1).should be_within(0.1).of(0.64)
    end
  end

  it "can query for electricity from a specific zipcode" do
    VCR.use_cassette('brighterplanet', :record => :new_episodes) do
      subject.calculate_kg_carbon(1, :zip_code => "94110").should be_within(0.1).of(0.34)
    end
  end

  it "can query for electricity on a specific date" do
    VCR.use_cassette('brighterplanet', :record => :new_episodes) do
      subject.calculate_kg_carbon(1, :date => "2011-03-29").should be_within(0.1).of(0.64)
    end
  end

  it "doesn't allow electricity queries to include keys other than those specified" do
    expect { subject.calculate_kg_carbon(1, :energy => 2) }.to raise_error(ArgumentError)
  end
end
