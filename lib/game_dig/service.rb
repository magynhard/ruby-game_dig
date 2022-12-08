require 'uri'
require 'net/http'
require 'benchmark'

require_relative 'game_dig_helper'

node_js_app_base_path = File.expand_path(File.dirname(__FILE__) + '/../node/')
node_js_app_js_path = File.expand_path(node_js_app_base_path + '/gamedig-service.js')

unless Dir.exist?(node_js_app_base_path + '/node_modules')
  puts "GameDig Service: Install missing dependencies ..."
  if !!GameDigHelper.which('yarn')
    `cd "#{node_js_app_base_path}" && yarn install`
  elsif !!GameDigHelper.which('npm')
    `cd "#{node_js_app_base_path}" && npm install`
  else
    raise "Neither 'yarn' nor 'npm' found!"
  end
  puts "done"
end


unless GameDigHelper.node_service_running?
  node_js_thread = Thread.new do |t|
    system %Q(cd "#{node_js_app_base_path}" && node ./gamedig-service.js)
    at_exit do
      node_js_thread.exit
    end
  end
end

ENV['GAMEDIG_SERVICE'] = 'true'

at_exit do
  GameDigHelper.stop_node_service
end

require_relative '../game_dig'