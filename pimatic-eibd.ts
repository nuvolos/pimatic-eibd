// #Plugin template

// This is an plugin template and mini tutorial for creating pimatic plugins. It will explain the
// basics of how the plugin system works and how a plugin should look like.

// ##The plugin code

// Your plugin must export a single function, that takes one argument and returns a instance of
// your plugin class. The parameter is an envirement object containing all pimatic related functions
// and classes. See the [startup.coffee](http://sweetpi.de/pimatic/docs/startup.html) for details.
export default function(env) {
  // ###require modules included in pimatic
  // To require modules that are included in pimatic use `env.require`. For available packages take
  // a look at the dependencies section in pimatics package.json

  // Require the  bluebird promise library
  let Promise = env.require('bluebird');
  // Require the [cassert library](https://github.com/rhoot/cassert).
  let assert = env.require('cassert');
  let _      = env.require('lodash');

  // Include you own depencies with nodes global require function:
  //
  //     someThing = require 'someThing'
  //
  let ZoneManager = (require('./zone-manager'))(env);
  let deviceTypes = {};

  for (let device of [
    'knx-power',
    'knx-shutter',
    'knx-dimmer',
    'knx-sensor',
    'knx-temperature',
    'knx-date-time',
    'knx-trigger'
  ]) {
    // convert kebap-case to camel-case notation with first character capitalized
    let className = device.replace(/(^[a-z])|(\-[a-z])/g, $1 => $1.toUpperCase().replace('-',''));
    deviceTypes[className] = require(`./devices/${device}`)(env);
  }

  // ###MyPlugin class
  // Create a class that extends the Plugin class and implements the following functions:
  class EibdPlugin extends env.plugins.Plugin {

    // ####init()
    // The `init` function is called by the framework to ask your plugin to initialise.
    //
    // #####params:
    //  * `app` is the [express] instance the framework is using.
    //  * `framework` the framework itself
    //  * `config` the properties the user specified as config for your plugin in the `plugins`
    //     section of the config.json file
    //
    //
    constructor(...args) {
      {
        // Hack: trick babel into allowing this before super.
        if (false) { super(); }
        let thisFn = (() => { this; }).toString();
        let thisName = thisFn.slice(thisFn.indexOf('{') + 1, thisFn.indexOf(';')).trim();
        eval(`${thisName} = this;`);
      }
      this.init = this.init.bind(this);
      super(...args);
    }

    init(app, framework, config) {
      this.framework = framework;
      this.config = config;
      env.framework.instance = this.framework;
      this.zm = new ZoneManager((_.cloneDeep(this.config.zones)), this);
      let deviceConfigDef = require("./device-config-schema");
      let common = deviceConfigDef.Common.properties;

      return (() => {
        let result = [];
        for (let dtname in deviceTypes) {
          let dtclass = deviceTypes[dtname];
          result.push(((dtname, dtclass) => {
            let confDef = _.cloneDeep(deviceConfigDef[dtname]);
            _.extend(confDef.properties, _.cloneDeep(common));

            let dclass = {
              configDef: confDef,
              createCallback: (config, lastState) => {
                return new dtclass(config, this, lastState);
              }
            };

            return this.framework.deviceManager.registerDeviceClass(dtname, dclass);
          })(dtname, dtclass));
        }
        return result;
      })();
    }
  }
  // ###Finally
  // Create a instance of my plugin and return it
  return new EibdPlugin;
};
