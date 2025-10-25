
module GameDig
  # Typed container for a normalized GameDig server response.
  #
  # @!attribute [rw] name
  #   @return [String] Server name.
  # @!attribute [rw] map
  #   @return [String] Current map.
  # @!attribute [rw] password
  #   @return [Boolean] Whether the server is password protected.
  # @!attribute [rw] num_players
  #   @return [Integer] Number of players currently on the server.
  # @!attribute [rw] max_players
  #   @return [Integer] Maximum number of players allowed on the server.
  # @!attribute [rw] players
  #   @return [Array<Hash>] List of players currently on the server.
  # @!attribute [rw] bots
  #   @return [Array<Hash>] List of bots currently on the server.
  # @!attribute [rw] connect
  #   @return [String] Connection string (IP:port) for the server.
  # @!attribute [rw] ping
  #   @return [Integer] Ping time to the server in milliseconds.
  # @!attribute [rw] query_port
  #   @return [Integer] Query port used to query the server.
  # @!attribute [rw] version
  #   @return [String] Server version string.
  # @!attribute [rw] raw
  #   @return [Hash{String=>Object}] Raw response data from the server.
  class QueryResult
    attr_accessor :name, :map, :password, :num_players, :max_players, :players, :bots,
                  :connect, :ping, :query_port, :version, :raw

    def initialize(hash)
      @name        = hash['name']
      @map         = hash['map']
      @password    = hash['password']
      @num_players = hash['num_players']
      @max_players = hash['max_players']
      @players     = hash['players'] || []
      @bots        = hash['bots'] || []
      @connect     = hash['connect']
      @ping        = hash['ping']
      @query_port  = hash['query_port']
      @version     = hash['version']
      @raw         = hash['raw'] || {}
    end

    # Convenience: turn back into plain Hash.
    # @return [Hash{String=>Object}]
    def to_h
      {
        'name' => @name,
        'map' => @map,
        'password' => @password,
        'num_players' => @num_players,
        'max_players' => @max_players,
        'players' => @players,
        'bots' => @bots,
        'connect' => @connect,
        'ping' => @ping,
        'query_port' => @query_port,
        'version' => @version,
        'raw' => @raw
      }
    end

    def to_json
      to_h.to_json
    end
  end
end
