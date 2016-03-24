# search-path - find stuff from local filesystem based on search query

path    = require 'path'
fs      = require 'fs'

class Content extends String
  constructor: -> super

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

  unique: (key) ->
    return @ unless @length > 0
    output = {}
    unless key?
      output[@[key]] = @[key] for key in [0...@length]
    else
      for k in [0..@length-1] when typeof @[k] is 'object'
        val = @[k]
        idx = val[key]
        idx ?= val.get? key
        idx ?= k
        continue unless idx?
        output[idx] = val
    (value for key, value of output)

  # used to specify 'basedir' to use when adding relative paths
  base: (path=@opts.basedir) -> @opts.basedir = path; this

  # TODO: optimize further to remove duplicates that may be part of the
  # overall searchpath array
  include: ->
    dirs = [].concat arguments...
    @unshift (@unique.call (@exists dirs, isDirectory: true))...

  locate: ->
    files = [].concat arguments...
    res = @exists files, isFile: true
    @unique().forEach (dir) =>
      #console.log "checking #{dir} for #{files}"
      res.push (@exists (files.map (f) -> path.resolve dir, f), isFile: true)...
    return (@unique.call res)

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
    (@resolve ([].concat arguments...)).map (f) => fs.readFileSync f, @opts.encoding

module.exports = SearchPath
