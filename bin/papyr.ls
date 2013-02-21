### papyr.ls --- The CLI tool for generating papyr documentations
#
# Copyright (c) 2013 Quildreen "Sorella" Motta <quildreen@gmail.com>
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

doc = '''
      Papyr° — CLI tool for generating Papyr° documentation.

      Usage:
        papyr build <json>
        papyr -h | --help
        papyr --version

      Options:
        -h, --help              Shows this screen.
        -v, --version           Displays Papyr° version and exits.
      '''


##[ Dependencies ]######################################################
fs     = require 'fs'
path   = require 'path'
glob   = require 'glob'
jade   = require 'jade'
marked = require 'marked'
wrench = require 'wrench'
global <<< require 'prelude-ls'


##[ Helpers ]###########################################################

# Writes contents to a path
# write :: String -> String -> IO ()
write = (pathname, contents) -->
  fs.write-file-sync pathname, content, 'utf-8'


# Reads contents from a path.
# read :: String -> IO String
read = (pathname) ->
  fs.read-file-sync pathname, 'utf-8'


# Reads contents from a path and parses as JSON.
# read-as-json :: String -> IO Object
read-as-json = (pathname) ->
  JSON.parse (read pathname)


# Loads a Jade documentation template
# read-template :: String -> IO String
read-template = (pathname) ->
  read (path.resolve __dirname, '../templates', pathname)


# Copies a tree recursively
# copy-tree :: String -> String -> IO ()
copy-tree = (out, from) -->
  wrench.copy-dir-sync-recursive from, out


# Constructs a directory tree recursively
# make-tree = String -> IO ()
make-tree = (pathname) ->
  wrench.mkdir-sync-recursive pathname


# Converts something to JSON
# to-json :: a -> String
to-json = JSON.stringify


# Wraps some JSON in a JSON-P format
# jsonp :: String -> String
jsonp = (x) -> "papyr.load(#{x})"


# Returns an API map for an API list
# api-map :: API -> { String -> Entity }
api-map = (api) -> {[x.id, x] for x in api.entities}


# Inherits properties from parent objects
# inherit-all :: Entity* -> { String -> Entity } -> API -> [String] -> Entity*
inherit-all = (entity, api-map, api, xs) --> xs |> each (x) ->
  each (inherit entity, api-map, api), x


# Inherits a single property from parent objects
# inherit :: Entity* -> { String -> Entity } -> API -> String -> Entity*
inherit = (entity, api-map, api, property) -->
  parent = arguments.5
  if not property of entity
    # Try searching property on parent
    if arguments.length < 5 => parent = entity.parent
    if parent
      p = api-map[parent]
      if p
        switch
        | property of p => entity[property] = p[property]
        | otherewise    => inherit entity, api-map, api, property, parent.parent

    # No parents? Just grab it from the API
    else
      if property of api => entity[property] = api[property]


# Loads Markdown literate examples from a folder
# load-examples :: String -> Entity -> IO [String]
load-examples = (pathname, entity) -->
  files = glob.sync '*.md', root: (path.resolve pathname, entity.id)
  map (marked . read), files  


# Process an API to load examples and what not
# process-api :: API -> IO API
process-api = (api-map, api) --> api.entities |> each (x) ->
  if api.prefix => x.id = api.prefix + x.id

  # Inherit properties from parent objects
  inherit-all x, api-map, api
            , <[ language file copyright repository authors licence ]>

  # Load examples
  x.examples = load-examples api.examples, x

  # Returns the entity
  x


# Load API entities
# load-api-entities :: API -> IO API
load-api-entities = (api) ->
  api.entities = fold (<<<), (map read-as-json, api.entities)

    
# Builds the documentation from a JSON configuration
# build-documentation :: String -> IO ()
build-documentation = (config) ->
  data      = read-as-json config
  data.apis = map load-api-entities, data.apis
  template  = jade (read-template (data.template or 'default.jade'))
  entities  = concat-map (process-api (api-map data.apis)), data.apis

  # Initialise the output directory
  out = data.output or 'build-docs'
  make-tree out
  copy-tree 'www/media', "#{out}/media"
  copy-tree 'www/vendor', "#{out}/vendor"
  write "#{out}/index.html" (template data)
  write "#{out}/api.jsonp" (jsonp (to-json entities))
  console.log "Documentation successfully generated at #{out}."
  

# Prints help and exit
# print-help :: () -> IO ()
print-help = ->
  console.log doc
  process.exit 0


##[ Main ]##############################################################
{docopt} = require 'docopt'
papyr-meta  = require '../package'

args = docopt doc, version: papyr-meta.version

switch
| args.build => build-documentation args['<json>']
| otherwise  => print-help!
