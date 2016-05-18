module.exports = (env) ->
  Promise = env.require 'bluebird'
  _ = env.require 'lodash'

  class KnxPower extends env.devices.PowerSwitch
    constructor: (@config, @plug, lastState) ->
      @_state = lastState?.state?.value or off
      @name = @config.name
      @id   = @config.id
      @zone = @plug.zm.zone (@config.zoneid or @config.zone)
      @writeGad  = @zone.registerGAD @config.gads.set, "DPT1"
      if @config.gads.get
        @statusGad = @zone.registerGAD @config.gads.get, "DPT1"
        @eventGad = @statusGad
      else
        @eventGad = @writeGad

      @eventGad.on 'set', (val) =>
        @_setState val ? on : off
      super()

    destroy: () =>
      super()

    changeStateTo: (state) =>
      val = 0
      val = 1 if state
      @writeGad.write val
      Promise.resolve()

    getState: () =>
      @eventGad.request()
      super()
