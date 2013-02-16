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

2) Run the quick-start task and answer the questions it asks you:

```bash
$ papyr quick-start
```

3) Put your JSON files in the source fouder you specified in the
previous step.

4) Run the build step:

```bash
$ papyr build
```

5) Open the `index.html` file in your browser.


## How does that JSON looks?

The JSON should be a list of Objects that match the interface
`Entity`, as described in `docs/api.doll`. Fields besides
`id`, `name`, `kind` and `text` are optional:


## Licence

MIT/X11.

