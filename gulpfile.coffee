gulp = require 'gulp'
webpack = require 'gulp-webpack'
plumber = require 'gulp-plumber'
stylus = require 'gulp-stylus'
path = require 'path'
nib = require 'nib'
named = require 'vinyl-named'
path = require 'path'
browserSync = require 'browser-sync'
del = require 'del'
{argv} = require 'yargs'

project =
  name: 'F2E'
  src: 'src'
  dist: './dist/'
  webpack: require './webpack.config'

scripts =
  name: "scripts"
  src: "#{project.src}/scripts"
  dist: "#{project.dist}/static/scripts"
  exts: ['js', 'coffee']

styles =
  name: "stylesheets"
  src: "#{project.src}/styles"
  dist: "#{project.dist}/static/styles"
  exts: ['css', 'styl']

html =
  name: "html"
  src: "{#{project.src},#{project.src}/views}"
  exts: ['html', 'htm']
  dist: "#{project.dist}"

images =
  name: "images"
  src: "#{project.src}/images"
  exts: ['jpg', 'png', 'gif', 'svg']
  dist: "#{project.dist}/images"

assets =
  name: 'assets'
  dirs: [].concat(scripts.src, styles.src)
  exts: [].concat(scripts.exts, styles.exts)
  glob: (bundle) ->
    if bundle
      "#{bundle.src}/**/*.{#{bundle.exts.join(',')}}"
    else
      dirs = [].concat(assets.dirs)
      exts = [].concat(assets.exts)
      "{#{dirs.join(',')}}/**/*.{#{exts.join(',')}}"

gulp.task 'default', ['clean'], ->
  gulp.start 'build'

gulp.task 'build', ['collect', 'style', 'webpack']

gulp.task 'clean', ['clean:dist']

gulp.task 'watch', ['default'], ->
  gulp.start 'browser-sync'
  gulp.watch "{#{assets.glob()},#{html.src}/**/*.#{html.exts.join(',')}}", ['build']

gulp.task 'webpack', ->
  gulp.src assets.glob(scripts)
    .pipe plumber()
    .pipe named((file) ->
      dirname = path.basename(path.dirname(file.path))
      filename = path.basename(file.path, path.extname(file.path))
      path.join(dirname, filename))
    .pipe webpack project.webpack
    .pipe gulp.dest("#{scripts.dist}")
    .pipe browserSync.reload(stream: true)

gulp.task 'style', ->
  options =
    use: [nib()]
    compress: not argv.debug
    sourcemap: { inline: argv.debug } if argv.debug
  gulp.src assets.glob(styles)
    .pipe plumber()
    .pipe stylus(options)
    .pipe gulp.dest("#{styles.dist}")
    .pipe browserSync.reload(stream: true)

gulp.task 'collect', ['collect:images', 'collect:html']

gulp.task 'collect:images', ->
  gulp.src "#{images.src}/**/*.{#{images.exts.join(',')}}"
    .pipe gulp.dest "#{images.dist}/"

gulp.task 'collect:html', ->
  gulp.src "#{html.src}/**/*.{#{html.exts.join(',')}}"
    .pipe gulp.dest "#{html.dist}/"

gulp.task 'browser-sync', ->
  port = argv.port or process.env.PORT
  browserSync
    port: port,
    open: false
    server:
      baseDir: ["#{project.dist}"]

gulp.task 'clean:dist', (done) ->
  del [
    "#{project.dist}"
  ], done
