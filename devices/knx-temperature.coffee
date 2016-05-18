module.exports = (env) ->
  Promise = env.require 'bluebird'
  _ = env.require 'lodash'

  class KnxTemperature extends env.devices.KnxSensor
    constructor: (config, plug, lastState) ->
      moreConfig =
        dpt: "DPT9"
        magnitude: "Temperature"
        acronym: "T"
        scale: 1
      super config, plug, lastState, moreConfig
