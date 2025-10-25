require "nodo"

node_js_app_base_path = File.expand_path(File.dirname(__FILE__) + '/node/')
Nodo.modules_root = node_js_app_base_path + '/node_modules'
Nodo.logger = Logger.new(nil) # disable logging

module GameDig
  class Nodo < Nodo::Core
    require gamedig: "gamedig"

    #
    # instance wrapper method, as nodo does not support class methods
    #
    def self.query(type, host, address = nil, port = nil, max_retries = nil, socket_timeout = nil, attempt_timeout = nil, given_port_only = nil, ip_family = nil, debug = nil, request_rules = nil, request_players = nil, request_rules_required = nil, request_players_required = nil, strip_colors = nil, port_cache = nil, no_breadth_order = nil, check_old_ids = nil)
      begin
        self.new.query type, host, address, port, max_retries, socket_timeout, attempt_timeout, given_port_only, ip_family, debug, request_rules, request_players, request_rules_required, request_players_required, strip_colors, port_cache, no_breadth_order, check_old_ids
      rescue ::Nodo::JavaScriptError => e
        raise GameDig::Error.new "#{e.message}"
      end
    end

    function :query, <<~JS
    async (type, host, address, port, maxRetries, socketTimeout, attemptTimeout, givenPortOnly, ipFamily, debug, requestRules, requestPlayers, requestRulesRequired, requestPlayersRequired, stripColors, portCache, noBreadthOrder, checkOldIDs) => {
      let queryOptions = {};
      // required fields
      queryOptions.type = type;
      queryOptions.host = host;
      // add options only if they are provided
      if (port !== null && port !== undefined) queryOptions.port = port;
      if (maxRetries !== null && maxRetries !== undefined) queryOptions.maxRetries = maxRetries;
      if (socketTimeout !== null && socketTimeout !== undefined) queryOptions.socketTimeout = socketTimeout;
      if (attemptTimeout !== null && attemptTimeout !== undefined) queryOptions.attemptTimeout = attemptTimeout;
      if (givenPortOnly !== null && givenPortOnly !== undefined) queryOptions.givenPortOnly = givenPortOnly;
      if (ipFamily !== null && ipFamily !== undefined) queryOptions.ipFamily = ipFamily;
      if (debug !== null && debug !== undefined) queryOptions.debug = debug;
      if (requestRules !== null && requestRules !== undefined) queryOptions.requestRules = requestRules;
      if (requestPlayers !== null && requestPlayers !== undefined) queryOptions.requestPlayers = requestPlayers;
      if (requestRulesRequired !== null && requestRulesRequired !== undefined) queryOptions.requestRulesRequired = requestRulesRequired;
      if (requestPlayersRequired !== null && requestPlayersRequired !== undefined) queryOptions.requestPlayersRequired = requestPlayersRequired;
      if (stripColors !== null && stripColors !== undefined) queryOptions.stripColors = stripColors;
      if (portCache !== null && portCache !== undefined) queryOptions.portCache = portCache;
      if (noBreadthOrder !== null && noBreadthOrder !== undefined) queryOptions.noBreadthOrder = noBreadthOrder;
      if (checkOldIDs !== null && checkOldIDs !== undefined) queryOptions.checkOldIDs = checkOldIDs;
      const serverData = await gamedig.GameDig.query(queryOptions);
      return serverData;      
    }
  JS

  end
end

ENV["GAMEDIG_MODE"] = "nodo"

require_relative '../game_dig'