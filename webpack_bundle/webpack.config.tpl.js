const path = require('path');

const baseConfig = require(path.resolve("TEMPLATED_BASE_CONFIG_PATH"));
const overrideConfig = {
  entry: [path.resolve("TEMPLATED_ENTRY_POINT")],
  resolve: {
    symlinks: false,
  },
  output: {
    path: path.dirname(path.resolve("TEMPLATED_OUT_PATH")),
    filename: path.basename("TEMPLATED_OUT_PATH"),
  },
};

module.exports = {
  baseConfig: baseConfig,
  overrideConfig: overrideConfig,
};
