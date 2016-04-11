webpack = require 'webpack'
nib = require 'nib'
{argv} = require 'yargs'

plugins = [
  new webpack.optimize.CommonsChunkPlugin('common.js'),
  new webpack.optimize.UglifyJsPlugin() unless argv.debug,
]

module.exports =
  resolve:
    extensions: ['', '.webpack.js', '.js', '.coffee', '.styl']
    modulesDirectories: [
      'node_modules',
      'src/scripts',
      'src/styles',
    ]
  output:
    filename: 'bundle.js'
  module:
    loaders: [
      { test: /\.coffee$/, loader: 'coffee-loader' },
      { test: '\.css$/', loader: 'style!css' },
      { test: '\.styl$/', loader: 'style!css!stylus' },
    ]
  plugins: plugins.filter((item) -> item)
  devtool: if argv.debug then 'source-map' else ''
  cache: false
  stylus:
    use: [nib()]
