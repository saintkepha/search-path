# search-path - find stuff from local filesystem based on search query

path    = require 'path'
fs      = require 'fs'

class SearchPath extends Array
  constructor: (@opts={}) ->
    @opts.basedir ?= process.cwd()
    @opts.encoding ?= 'utf-8'
    @opts.exts = [].concat @opts.exts...
    super

  exists: (paths..., opts={}) ->
    unless opts instanceof Object
      paths.push opts
      opts = {}
    opts[k] = v for k, v of @opts when not opts[k]?
    [].concat paths...
      .filter (f) -> (typeof f is 'string') and !!f
      .map (f) -> path.resolve opts.basedir, f
      .filter (f) ->
        try stat = fs.statSync f
        catch
        switch
          when not stat? then false
          when opts.isDirectory then stat.isDirectory()
          when opts.isFile then stat.isFile()
          else false

  # used to specify 'basedir' to use when adding relative paths
  base: (path=@opts.basedir) -> @opts.basedir = path; this

  # TODO: optimize to remove duplicates
  include: ->
    @unshift (@exists ([].concat arguments...), isDirectory: true)...

  locate: ->
    files = [].concat arguments...
    res = []
    @forEach (dir) =>
      #console.log "checking #{dir} for #{files}"
      res.push (@exists (files.map (f) -> path.resolve dir, f), isFile: true)...
    return res

  resolve: ->
    files =
      ([].concat arguments...)
        .filter (x) -> x? and !!x
        .reduce ((a,b) =>
          a.push b
          if not !!(path.extname b)
            a.push "#{b}.#{ext}" for ext in @opts.exts
          return a
        ), []
    @locate files

  fetch: ->
    (@resolve ([].concat arguments...)).map (f) -> fs.readFileSync f, @opts.encoding

module.exports = SearchPath
