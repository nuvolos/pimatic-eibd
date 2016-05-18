pimatic-eibd
=======================

`pimatic-eibd` is a pimatic plugin to interface wiht a knx bus through an eibd daemon that should be deployed somewhere reachable via IP.

The plugin can be configured with several zones (several eibd daemons) for cases where multi-building control is indicated.

The plugin is in a very early stage, and is not yet available from npm

## Dependencies

The only current dependency is with the [eibd](https://github.com/andreek/node-eibd) nodejs package, which implements communication with the [eibd](https://sourceforge.net/projects/bcusdk/) daemon from within node.

## Devices implemented

The following devices are currently implemented:
- Power devices (KnxPower)
- Dimmers (KnxDimmer)
- Shutters (KnxShutter)
- Generic Sensors (KnxSensor)
- Temperature Sensors (KnxTemperature)

The above classes have been implemented as subclasses of the corresponding pimatic classes, using their templates for visualization. More classes (presence, contact) will be provided.

In some cases, Knx actuators can do more than the corresponding modelled pimatic sensors (e.g., shutters can be positioned precisely with some actuators. Dimmers/shutters can vary by steps) The plan is to provide proper templates for their visualization for those actuators offering the extras, and even to emulate those extras from within the plugin, configuring timings for the devices, and a calibration mode for those.

Finally, also part of the plan is to implement a proxy device to capture KNX datagrams and act on other devices registered within the pimatic installation, emulating KNX devices with other technologies (which can then be controlled from the KNX bus)

