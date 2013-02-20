### scope.ls --- Manages all documented entiries under one scope
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
#


## Module scope ########################################################
λ = require 'prelude-ls'
entities = require './entities'
{detach, listen, clear, query, append, add-class, remove-class} = (require 'moros')!
{builder:$} = require 'clotho/src/browser'

bindings = {}
top = []

# Matches selector
matches-p = let el = document.create-element 'div'
            return el.matches-selector        \
                || el.o-matches-selector      \
                || el.ms-matches-selector     \
                || el.moz-matches-selector    \
                || el.webkit-matches-selector


# Find element based on target
find-target = (selector, parent, x) -->
  while x isnt parent
    if matches-p.call x, selector => return x
    x = x.parent-element
  return null

# Activation / Deactivation
activate = add-class 'active'
deactivate = remove-class 'active'


# :: [Entity] -> HTMLElement
rendered = λ.map (.render void)

# :: EntityMeta -> Entity
make-entity = (x) ->
  | x.kind of entities.mappings => entities.mappings[x.kind].make x
  | otherwise                   => throw new Error "Unknow entity type #{x.kind}"


# :: Entity -> IO Entity
make-binding = (x) ->
  bindings[x.id] = x


# :: Entity -> IO Entity
resolve-cross-reference = (x) ->
  parent = bindings[x.parent-id]
  if parent => parent.assimilate x
  x


# :: Entity -> Bool
top-level-p = (.parent is null)


# :: [EntityMeta] -> IO [Entity]
load = (xs) ->
  ys = λ.map (make-binding . make-entity), xs
  ys |> λ.map resolve-cross-reference

  as = λ.values bindings
  top.length = 0
  top.push.apply top, (as.filter top-level-p)
  update-render top


# :: [Entity] -> IO [Entity]
update-render = (xs) ->
  entity-list = (query '#entity-list').0
  clear entity-list
  append entity-list, rendered xs


# Events
(query '#viewport') |> listen 'click' (ev) ->
  el = find-target '.jsk-actionable-item', ev.current-target, ev.target
  if el
    ev.prevent-default!
    id     = el.get-attribute 'data-id'
    entity = bindings[id]
    if entity
      append (query '#viewport').0, p = ($ 'li.context.entity-details'
                                         , ($ '.back-button')
                                         , entity.page!)
      deactivate (query '.context')
      activate p
      window.scroll-to 0, 0

(query '#viewport') |> listen 'click' (ev) ->
  el = find-target '.context > .back-button', ev.current-target, ev.target
  if el
    ev.prevent-default!
    context = el.parent-element
    deactivate context
    activate context.previous-element-sibling
    window.scroll-to 0, 0
    set-timeout (-> detach context), 500



### Exports ############################################################
window.papyr = { load, bindings, top }
