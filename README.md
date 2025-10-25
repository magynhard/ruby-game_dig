# GameDig for Ruby
[![Gem](https://img.shields.io/gem/v/game_dig?color=default&style=plastic&logo=ruby&logoColor=red)](https://rubygems.org/gems/game_dig)
![downloads](https://img.shields.io/gem/dt/game_dig?color=blue&style=plastic)
[![License: MIT](https://img.shields.io/badge/License-MIT-gold.svg?style=plastic&logo=mit)](LICENSE)

> Query game servers from Ruby powered by [node-gamedig](https://github.com/gamedig/node-gamedig). 

This is a Ruby wrapper gem for [node-gamedig](https://github.com/gamedig/node-gamedig), providing support to use the node cli or running a node process with [nodo](https://github.com/mtgrosser/nodo) for faster responses.





# Contents

* [Installation](#installation)
* [Usage examples](#usage)
* [Documentation](#documentation)
* [Contributing](#contributing)




<a name="installation"></a>
## Installation
### Prerequisites
For using the CLI variant, install the gamedig package with your favourite package manager globally, e.g. here with npm or yarn:

#### yarn
```
    yarn global add gamedig
```

#### npm
```
    npm install -g gamedig
```

For the nodo variant, NodeJS >= 22.x is installed and available via commandline (in PATH).


### Gem

Add this line to your application's Gemfile:

```ruby
gem 'game_dig'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install game_dig
    

<a name="usage"></a>
## Usage examples

You can use the basic cli wrapper or the nodo instance.

### CLI wrapper

This will just run the gamedig cli and return its result.
```ruby
    require 'game_dig'
    data = GameDig.query(type: 'minecraft', host: 'my-server.example.com')
    p data
```

### Nodo wrapper
This will start a node process in the background and communicate with it using the nodo gem.

As this prevents starting a new node process for each query, this is much faster for multiple queries.
```ruby
    require 'game_dig/nodo'
    data = GameDig.query(type: 'minecraft', host: 'my-server.example.com')
    p data
```

### Query parameters
You can pass all parameters supported by node-gamedig, checkout the [rubydoc for more details](https://www.rubydoc.info/gems/game_dig/GameDig).

Here an example with all parameters, the camelCase parameters are converted to snake_case in ruby:
```ruby
    require 'game_dig'
    data = GameDig.query(
      # mandatory parameters
      type: 'minecraft',
      host: 'my-server.example.com',
      # optional parameters
      address: '119.212.123.34', # overrides host and skips DNS lookup
      port: 25565, # optional, default depends on game type
      max_retries: 1, # number of retry attempts
      socket_timeout: 2000, 
      attempt_timeout: 10000,
      given_port_only: false,
      ip_family: 0,
      debug: false,
      request_rules: false,
      request_players: true,
      request_rules_required: false,
      request_players_required: false,
      strip_colors: true,
      port_cache: true,
      no_breadth_order: false,
      check_old_ids: false
    )
    p data
```

### Query response
The response is a ruby hash with the same structure as the original node-gamedig response,
but the key of `queryPort` is in snake_case `query_port` instead of camelCase. And the keys `numplayers` and `maxplayers` are `num_players` and `max_players` respectively.

The objects of `raw` and `bots` are untouched, as they may depend on the game type and are not modified by gamedig itself.

For example:
```ruby
{
  "name" => "My Minecraft Server",
  "map" => "world",
  "password" => false,
  "num_players" => 5,
  "max_players" => 20,
  "players" => [
    { "name" => "Player1", "raw" => {} },
    { "name" => "Player2", "raw" => {} },
  # ...
  ],
  "bots" => [
    { "name" => "Bot1", "raw" => {} },
    { "name" => "Bot2", "raw" => {} },
  # ...
  ],
  "connect" => "my-server.example.com:25565",
  "ping" => 45,
  "query_port" => 25565,
  "version" => "1.16.4",
  "raw" => {
    # ...
  }
}    
```

<a name="documentation"></a>
## Documentation
Check out the doc at RubyDoc:<br>
https://www.rubydoc.info/gems/game_dig


As this library is only a wrapper, checkout the original node-gamedig documentation:<br>
https://github.com/gamedig/node-gamedig


<a name="contributing"></a>
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/magynhard/ruby-game_dig. 

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## SEO keywords
ruby gamedig game-dig game_dig
