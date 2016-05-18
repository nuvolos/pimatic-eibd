# #pimatic-johnny-five plugin config options
module.exports =
  title: "pimatic-eibd plugin config options"
  type: "object"
  properties:
    zones:
      description: "Zones"
      type: "array"
      default: []
      format: "table"
      items:
        type: "object"
        properties:
          id:
            type: "string"
            description: "A unique identifier used to reference a knx zone. Optional: can use the index"
            required: false
          port:
            description: "IP port number for eibd daemon"
            type: "number"
            default: 6720
          host:
            description: "IP or domain name of host where the daemon runs"
            type: "string"
