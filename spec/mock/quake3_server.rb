require 'socket'
require 'thread'

#
# MockQuake3Server
#
# A mock Quake3 server that responds to getstatus queries
# for testing purposes
#
class MockQuake3Server
  attr_reader :port, :running

  GETSTATUS_REQUEST = "\xFF\xFF\xFF\xFFgetstatus".force_encoding('ASCII-8BIT')
  STATUSRESPONSE_PREFIX = "\xFF\xFF\xFF\xFFstatusResponse\n".force_encoding('ASCII-8BIT')

  def initialize(port: 27960)
    @port = port
    @running = false
    @socket = nil
    @thread = nil
    @server_info = {
      'sv_hostname' => 'Mock Quake3 Server',
      'mapname' => 'q3dm17',
      'g_gametype' => '0',
      'sv_maxclients' => 16,  # Numeric value
      'sv_privateClients' => 0,
      'gamename' => 'baseq3',
      'protocol' => 68,
      'version' => 'Q3 1.32c linux-i386'
    }
    @players = [
      { name: 'Player1', score: 25, ping: 50 },
      { name: 'Player2', score: 15, ping: 75 },
      { name: 'Player3', score: 10, ping: 100 }
    ]
  end

  def start
    return if @running

    @socket = UDPSocket.new
    @socket.bind('127.0.0.1', @port)
    @running = true

    @thread = Thread.new do
      while @running
        begin
          data, addr = @socket.recvfrom(1024)
          puts "Received #{data.bytesize} bytes from #{addr[3]}:#{addr[1]}" if ENV['DEBUG']
          handle_request(data, addr)
        rescue => e
          puts "Error in mock server: #{e.message}" unless e.is_a?(IOError)
          puts e.backtrace.first(5).join("\n") if ENV['DEBUG']
        end
      end
    end

    # Give the server a moment to start
    sleep 0.1
    puts "Mock Quake3 Server started on port #{@port}"
  end

  def stop
    return unless @running

    @running = false
    @socket.close if @socket
    @thread.join if @thread
    puts "Mock Quake3 Server stopped"
  end

  def set_server_info(info)
    @server_info.merge!(info)
  end

  def set_players(players)
    @players = players
  end

  def add_player(name:, score: 0, ping: 0)
    @players << { name: name, score: score, ping: ping }
  end

  def clear_players
    @players = []
  end

  private

  def handle_request(data, addr)
    data = data.force_encoding('ASCII-8BIT')
    puts "Received request: #{data.inspect}" if ENV['DEBUG']
    if data.start_with?(GETSTATUS_REQUEST)
      response = build_status_response
      puts "Sending response (#{response.bytesize} bytes): #{response[0..100].inspect}..." if ENV['DEBUG']
      @socket.send(response, 0, addr[3], addr[1])
      puts "Response sent to #{addr[3]}:#{addr[1]}" if ENV['DEBUG']
    else
      puts "Unknown request type" if ENV['DEBUG']
    end
  end

  def build_status_response
    parts = []
    parts << STATUSRESPONSE_PREFIX

    # Build server info string (key\value pairs)
    @server_info.each do |key, value|
      parts << "\\#{key}\\#{value}"
    end
    parts << "\n"

    # Build player info (score ping "name")
    @players.each do |player|
      parts << "#{player[:score]} #{player[:ping]} \"#{player[:name]}\"\n"
    end

    parts.join.force_encoding('ASCII-8BIT')
  end
end

# Helper method to run the server in tests
def with_mock_quake3_server(port: 27960, **options)
  server = MockQuake3Server.new(port: port)

  # Apply custom server info if provided
  server.set_server_info(options[:server_info]) if options[:server_info]
  server.set_players(options[:players]) if options[:players]

  server.start
  begin
    yield server
  ensure
    server.stop
  end
end

