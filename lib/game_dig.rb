require 'mkmf'
require 'game_dig/version'
require_relative 'custom_errors/game_dig_error'
require_relative 'custom_errors/game_dig_cli_not_found'

#
# GameDig
#

module GameDig

  DEBUG_MESSAGE_END = 'Q#0 Query was successful'

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
    throw GameDigCliNotFound unless cli_installed?
    command = "gamedig --type #{type}"
    command += " --port #{port}" if port
    command += " --maxAttempts #{max_attempts}" if max_attempts
    command += " --socketTimeout #{socket_timeout}" if socket_timeout
    command += " --attemptTimeout #{attempt_timeout}" if attempt_timeout
    command += " --givenPortOnly" if given_port_only
    command += " --debug #{debug}" if debug
    command += " --requestRules" if request_rules
    command += " #{host}"
    puts command
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

  private

  #
  # Check if gamedig cli is installed globally
  #
  # @return [Boolean]
  def self.cli_installed?()
    !!(which 'gamedig')
  end

  #----------------------------------------------------------------------------------------------------

  def self.which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable?(exe) && !File.directory?(exe)
      end
    end
    nil
  end

  #----------------------------------------------------------------------------------------------------

end
