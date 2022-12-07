require "spec_helper"
require "tempfile"

RSpec.describe GameDig do
  it "has a version number" do
    expect(GameDig::VERSION).not_to be nil
  end
end

RSpec.describe GameDig, '#cli_installed?' do
  context 'check if the cli is installed' do
    it 'has an installed cli' do
      expect(GameDig.cli_installed?).to eql(true)
    end
  end
end
