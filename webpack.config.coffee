webpack = require 'webpack'
nib = require 'nib'
{argv} = require 'yargs'

loaders = [
  { test: /\.coffee$/, loader: 'coffee' },
  { test: /\.css$/, loader: 'style!css' },
  { test: /\.styl/, loader: 'style!css!stylus'},
]

plugins = [
  new webpack.optimize.CommonsChunkPlugin('common.js'),
  new webpack.optimize.UglifyJsPlugin() unless argv.debug,
]

module.exports =
  resolve:
    extendsions: ['', '.js', '.coffee']
    modulesDirectories: [
      'node_modules',
      'scripts',
      'styles',
    ]
  mobule:
    loaders: loaders
  plugins: plugins.filter((item) -> item)
  devtool: 'source-map' if argv.debug
  cache: false
  stylus:
    use: [nib()]
