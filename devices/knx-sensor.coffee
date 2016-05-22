module.exports = (env) ->
  Promise = env.require 'bluebird'
  assert  = env.require 'cassert'
  _ = env.require 'lodash'

  # Base class for different kinds of sensors.
  # As a generic sensor, it admits multiple configuration
  # settings that its subclasses will not expose, but will need to fill in
  # through their constructor.
  class KnxSensor extends env.devices.Sensor
    _value: undefined

    attributes:
      value:
        description: "The measured value"
        type: "number"
        unit: ''
        acronym: ''

    template: "device"

    # We use a @superConfig property to fill in all the settings of a KnxSensor
    # without polluting the configuration space of the actual sensor that was
    # created. This is due to the dual nature of the @config: it serves to pass
    # configuration parameters while, at the same time, it is used by the framework
    # to write them out to the config.json file.
    #
    # Note that a KnxSensor can be instantiated directly, and this is detected
    # by checking for the existence of @superConfig
    #
    constructor: (@config, @plug, lastState) ->
      @superConfig = @config unless @superConfig
      @superConfig.presentationUnit = @superConfig.unit unless @superConfig.presentationUnit

      @attributes.value.unit = @_visualizeUnit @superConfig.presentationUnit
      @attributes.value.acronym = @superConfig.acronym || @superConfig.magnitude || ""

      @_value = lastState?.value?.value or 0
      @name = @superConfig.name
      @id   = @superConfig.id

      @zone = @plug.zm.zone (@superConfig.zoneid or @superConfig.zone)

      @statusGad  = @zone.registerGAD @superConfig.status, @superConfig.dpt

      if @superConfig.poll
        @interval = setInterval @_pollSensor, @superConfig.poll

      @statusGad.on 'set', (val) =>
        @_setValue @_toInternal val

      super()

    _pollSensor: () =>
      @statusGad.request()

    _visualizeUnit: (unit) =>
      unit

    # The value is in the storage units.
    _setValue: (val) =>
      return if @_value == val
      @_value = val
      @emit 'value', @_toExternal val

    # Ought to be implemented by specializations
    # default implementation does only what is sensible in
    # one case.
    _toInternal: (val) =>
      val

    _toExternal: (val) =>
      assert @superConfig.unit == @superConfig.presentationUnit, "Must provide unit conversion"
      val
    destroy: () =>
      @statusGad.removeAllListeners()
      clearInterval @interval if @interval
      super()

    getValue: () =>
      @_pollSensor()
      Promise.resolve @_toExternal @_value

  env.devices.KnxSensor = KnxSensor
