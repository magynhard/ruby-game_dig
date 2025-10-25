require 'uri'
require 'net/http'

class GameDigHelper

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

  private

  #----------------------------------------------------------------------------------------------------

  def self.port_open?(ip, port, seconds = 0.5)
    # => checks if a port is open or not on a remote host
    Timeout::timeout(seconds) do
      begin
        TCPSocket.new(ip, port).close
        true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError
        false
      end
    end
  rescue Timeout::Error
    false
  end

  #----------------------------------------------------------------------------------------------------

end