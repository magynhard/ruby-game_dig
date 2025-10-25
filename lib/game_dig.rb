require 'uri'
require 'net/http'
require 'json'

require_relative 'game_dig/version'
require_relative 'game_dig/helper'
require_relative 'game_dig/query_result'

require_relative 'custom_errors/error'
require_relative 'custom_errors/cli_not_found'

# Set default mode to 'cli' if not specified
ENV['GAMEDIG_MODE'] ||= 'cli'

#
# GameDig
#

module GameDig

  # When gamedig debug is enabled, this string marks the end of debug output and the beginning of JSON output
  DEBUG_MESSAGE_END = 'Q#0 Query was successful'

  #
  # Query a server for insight data.
  # Raises GameDig::Error on failure.
  #
  # 'type' and 'host' are required parameters, all others are optional.
  #
  # @param [String] type One of the game type IDs listed in the games list: https://github.com/gamedig/node-gamedig/blob/master/GAMES_LIST.md Or you can use protocol-[name] to select a specific protocol. Protocols are listed here: https://github.com/gamedig/node-gamedig/blob/master/protocols/index.js
  # @param [String] host The hostname or IP address of the server to query
  # @param [String] address=nil Override the IP address of the server skipping DNS resolution. When set, host will not be resolved, instead address will be connected to. However, some protocols still use host for other reasons e.g. as part of the query.
  # @param [Number] port Connection port or query port for the game server. Some games utilize a separate "query" port. If specifying the game port does not seem to work as expected, passing in this query port may work instead.
  # @param [Number] max_retries=1 Number of retries to query server in case of failure. Note that this amount multiplies with the number of attempts.
  # @param [Number] socket_timeout=2000 Milliseconds to wait for a single packet. Beware that increasing this will cause many queries to take longer even if the server is online.
  # @param [Number] attempt_timeout=10000 Milliseconds allowed for an entire query attempt (including socket_timeout, beware that if this value is smaller (or even equal) to the socket one, the query will always fail).
  # @param [Boolean] given_port_only=false Only attempt to query server on given port. Causes any default ports, port offsets or cached ports to be ignored.
  # @param [String] ip_family=0 IP family/version returned when looking up hostnames via DNS, can be 0 (IPv4 and IPv6), 4 (IPv4 only) or 6 (IPv6 only).
  # @param [Boolean] debug=true Enables massive amounts of debug logging to stdout.
  # @param [Boolean] request_rules=false Valve games only. Additional 'rules' may be fetched into the 'raw' key.
  # @param [Boolean] request_players=true Valve games only. Disable this if you don't want to fetch players data.
  # @param [Boolean] request_rules_required=false Valve games only. 'request_rules' is always required to have a response or the query will timeout.
  # @param [Boolean] request_players_required=false Valve games only. Querying players is always required to have a response or the query will timeout. Some games may not provide a players response.
  # @param [Boolean] strip_colors=true Enables stripping colors for protocols: unreal2, savage2, quake3, nadeo, gamespy2, doom3, armagetron.
  # @param [Boolean] port_cache=true After you queried a server, the second time you query that exact server (identified by specified ip and port), first add an attempt to query with the last successful port.
  # @param [Boolean] no_breadth_order=false Enable the behaviour of retrying an attempt X times followed by the next attempt X times, otherwise try attempt A, then B, then A, then B until reaching the X retry count of each.
  # @param [Boolean] check_old_ids=false Also checks the old ids amongst the current ones.
  # @return [GameDig::QueryResult] The response data from the server.
  #
  def self.query(type:, host:, address: nil, port: nil, max_retries: nil, socket_timeout: nil, attempt_timeout: nil, given_port_only: nil, ip_family: nil, debug: nil, request_rules: nil, request_players: nil, request_rules_required: nil, request_players_required: nil, strip_colors: nil, port_cache: nil, no_breadth_order: nil, check_old_ids: nil)
    result = if ENV['GAMEDIG_MODE'] == 'cli'
      perform_cli_query(type: type, host: host, address: address, port: port, max_retries: max_retries, socket_timeout: socket_timeout, attempt_timeout: attempt_timeout, given_port_only: given_port_only, ip_family: ip_family, debug: debug, request_rules: request_rules, request_players: request_players, request_rules_required: request_rules_required, request_players_required: request_players_required, strip_colors: strip_colors, port_cache: port_cache, no_breadth_order: no_breadth_order, check_old_ids: check_old_ids)
    elsif ENV['GAMEDIG_MODE'] == 'nodo'
      perform_nodo_query(type: type, host: host, address: address, port: port, max_retries: max_retries, socket_timeout: socket_timeout, attempt_timeout: attempt_timeout, given_port_only: given_port_only, ip_family: ip_family, debug: debug, request_rules: request_rules, request_players: request_players, request_rules_required: request_rules_required, request_players_required: request_players_required, strip_colors: strip_colors, port_cache: port_cache, no_breadth_order: no_breadth_order, check_old_ids: check_old_ids)
    else
      raise "Unsupported GAMEDIG_MODE: #{ENV['GAMEDIG_MODE']}. Supported modes are 'cli' and 'nodo'."
    end
    GameDig::QueryResult.new(result)
  end

  #----------------------------------------------------------------------------------------------------

  private

  #----------------------------------------------------------------------------------------------------

  def self.perform_cli_query(type:, host:, address: nil, port: nil, max_retries: nil, socket_timeout: nil, attempt_timeout: nil, given_port_only: nil, ip_family: nil, debug: nil, request_rules: nil, request_players: nil, request_rules_required: nil, request_players_required: nil, strip_colors: nil, port_cache: nil, no_breadth_order: nil, check_old_ids: nil)
    throw GameDig::CliNotFound unless GameDig::Helper.cli_installed?
    command = "gamedig --type #{type}"
    command += " --port #{port}" if port
    command += " --address #{address}" if address
    command += " --maxRetries #{max_retries}" if max_retries
    command += " --socketTimeout #{socket_timeout}" if socket_timeout
    command += " --attemptTimeout #{attempt_timeout}" if attempt_timeout
    command += " --givenPortOnly" if given_port_only
    command += " --ipFamily #{ip_family}" if ip_family
    command += " --debug #{debug}" if debug
    command += " --requestRules" if request_rules
    command += " --requestPlayers" if request_players
    command += " --requestRulesRequired" if request_rules_required
    command += " --requestPlayersRequired" if request_players_required
    command += " --stripColors" if strip_colors
    command += " --portCache" if port_cache
    command += " --noBreadthOrder" if no_breadth_order
    command += " --checkOldIDs" if check_old_ids
    command += " #{host}"
    begin
      output = `#{command}`
      json = if debug
               output.split(DEBUG_MESSAGE_END).last
             else
               output
             end
      response = JSON.parse json
      if debug
        response['debug'] = output[0...(output.index(DEBUG_MESSAGE_END) + DEBUG_MESSAGE_END.size)]
      end
      if response['error']
        raise GameDig::Error.new response['error']
      end
      normalize_response response
    rescue => e
      raise e
    end
  end

  def self.perform_nodo_query(type:, host:, address: nil, port: nil, max_retries: nil, socket_timeout: nil, attempt_timeout: nil, given_port_only: nil, ip_family: nil, debug: nil, request_rules: nil, request_players: nil, request_rules_required: nil, request_players_required: nil, strip_colors: nil, port_cache: nil, no_breadth_order: nil, check_old_ids: nil)
    result = GameDig::Nodo.query(type, host, address, port, max_retries, socket_timeout, attempt_timeout, given_port_only, ip_family, debug, request_rules, request_players, request_rules_required, request_players_required, strip_colors, port_cache, no_breadth_order, check_old_ids)
    normalize_response result
  end

  def self.normalize_response(response)
    response["query_port"] = response.delete("queryPort") if response.key?("queryPort")
    response["max_players"] = response.delete("maxplayers").to_i if response.key?("maxplayers")
    response["num_players"] = response.delete("numplayers").to_i if response.key?("numplayers")
    response
  end

end
