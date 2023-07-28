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
            // Check if the module matches the desired name
            
          });
        }
      });

      webpackConfig.module.rules.forEach((rule) => {
        if (rule.oneOf) {
          rule.oneOf.forEach((oneOf) => {
            if (oneOf.loader && oneOf.loader.includes('file-loader')) {
              oneOf.exclude.push(wasmExtensionRegExp);
            }
            if(oneOf.loader && oneOf.loader.includes('babel-loader') && oneOf.include) {
              // oneOf.include = [
              //   // path.resolve(__dirname, 'node_modules/@docknetwork'),
              //   // path.resolve(__dirname, 'node_modules/@polkadot'),
              //   /\/node_modules\/(@polkadot|@babel|@docknetwork|@digitalbazaar)/,
              //   oneOf.include,
              // ]
              // oneOf.include = undefined;
              // oneOf.exclude = /\/node_modules\/(@polkadot|@babel|@docknetwork|@digitalbazaar)/gi;
              // console.log(oneOf);
              
              // console.log()
              // oneOf.exclude = new RegExp(
              //   `node_modules/(?!(${path.join('docknetwork', 'sdk')}))`
              // );

              // console.log()
            }
          });
        }
      });
  

      // throw new Error('test');

      const wasmLoader = {
        test: /\.wasm$/,
        // exclude: /node_modules/,
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
        // 'console-browserify': path.resolve(__dirname, 'node_modules/console-browserify/index.js'),

      };

      
      // webpackConfig.resolve.mainFields = ['main'];


      // webpackConfig.resolve.extensions.push(".cjs");

      // Add a rule for handling '.cjs' files
      // webpackConfig.module.rules.push({
      //   test: /\.cjs$/,
      //   use: [
      //     {
      //       loader: paths.scriptLoader,
      //       options: {
      //         compact: env === "production",
      //       },
      //     },
      //   ],
      // });

      return webpackConfig;
    },
  },
};
