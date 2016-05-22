mySetTimeout = (tout, f) =>
  setTimeout f, tout

module.exports = (env) ->
  Promise = env.require 'bluebird'
  _ = env.require 'lodash'


  class KnxShutter extends env.devices.ShutterController
    _aperture: 0

    attributes:
      position:
        label: "Position"
        description: "State of the shutter"
        type: "string"
        enum: ['up', 'down', 'stopped']
        acronym: "Status"
      aperture:
        label: "Precise Position"
        description: "Percentage open"
        type: "number"
        acronym: "Aperture"
        unit: "%"
    actions:
      moveUp:
        description: "Raise the shutter"
      moveDown:
        description: "Lower the shutter"
      stop:
        description: "Stops the shutter move"
      step:
        description: "Moves the shutter a small amount"
      moveToPosition:
        description: "Changes the shutter state"
        params:
          state:
            type: "string"
      setAperture:
        description: "Moves the shutter to a precise percentage aperture"
        params:
          aperture:
            type: "number"

    template: "shutter"

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

      if @gads.status
        @gads.status   = @zone.registerGAD cgads.status, "DPT5"
        @gads.status.on 'set', (val) =>
          val = val/255 * 100
          @_setAperture val

      super()

    destroy: () =>
      clearTimeout @op if @op
      super()
    stop: () =>
      @moveToPosition 'stopped'

    step: (dir) =>
      dir = if dir then 1 else 0
      @gads.step.write dir
      Promise.resolve()

    moveToPosition: (pos) =>
      if pos == 'stopped'
        value = if @_position == "up" then 1 else 0
        @gads.stop.write value
        op = @op
        @op = null
        clearTimeout op if op
      else
        val = if pos == 'up' then 0 else 1
        @gads.move.write val
        @op = setTimeout @stop, 1000 * parseFloat @config.timeout
      @_setPosition pos
      Promise.resolve()

    setAperture: (pos) =>
      pos = Number pos
      assert (pos >= 0 and pos <= 100)
      pos = Math.floor pos/100 * 255
      @gads.precise.write pos
      @_setAperture pos
      Promise.resolve()

    getAperture: () =>
      Promise.resolve @_aperture

    _setAperture: (ap) =>
      return if @_pPosition == ap
      @_aperture = pp
      emit 'aperture', pp
