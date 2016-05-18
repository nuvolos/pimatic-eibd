eibd = require 'eibd'

module.exports = (env) ->
  Promise      = env.require 'bluebird'
  assert       = env.require 'cassert'
  EventEmitter = env.require 'events'

  setMyTimeout = (tout, f) =>
    setTimeout f, tout

  # A zone establishes a connection with the eibd server,
  # emitting events whenever a telegram is seen.

  # It can create GADs to which telegrams can be sent and
  # events can be received.
  #
  class Zone extends EventEmitter
    constructor: (@zone) ->
      console.log @zone
      @connection = new eibd.Connection()
      @connection.on 'close', () =>
        setMyTimeout 100, @_openConnection
      @_openConnection()

    registerGAD: (gad, dpt) =>
      new GAD this, gad, dpt

    send: (address, action, value, dpt, callback) =>
      callback = value if action == 'read'
      callback = (() => ) unless callback
      conn = new eibd.Connection()
      conn.socketRemote @zone, () =>
        conn.openTGroup address, 0, (err) =>
          if (err)
            callback err
            return
          if action == 'read'
            msg = eibd.createMessage action, dpt, parseFloat value
          else
            msg = eibd.createMessage action, dpt, parseFloat value
          conn.sendAPDU msg, callback

    _openConnection: () =>
      @connection.socketRemote @zone, () =>
        @connection.openGroupSocket 0, (parser) =>
          parser.on 'response', @_handleDgram 'response'
          parser.on 'write', @_handleDgram 'write'
          parser.on 'read', @_handleDgram 'read'

    _handleDgram: (action) =>
      if action == 'read'
        (src, dst) =>
          @emit dst, action
          @emit 'dgram', dst, action
      else
        (src, dst, typ, val) =>
          @emit dst, action, val
          @emit 'dgram', dst, action, val

  class GAD extends EventEmitter
    constructor: (@zone, @gad, @dpt) ->
      @address = eibd.str2addr @gad
      @zone.on @gad, (action, value) =>
        if action == "response" or action == "write"
          @emit "set", value
        else
          @emit "get"
    respond: (value) =>
      @zone.send @address, 'respond', value, @dpt

    write: (value) =>
      @zone.send @address, 'write', value, @dpt

    request: () =>
      @zone.send @address, 'read'


  class ZoneManager
    constructor: (@opts, @plugin) ->
      @_zones = []
      for z in @opts
        nz = new Zone z
        @_zones.push nz
        @_zones[z.id] = nz if z.id
    zone: (i) =>
      @_zones[i]
