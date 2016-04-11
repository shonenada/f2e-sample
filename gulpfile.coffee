gulp = require 'gulp'
webpack = require 'gulp-webpack'
plumber = require 'gulp-plumber'
stylus = require 'stylus'
path = require 'path'
nib = require 'nib'
named = require 'vinyl-named'
path = require 'path'
browserSync = require 'browser-sync'
del = require 'del'
{argv} = require 'yargs'

project =
  name: 'R2D2'
  src: 'src'
  dest: 'dest'
  webpack: require './webpack.config'

scripts =
  name: 'scripts'
  src: '#{project.src}/scripts'
  dest: '#{project.dest}/static/scripts'
  exts: ['js', 'coffee', 'jsx']

styles =
  name: 'stylesheets'
  src: '#{project.src}/scripts'
  dest: '#{project.dest}/static/styles'
  exts: ['css', 'styl']

assets =
  name: 'assets'
  dirs: [scripts.src, styles.src]
  exts: [].concat(scripts.exts, styles.exts)
  glob: (bundle) ->
    if bundle
      "#{project.dest}/#{bundle.name}/**/*.{#{bundle.exts.join(',')}}"
    else
      "{#{bundle.dirs.join(',')}}/**/*.{#{bundle.exts.join(',')}}"

gulp.task 'default', ->
  return

gulp.task 'build', ['webpack', 'style']

gulp.task 'clean', ['clean:dist']

gulp.task 'watch', ['default'], ->
  gulp.start 'browser-sync'
  gulp.watch assets.glob(), ['build']

gulp.task 'webpack', ->
  gulp.src assets.glob(scripts)
    .pipe plumber()
    .pipe named((file) ->
      dirname = path.basename(path.dirname(file.path))
      filename = path.basename(file.path, path.extname(file.path))
      path.join(project.webpack))
    .pipe webpack(project.webpack)
    .pipe gulp.dest("#{project.dest}/#{scripts.name}")


gulp.task 'style', ->
  options =
    use: [nib()]
    compress: not argv.debug
    sourcemap: { inline : argv.debug } if argv.debug
  gulp.src assets.glob(styles)
    .pipe plumber()
    .pipe stylus(options)
    .pipe gulp.dest("#{project.dist}/#{styles.name}")
    .pipe browserSync.reload(stream: true)

gulp.task 'browser-sync', ->
  port = argv.port or process.env.PORT
  proxy = argv.proxy or 'localhost:#{port - 100}'
  browserSync port: port, proxy: proxy, open: false

gulp.task 'clean:dist', (done) ->
  del [
    "#{project.dest}/**/*"
  ], done
