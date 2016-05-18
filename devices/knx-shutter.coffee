mySetTimeout = (tout, f) =>
  setTimeout f, tout

module.exports = (env) ->
  Promise = env.require 'bluebird'
  _ = env.require 'lodash'


  class KnxShutter extends env.devices.ShutterController

    constructor: (@config, @plug, lastState) ->
      @_position = lastState?.position?.value or 'stopped'
      @name = @config.name
      @id   = @config.id
      @zone = @plug.zm.zone (@config.zoneid or @config.zone)
      @gads = {}

      cgads = @config.gads
      @gads.move     = @zone.registerGAD cgads.move, "DPT1"
      @gads.precise  = @zone.registerGAD cgads.precise, "DPT5" if cgads.precise
      @gads.stop     = @zone.registerGAD cgads.stop, "DPT1"
      @gads.step     = @zone.registerGAD cgads.step, "DPT1"  if cgads.step
      console.log @config.timeout
      super()

    destroy: () =>
      super()
    stop: () =>
      @moveToPosition 'stopped'

    moveToPosition: (pos) =>
      if pos == 'stopped'
        @gads.stop.write 1
        op = @op
        @op = null
        clearTimeout op if op
      else
        val = if pos == 'up' then 0 else 1
        @gads.move.write val
        @op = setTimeout @stop, 1000 * parseFloat @config.timeout
      @_setPosition pos
      Promise.resolve()


    _setPrecisePosition: (pp) =>
