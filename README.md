# lita-consul

[![Build Status](https://travis-ci.org/dpires/lita-consul.png?branch=master)](https://travis-ci.org/dpires/lita-consul)
[![Coverage Status](https://coveralls.io/repos/dpires/lita-consul/badge.svg?branch=master&service=github)](https://coveralls.io/github/dpires/lita-consul?branch=master)

**lita-consul** is a handler for [Lita](https://github.com/litaio/lita) for interacting with [Consul](https://github.com/hashicorp/consul).

## Installation

Add lita-consul to your Lita instance's Gemfile:

``` ruby
gem "lita-consul"
```

## Configuration

### Optional attributes

* `consul_host` (String) - Consul host. Default: `localhost`.
* `consul_port` (String) - Consul port. Default: `8500`.


## Usage

```
[You]: lita consul get foo 
[Lita]: foo = bar 
[You]: lita consul set mykey myvalue
[Lita]: mykey = myvalue
```

## License

[MIT](http://opensource.org/licenses/MIT)
