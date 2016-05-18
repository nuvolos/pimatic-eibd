module.exports = (env) ->
  Promise = env.require 'bluebird'
  _ = env.require 'lodash'

  class KnxDimmer extends env.devices.DimmerActuator
    constructor: (@config, @plug, lastState) ->
      @_state = lastState?.state?.value or off
      @name = @config.name
      @id   = @config.id
      @zone = @plug.zm.zone (@config.zoneid or @config.zone)
      @gads = {}
      @gads.all     = @zone.registerGAD @config.gads.set, "DPT1"
      @gads.precise = @zone.registerGAD @config.gads.setPrecise, "DPT5"
      if @config.gads.get
        @gads.state = @zone.registerGAD @config.gads.get, "DPT5"
        @gads.events = @gads.state
      else
        @gads.events = @gads.precise

      @gads.events.on 'set', (val) =>
        value = val/255 * 100
        @_setDimlevel value
      super()

    destroy: () =>
      super()

    changeDimlevelTo: (level) =>
      val = level/100 * 255
      @gads.precise.write val
      Promise.resolve()

    changeStateTo: (state) =>
      if @gads.all
        val = 0
        val = 1  if state
        @gads.all.write val
        Promise.resolve()
      else
        super()

    getState: () =>
      @gads.events.request()
      super()

    getDimLevel: () =>
      @gads.events.request()
      super()
