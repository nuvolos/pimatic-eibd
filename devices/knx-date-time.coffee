module.exports = (env) ->
  Promise = env.require 'bluebird'
  _ = env.require 'lodash'

  class KnxDateTime extends env.devices.Device
    constructor: (@config, @plug, lastState) ->
      @name     = @config.name
      @id       = @config.id
      @zone     = @plug.zm.zone (@config.zoneid or @config.zone)
      @rate     = @config.rate
      @timeGad  = @zone.registerGAD @config.gads.setTime, "DPT10"
      @dateGad  = @zone.registerGAD @config.gads.setDate, "DPT11"

      @job   = setInterval @pushTime, @rate * 1000
      super()

    destroy: () =>
      clearInterval @job if @job
      @job = undefined
      super()

    pushTime: () =>
      dt = new Date();
      @timeGad.write [dt.getDay() + 1, dt.getHours(), dt.getMinutes(), dt.getSeconds()]
      @dateGad.write [dt.getDate(), dt.getMonth() + 1, dt.getFullYear() % 100]

