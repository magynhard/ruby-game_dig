require 'uri'
require 'net/http'
require 'json'

require_relative 'game_dig/version'
require_relative 'game_dig/game_dig_helper'
require_relative 'custom_errors/game_dig_error'
require_relative 'custom_errors/game_dig_cli_not_found'

#
# GameDig
#

module GameDig

  DEBUG_MESSAGE_END = 'Q#0 Query was successful'
  @@node_service_up = false

  #----------------------------------------------------------------------------------------------------

  # Query a server for insight data
  #
  # @param [String] type
  # @param [String] host
  # @param [Number] port
  # @param [Number] max_attempts
  # @param [Number] socket_timeout
  # @param [Number] attempt_timeout
  # @param [Boolean] given_port_only
  # @param [Boolean] debug
  # @param [Boolean] request_rules
  def self.query(type:, host:, port: nil, max_attempts: nil, socket_timeout: nil, attempt_timeout: nil, given_port_only: nil, debug: nil, request_rules: nil)
    if ENV['GAMEDIG_SERVICE'] == 'true'
      perform_service_query(type: type, host: host, port: port, max_attempts: max_attempts, socket_timeout: socket_timeout, attempt_timeout: attempt_timeout, given_port_only: given_port_only, debug: debug, request_rules: request_rules)
    else
      perform_cli_query(type: type, host: host, port: port, max_attempts: max_attempts, socket_timeout: socket_timeout, attempt_timeout: attempt_timeout, given_port_only: given_port_only, debug: debug, request_rules: request_rules)
    end
  end

  #----------------------------------------------------------------------------------------------------

  private

  #----------------------------------------------------------------------------------------------------

  def self.perform_cli_query(type:, host:, port: nil, max_attempts: nil, socket_timeout: nil, attempt_timeout: nil, given_port_only: nil, debug: nil, request_rules: nil)
    throw GameDigCliNotFound unless GameDigHelper.cli_installed?
    command = "gamedig --type #{type}"
    command += " --port #{port}" if port
    command += " --maxAttempts #{max_attempts}" if max_attempts
    command += " --socketTimeout #{socket_timeout}" if socket_timeout
    command += " --attemptTimeout #{attempt_timeout}" if attempt_timeout
    command += " --givenPortOnly" if given_port_only
    command += " --debug #{debug}" if debug
    command += " --requestRules" if request_rules
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
        response['debug'] = output[0...(output.index(DEBUG_MESSAGE_END)+DEBUG_MESSAGE_END.size)]
      end
      if response['error']
        raise GameDigError.new response['error']
      end
      response
    rescue => e
      raise e
    end
  end

  #----------------------------------------------------------------------------------------------------

  def self.perform_service_query(type:, host:, port: nil, max_attempts: nil, socket_timeout: nil, attempt_timeout: nil, given_port_only: nil, debug: nil, request_rules: nil)
    ensure_node_service_is_up
    hostname = host
    hostname += ":#{port}" if port
    uri = URI("http://127.0.0.1:24445/#{type}/#{hostname}")
    res = Net::HTTP.get_response(uri)
    res.body
  end

  #----------------------------------------------------------------------------------------------------

  def self.ensure_node_service_is_up
    max_counter = 100
    counter = 0
    unless @@node_service_up
      loop do
        counter += 1
        if GameDigHelper.node_service_running?
          break
        elsif counter >= max_counter
          raise "Node gamedig service did not boot up properly ..."
          break
        end
        sleep 0.1
      end
      @@node_service_up = true
    end
  end

  #----------------------------------------------------------------------------------------------------

end
