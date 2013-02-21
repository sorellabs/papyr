Papyr°
======

Papyr° is a single-page web application for visualising API documentation
written as plain JSON. It can also mix-in examples and Markdown-written
content (with just-in-time client-side rendering too!)


## Getting Started

Getting your API documentation in 5 easy steps:

1) Install it from NPM:

```bash
$ npm install -g papyr
```

2) Create a JSON file describing your documentation:

```bash
$ cat > doc.json
{ "project": "Test"
, "version": "1.0.0-snapshot"
, "template": "default.jade"
, "output": "docs/build"
, "apis": [{ "licence": "MIT"
           , "repository": "http://github.com/you/test"
           , "examples": "examples/"
           , "entities": [ "test.json" ] }]}
```

3) Put your API JSON files in the source folder you specified in the
previous step.

```bash
$ cp ~/path/to/test.json test.json
```

4) Run the build step specifying the documentation JSON.

```bash
$ papyr build doc.json
```

5) Open the `index.html` file in your browser.


## How does that JSON looks?

The JSON should be a list of Objects that match the interface
`Entity`, as described in `docs/api.doll`. Fields besides
`id`, `name`, `kind` and `text` are optional:


## Licence

MIT/X11.

