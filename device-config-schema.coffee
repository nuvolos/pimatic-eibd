# pymatic-eibd configuration options
#
module.exports =
  title: "knx device configuration"
  Common:
    description: "Common properties for all knx devices"
    type: "object"
    properties:
      zone:
        description: "Index of the zone this device is in."
        type: "number"
        default: 0
      zoneid:
        description: "Nominal id of the zone this device is on. Has priority over the index"
        type: "string"
        required: false
  KnxPower:
    description: "Power switch device"
    type: "object"
    properties:
      gads:
        description: "Group address(es)"
        type: "object"
        properties:
          set:
            description: "GAD for setting the state of the device"
            type: "string"
          get:
            description: "GAD to observe the state of the device or read it"
            type: "string"
            required: false
  KnxDimmer:
    description: "Dimmer-like device"
    type: "object"
    properties:
      gads:
        description: "Group address(es)"
        type: "object"
        properties:
          set:
            description: "GAD for powering fully up/down"
            type: "string"
            required: false
          get:
            description: "GAD to observe the state of the device"
            type: "string"
          setPrecise:
            description: "GAD to set the precise lightness"
            type: "string"
          step:
            description: "GAD to stop progression, take a small step"
            type: "string"
            required: false
  KnxShutter:
    description: "Shutter-like device"
    type: "object"
    properties:
      timeout:
        description: "Max time in seconds to completely close/open"
        type: "number"
        default: 120
      gads:
        description: "Group address(es)"
        type: "object"
        properties:
          move:
            description: "GAD for powering fully up/down"
            type: "string"
          status:
            description: "GAD to observe the position of the shutter"
            type: "string"
            required: false
          precise:
            description: "GAD to set the precise position"
            type: "string"
            required: false
          stop:
            description: "GAD to stop progression, take a small step"
            type: "string"
          step:
            description: "GAD to take a small step"
            type: "string"
            required: false
  KnxSensor:
    description: "Arbitrary sensor, reporting its readings periodically, or by polling"
    type: "object"
    properties:
      dpt:
        description: "KNX type in which the measurement is encoded"
        type: "string"
        default: "DPT1"
      status:
        description: "GAD where the sensor writes the reading"
        type: "string"
      magnitude:
        description: "What physical magnitude is this a measure of"
        type: "string"
      unit:
        description: "Unit in which the sensor measures the physical magnitude"
        type: "string"
      presentationUnit:
        description: "Unit in which the sensed magnitude is to be shown"
        type: "string"
        required: false
      acronym:
        description: "Acronym for the magnitude"
        type: "string"
        required: false
      poll:
        description: "Poll interval. 0 == no polling"
        type: "number"
        default: 0
  KnxTemperature: # a special case of value sensor
    description: "A temperature sensor with DPT9"
    type: "object"
    properties:
      status:
        description: "GAD where the sensor writes the temperature"
        type: "string"
      poll:
        description: "polling period. No polling if 0"
        type: "number"
        default: 0
      unit:
        description: "Units in which temperature is captured by the sensor"
        type: "string"
        default: "C"
      presentationUnit:
        description: "Units in which temperature is to be shown"
        type: "string"
        required: false
  KnxDateTime: # clock syncing in the installation
    description: "Clocks & calendars with DPT10 and DPT11 respectively"
    type: "object"
    properties:
      rate:
        description: "seconds between updates"
        type: "number"
        default: 10
      gads:
        description: "Group address(es)"
        type: "object"
        properties:
          setTime:
            description: "GAD where the time is written"
            type: "string"
          setDate:
            description: "GAD where the date is written"
            type: "string"
  KnxTrigger:
    description: "a sensor, producing pulse events. The state cannot be read"
    properties:
      dpt:
        description: "Type of the event"
        type: "string"
        default: "DPT1"
      status:
        description: "GAD where the event is posted"
        type: "string"
