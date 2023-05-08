# GameDig for Ruby
[![Gem](https://img.shields.io/gem/v/game_dig?color=default&style=plastic&logo=ruby&logoColor=red)](https://rubygems.org/gems/game_dig)
![downloads](https://img.shields.io/gem/dt/game_dig?color=blue&style=plastic)
[![License: MIT](https://img.shields.io/badge/License-MIT-gold.svg?style=plastic&logo=mit)](LICENSE)

> Ruby wrapper gem for [node-gamedig](https://github.com/gamedig/node-gamedig).

Providing support to use the node cli or running a tiny webservice for faster responses.





# Contents

* [Installation](#installation)
* [Usage examples](#usage)
* [Documentation](#documentation)
* [Contributing](#contributing)




<a name="installation"></a>
## Installation
### Prerequisites
NodeJS or a compatible alternative is installed.

Then install the gamedig package with your favourite package manager globally, e.g. here with npm or yarn:

#### yarn
```
    yarn global add gamedig
```

#### npm
```
    npm install -g gamedig
```

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

You can use the basic cli wrapper or the tiny webservice instance.

### CLI wrapper

This will just run the gamedig cli and return its result.
```ruby
    require 'game_dig'
    data = GameDig.query(type: 'minecraft', host: 'my-server.example.com')
    p data
```

### Service wrapper (experimental, only did some testing on linux)

Only the following parameters are implemented for the service wrapper: `type, host, protocol` (version 0.1.0)

Behaves the same to the user, but runs a tiny node webservice in the background to avoid startup times when called more than one time.

```
your-ruby-app 
    --------> ruby-game_dig 
        --------> tiny node instance in a separate thread using gamedig node module
<----------------    
```

It needs only about half of the query time, but might be not as stable as it involves much more complexity. (about 10ms vs 20ms)

```ruby
    require 'game_dig/service'
    data = GameDig.query(type: 'minecraft', host: 'my-server.example.com')
    p data
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
