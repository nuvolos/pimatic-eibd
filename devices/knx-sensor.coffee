module.exports = (env) ->
  Promise = env.require 'bluebird'
  _ = env.require 'lodash'

  class KnxSensor extends env.devices.Sensor
    _value: undefined

    attributes:
      value:
        description: "The measured value"
        type: "number"
        unit: ''
        acronym: ''

    template: "temperature"

    constructor: (config, @plug, lastState, moreConfig) ->
      @config = _.cloneDeep config
      _.extend @config, moreConfig || {}

      @attributes.value.unit = @config.unit
      @attributes.value.acronym = @config.acronym || @config.magnitude || ""

      @_value = lastState?.state?.value or 0
      @name = @config.name
      @id   = @config.id


      @zone = @plug.zm.zone (@config.zoneid or @config.zone)

      @statusGad  = @zone.registerGAD @config.status, @config.dpt

      if @config.poll
        setInterval @_readSensor, @config.poll

      @statusGad.on 'set', (val) =>
        @_setValue val/@config.scale
      super()

    _setValue: (val) =>
      return if @_value == val
      @_value = val
      emit 'value', val

    destroy: () =>
      super()


    getValue: () =>
      @statusGad.request()
      Promise.resolve @_value
