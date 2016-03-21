# search-path - locate and fetch files from the filesystem using search path

A simple extension to Array to hold various search path directories
and provide checks for existence and locate/fetch files accordingly.

# Usage

Example usage (coffeescript):

```coffeescript
SearchPath = require 'search-path'
search = new SearchPath basedir: __dirname, exts: [ 'txt', 'doc' ], encoding: 'utf-8'

# include example and test/foo directories as part of search (relative
# to basedir)
search.add 'example', 'test/foo'

console.log search                  # shows current contents of search path
console.log (search.locate 'hello') # shows where 'hello', 'hello.txt', or 'hello.doc' was found
console.log (search.fetch 'hello')  # retrieves located content using 'encoding'
```

# API

## exists (paths..., opts)

Checks whether passed in *paths* exists in the local filesystem.

opts.basedir | string | prefix for relative paths
opts.isDirectory | boolean | if true, checks if directory
opts.isFile | boolean | if true, checks if file

## base (path)

Update the current *basedir* to use for relative paths.

```coffeescript
search.base('/home')
  .include 'some-user'
  .include 'other-user/docs'

console.log search

## include (paths...)

Adds additional directories into search path if they exist.

## locate (files...)

Finds all *files* existing in the current search path. Always returns
an array containing one or more matching files.

## resolve (files...)

Locates all *files* existing in the current search path including any
files matching the configured *exts* as part of the current search
path instance.

## fetch (files...)

Grabs content(s) of all resolved *files* using the *encoding* for the
search path.

This is a convenience function and simply applies `fs.readFileSync` on
the results of `resolve` from above.

# License
  [Apache 2.0](LICENSE)
