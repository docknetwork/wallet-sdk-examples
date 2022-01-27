module.exports = {
  presets: [
    [
      '@babel/preset-env',
      {
        targets: {
          node: 'current',
        },
      },
    ],
  ],
  plugins: [
    '@babel/plugin-transform-flow-strip-types',
    [
      require.resolve('babel-plugin-module-resolver'),
      {
        alias: {
          "@polkadot/types/packageInfo.cjs": require.resolve("../wallet-sdk/node_modules/@polkadot/types/packageInfo.cjs"),
        }
      }
  
    ]
  ]
};
