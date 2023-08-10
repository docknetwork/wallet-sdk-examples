const path = require('path');
const webpack = require('webpack');
const NodePolyfillPlugin = require("node-polyfill-webpack-plugin")

module.exports = {
  webpack: {
    configure: (webpackConfig, { env, paths }) => {
      const wasmExtensionRegExp = /\.wasm$/;
      webpackConfig.resolve.extensions.push('.wasm');
  
      webpackConfig.devtool = false;

      webpackConfig.module.rules.forEach((rule) => {
        if (rule.oneOf) {
          rule.oneOf.forEach((oneOf) => {
            if (oneOf.loader && oneOf.loader.includes('file-loader')) {
              oneOf.exclude.push(wasmExtensionRegExp);
            }
          });
        }
      });

      const wasmLoader = {
        test: /\.wasm$/,
        type: 'javascript/auto',
        use: ['wasm-loader'],
      };
  
      webpackConfig.module.rules.push(wasmLoader);

      webpackConfig.plugins.push(
        new NodePolyfillPlugin({
          excludeAliases: ["console"]
        })
      );

      webpackConfig.resolve.alias = {
        ...webpackConfig.resolve.alias,
        realm: path.resolve(__dirname, 'shims/realm.js'),
        'react-native-sqlite-storage': path.resolve(__dirname, 'shims/react-native-sqlite-storage.js'),
      };

      return webpackConfig;
    },
  },
};
