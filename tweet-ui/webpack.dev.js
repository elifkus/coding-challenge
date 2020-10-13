"use strict";

const path = require("path");
const { merge } = require('webpack-merge');
const common = require('./webpack.common.js');
const ReactRefreshWebpackPlugin = require("@pmmmwh/react-refresh-webpack-plugin");
const HtmlWebpackPlugin = require("html-webpack-plugin");

module.exports = merge(common, {
  devtool: 'eval-source-map',

  devServer: {
    contentBase: path.resolve(__dirname, 'dist'),
    port: 9000,
    stats: 'errors-only',
    hotOnly: true,
    hot: true,
  },

  mode: 'development',


  // This plugin updates React components without losing their state
  plugins: [
    new ReactRefreshWebpackPlugin(),
  ],

});
