# #Plugin template

# This is an plugin template and mini tutorial for creating pimatic plugins. It will explain the
# basics of how the plugin system works and how a plugin should look like.

# ##The plugin code

# Your plugin must export a single function, that takes one argument and returns a instance of
# your plugin class. The parameter is an envirement object containing all pimatic related functions
# and classes. See the [startup.coffee](http://sweetpi.de/pimatic/docs/startup.html) for details.
module.exports = (env) ->
  # ###require modules included in pimatic
  # To require modules that are included in pimatic use `env.require`. For available packages take
  # a look at the dependencies section in pimatics package.json

  # Require the  bluebird promise library
  Promise = env.require 'bluebird'
  # Require the [cassert library](https://github.com/rhoot/cassert).
  assert = env.require 'cassert'
  _      = env.require 'lodash'

  # Include you own depencies with nodes global require function:
  #
  #     someThing = require 'someThing'
  #
  ZoneManager = (require './zone-manager') env
  deviceTypes = {}

  for device in [
    'knx-power'
    'knx-shutter'
    'knx-dimmer'
    'knx-sensor'
    'knx-temperature'
    'knx-date-time'
  ]
    # convert kebap-case to camel-case notation with first character capitalized
    className = device.replace /(^[a-z])|(\-[a-z])/g, ($1) -> $1.toUpperCase().replace('-','')
    deviceTypes[className] = require('./devices/' + device)(env)

  # ###MyPlugin class
  # Create a class that extends the Plugin class and implements the following functions:
  class EibdPlugin extends env.plugins.Plugin

    # ####init()
    # The `init` function is called by the framework to ask your plugin to initialise.
    #
    # #####params:
    #  * `app` is the [express] instance the framework is using.
    #  * `framework` the framework itself
    #  * `config` the properties the user specified as config for your plugin in the `plugins`
    #     section of the config.json file
    #
    #
    init: (app, @framework, @config) =>
      env.framework.instance = @framework
      @zm = new ZoneManager (_.cloneDeep @config.zones), this
      deviceConfigDef = require "./device-config-schema"
      common = deviceConfigDef.Common.properties

      for dtname, dtclass of deviceTypes
        do (dtname, dtclass) =>
          confDef = _.cloneDeep deviceConfigDef[dtname]
          _.extend confDef.properties, _.cloneDeep common

          dclass =
            configDef: confDef
            createCallback: (config, lastState) =>
              new dtclass config, this, lastState

          @framework.deviceManager.registerDeviceClass dtname, dclass
  # ###Finally
  # Create a instance of my plugin and return it
  new EibdPlugin
