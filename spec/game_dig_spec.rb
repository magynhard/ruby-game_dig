require "spec_helper"
require "tempfile"

require_relative '../lib/game_dig'
require_relative 'mock/quake3_server'

RSpec.describe GameDig do
  it "has a version number" do
    expect(GameDig::VERSION).not_to be nil
  end
end

RSpec.describe GameDig::Helper, '#cli_installed?' do
  context 'check if the cli is installed' do
    it 'has an installed cli' do
      expect(GameDig::Helper.cli_installed?).to eql(true)
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
        expect(result["max_players"]).to eq(16)
        expect(result["players"]).to be_a(Array)
        expect(result["players"].length).to eq(3)
      end
    end

    it 'can extract valid content when debug is on at cli' do
      with_mock_quake3_server(port: 27966) do |server|
        ENV["GAMEDIG_MODE"] = 'cli'
        type = "q3a"
        host = "127.0.0.1"
        port = 27966

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
      with_mock_quake3_server(port: 27967) do |server|
        ENV["GAMEDIG_MODE"] = 'nodo'
        type = "q3a"
        host = "127.0.0.1"
        port = 27967

        result = GameDig.query type: type, host: host, port: port

        expect(result["name"]).to be_a(String)
        expect(result["name"]).to eq("Mock Quake3 Server")
        expect(result["map"]).to eq("q3dm17")
        expect(result["num_players"]).to eq(3)
        expect(result["max_players"]).to eq(16)
        expect(result["players"]).to be_a(Array)
        expect(result["players"].length).to eq(3)
      end
    end

    it 'has all parameters in snake_case for cli mode' do
      with_mock_quake3_server(port: 27968) do |server|
        ENV["GAMEDIG_MODE"] = 'cli'
        type = "q3a"
        host = "127.0.0.1"
        port = 27968

        result = GameDig.query type: type, host: host, port: port

        expect(result["query_port"]).to eq(27968)
        expect(result["queryPort"]).to eq(nil)
        expect(result["num_players"]).to eq(3)
        expect(result["numplayers"]).to eq(nil)
        expect(result["max_players"]).to eq(16)
        expect(result["maxplayers"]).to eq(nil)
      end
    end

    it 'has all parameters in snake_case for nodo mode' do
      require_relative '../lib/game_dig/nodo'
      with_mock_quake3_server(port: 27969) do |server|
        ENV["GAMEDIG_MODE"] = 'nodo'
        type = "q3a"
        host = "127.0.0.1"
        port = 27969

        result = GameDig.query type: type, host: host, port: port

        expect(result["query_port"]).to eq(27969)
        expect(result["queryPort"]).to eq(nil)
        expect(result["num_players"]).to eq(3)
        expect(result["numplayers"]).to eq(nil)
        expect(result["max_players"]).to eq(16)
        expect(result["maxplayers"]).to eq(nil)
      end
    end

    it 'raises an error for unsupported GAMEDIG_MODE' do
      ENV["GAMEDIG_MODE"] = 'unsupported_mode'
      expect {
        GameDig.query type: "q3a", host: "dummy", port: 12345
      }.to raise_error(RuntimeError, /Unsupported GAMEDIG_MODE: unsupported_mode/)
    end

    it 'raises an error when host is unreachable in CLI mode' do
      ENV["GAMEDIG_MODE"] = 'cli'
      expect {
        GameDig.query type: "q3a", host: "abc", port: 12345, max_retries: 1, socket_timeout: 1000, attempt_timeout: 1000
      }.to raise_error(GameDig::Error)
    end

    it 'raises an error when host is unreachable in Nodo mode' do
      require_relative '../lib/game_dig/nodo'
      ENV["GAMEDIG_MODE"] = 'nodo'
      expect {
        GameDig.query type: "q3a", host: "abc", port: 12345, max_retries: 1, socket_timeout: 1000, attempt_timeout: 1000
      }.to raise_error(GameDig::Error)
    end
  end
end
