/* eslint-env node */
const root = require('app-root-path').path;

module.exports = {
  entry: `${root}/index.js`,
  output: {
    filename: 'bundle.js',
    path: `${root}`
  },
  resolve: {
    extensions: [".js"],
  },
};
