require "spec_helper"

RSpec.describe Sequel::Rake::Migrations do
  it "has a version number" do
    expect(Sequel::Rake::Migrations::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
