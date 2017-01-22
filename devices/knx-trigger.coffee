module.exports = (env) ->
  Promise = env.require 'bluebird'
  assert  = env.require 'cassert'
  _ = env.require 'lodash'


  class KnxTemperature extends env.devices.KnxSensor
    template: "temperature"

    # Note that @superConfig takes @config as its prototype. This avoids
    # polution of the config space, while, at the same time, accessing the
    # default parameters the framework makes available.
    constructor: (@config, plug, lastState) ->
      @superConfig = Object.create @config
      _.extend @superConfig,
        dpt: "DPT1"
        magnitude: "Presence"
        acronym: "Present"
      super @config, plug, lastState

    _visualizeUnit: (unit) =>
      " is #{unit}"

    _toInternal: (value) =>
      value

    _toExternal: (value) =>
      value
