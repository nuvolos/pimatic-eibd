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
        dpt: "DPT9"
        magnitude: "Temperature"
        acronym: "T"
      super @config, plug, lastState

    _visualizeUnit: (unit) =>
      "º#{unit}"

    # Temperature is sotred as degrees Kelvin
    _toInternal: (value) =>
      unit = @superConfig.unit
      if unit == "F"
        (value + 459.67) * 5/9
      else if unit == "R"
        value * 5/9
      else if unit == "C"
        value + 273.15
      else
        assert unit == "K", "Unknown temperature unit: #{unit}"
        value

    _toExternal: (value) =>
      unit = @superConfig.presentationUnit
      if unit == "F"
        value * 9/5 - 459.67
      else if unit == "R"
        value * 9/5
      else if unit == "C"
        value - 273.15
      else
        assert unit == "K", "Unknown temperature unit: " + unit
        value
