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
    constructor: (@zone, @index) ->
      @connection = new eibd.Connection()
      @connection.on 'close', () =>
        env.logger.warn "Lost daemon for zone #{@index}:#{@zone.id}. Retrying in 100 seconds."
        setMyTimeout 100000, @_openConnection
      @_openConnection()

    registerGAD: (gad, dpt) =>
      new GAD this, gad, dpt

    send: (address, action, value, dpt, callback) =>
      callback = value if action == 'read'
      callback = (() => ) unless callback
      conn = new eibd.Connection()
      conn.socketRemote @zone, (err) =>
        if err
          env.logger.error "Cannot send to gad in zone #{@index}:#{@zone.id}. Lost Datagram."
          return

        conn.openTGroup address, 0, (err) =>
          if (err)
            callback err
            return
          if action == 'read'
            msg = eibd.createMessage action, dpt, 0 # the value is inmaterial for a read
          else
            if (typeof value == "string")
              value = parseFloat value
            msg = eibd.createMessage action, dpt, value
          conn.sendAPDU msg, callback

    _openConnection: () =>
      @connection.socketRemote @zone, (err) =>
        if err
          return
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
        env.logger.info "Registering zone #{@_zones.length}:#{z.id}"
        nz = new Zone z, @_zones.length
        @_zones.push nz
        @_zones[z.id] = nz if z.id
    zone: (i) =>
      @_zones[i]
