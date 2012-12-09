#
# Cakefile
# --------
#
#  Targets:
#
#     test:
#     	print some pretty colors on the console
#
#     toast:
#       create the javascript files in the build/ directory
#
#
# Based on sample cakefile at
# https://github.com/kompiro/Cakefile-Sample/
#

try
  {spawn} = require 'child_process'
  {log} = require 'util'
  fs = require 'fs'
  glob = require 'glob'
  _ = require 'lodash'
  coffee = require 'coffee-script'
catch err
  console.log "\n Package loading issue; Perhaps `npm install` needs to be run."
  throw new Error("A package could not be loaded: #{err}")


SRC_DIR = 'lib'
COFFEE_SRC = ['casper-chai.coffee']
DEST = 'build/casper-chai'
UGLIFY_CMD = './node_modules/uglify-js2/bin/uglifyjs2'


task 'test', 'Print some pretty colors to the console', (options) ->
  cmd = 'casperjs'
  args = ["test/run.js"]
  log "Cake is running: #{cmd} #{args.join(" ")}"
  spawn cmd, args, customFds: [0, 1, 2]


task 'deploy', 'Publish a patch release on npm (increments patch number)', ->
  semver = require('semver')

  # read package.json
  pkg = JSON.parse(fs.readFileSync('package.json', "utf8"))

  # get and increment version
  version = pkg.version
  pkg.version = semver.inc(version, 'patch')

  # notify of version change and write new package.json
  console.log "version incrementing from #{version} => #{pkg.version}"
  fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2), "utf8")

  # build latest version
  invoke 'toast'

  # publish
  args = ['publish']
  spawn "npm", args, customFds: [0,1,2]


task 'toast', "Build the project into the build/ dir", (options) ->
  source_dir = require('path').join(__dirname, SRC_DIR)
  version = JSON.parse(fs.readFileSync("package.json")).version
  console.log "Compiling version #{version}"
  sources = []

  # Get all source files. Preserve the order in COFFEE_SRC
  _.each(COFFEE_SRC, (src) ->
    _.each(glob.sync(src, cwd: source_dir), (filename) ->
      if filename not in sources
        sources.push(filename)
    )
  )

  # get the source as a string
  source = _.map(sources, (src_file) ->
    src_file = require('path').join(SRC_DIR, src_file)
    console.log "Compiling #{src_file}."
    js = coffee.compile fs.readFileSync(src_file, 'utf8')
    return "\n// -- from: #{src_file} -- \\\\\n" + js
  ).join("\n")

  contents = source

  console.log "Writing #{DEST}.js"
  fs.writeFileSync("#{DEST}.js", contents, 'utf8')

  # minify the content
  console.log "Creating minified #{DEST}.min.js"
  args = ["#{DEST}.js", '-o', "#{DEST}.min.js", '-m', '--lint']
  spawn UGLIFY_CMD, args, customFds: [0, 1, 2]


