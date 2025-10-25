require "spec_helper"
require "tempfile"

require_relative '../lib/game_dig'
require_relative 'mock/quake3_server'

RSpec.describe GameDig do
  it "has a version number" do
    expect(GameDig::VERSION).not_to be nil
  end
end

RSpec.describe GameDigHelper, '#cli_installed?' do
  context 'check if the cli is installed' do
    it 'has an installed cli' do
      expect(GameDigHelper.cli_installed?).to eql(true)
    end
  end
end

RSpec.describe GameDig, 'execution mode' do
  context 'check if the ENV is loaded correctly' do
    it 'has "cli" mode by default' do
      require_relative '../lib/game_dig'
      expect(ENV["GAMEDIG_MODE"]).to eql("cli")
    end
    it 'uses "nodo" mode when requiring via /nodo' do
      require_relative '../lib/game_dig/nodo'
      expect(ENV["GAMEDIG_MODE"]).to eql("nodo")
    end
  end
end

RSpec.describe GameDig, '#query' do
  context 'make query with mock server' do
    it 'can query mock server with cli' do
      with_mock_quake3_server(port: 27965) do |server|
        ENV["GAMEDIG_MODE"] = 'cli'
        type = "q3a"
        host = "127.0.0.1"
        port = 27965

        result = GameDig.query type: type, host: host, port: port

        expect(result["name"]).to be_a(String)
        expect(result["name"]).to eq("Mock Quake3 Server")
        expect(result["map"]).to eq("q3dm17")
        # gamedig CLI returns maxplayers as string, not number
        expect(result["maxplayers"].to_i).to eq(16)
        expect(result["players"]).to be_a(Array)
        expect(result["players"].length).to eq(3)
      end
    end

    it 'can extract valid content when debug is on at cli' do
      with_mock_quake3_server(port: 27965) do |server|
        ENV["GAMEDIG_MODE"] = 'cli'
        type = "q3a"
        host = "127.0.0.1"
        port = 27965

        result = GameDig.query type: type, host: host, port: port
        result2 = GameDig.query type: type, host: host, port: port, debug: true

        expect(result["name"]).to be_a(String)
        expect(result["name"]).to eq("Mock Quake3 Server")

        expect(result2["name"]).to be_a(String)
        expect(result2["name"]).to eq("Mock Quake3 Server")
      end
    end

    it 'can query mock server with nodo' do
      require_relative '../lib/game_dig/nodo'
      with_mock_quake3_server(port: 27966) do |server|
        ENV["GAMEDIG_MODE"] = 'nodo'
        type = "q3a"
        host = "127.0.0.1"
        port = 27966

        result = GameDig.query type: type, host: host, port: port

        expect(result["name"]).to be_a(String)
        expect(result["name"]).to eq("Mock Quake3 Server")
        expect(result["map"]).to eq("q3dm17")
        expect(result["maxplayers"]).to eq("16")
        expect(result["players"]).to be_a(Array)
        expect(result["players"].length).to eq(3)
      end
    end
  end
end
