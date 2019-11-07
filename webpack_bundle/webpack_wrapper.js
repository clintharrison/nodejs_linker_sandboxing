/* eslint-env node */
const fs = require('fs');
const path = require('path');
const webpack = require('webpack');

function mergeDeep(target, ...sources) {
  const isObject = item => (item && typeof item === 'object' && !Array.isArray(item));

  if (!sources.length) {
    return target;
  }
  const source = sources.shift();

  if (isObject(target) && isObject(source)) {
    Object.keys(source).forEach(key => {
      if (isObject(source[key])) {
        if (!target[key]) Object.assign(target, {[key]: {}});
        mergeDeep(target[key], source[key]);
      } else {
        Object.assign(target, {[key]: source[key]});
      }
    });
  }

  return mergeDeep(target, ...sources);
}

const main = function(args) {
  const configFlag = "--config-path=";
  const configPath = args.find(arg => arg.indexOf(configFlag) !== -1).slice(configFlag.length);
  const generatedConfig = require(path.resolve(configPath));
  const options = mergeDeep(generatedConfig.baseConfig, generatedConfig.overrideConfig);

  const compiler = webpack(options);
  compiler.run((err, stats) => {
    if (err) {
      log.error(err.stack || err);
      if (err.details) {
        log.error(err.details);
      }
    }

    // Print out helpful report of what we compiled, how long it took, etc.
    if (stats) {
      console.log(
        stats.toString({
          chunks: false,
          colors: true,
          modules: false
        })
      );
    }
  });
};

main(process.argv);
