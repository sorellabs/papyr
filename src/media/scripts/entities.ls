### entities.ls --- Provides models for code entities
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


## Module entities #####################################################


### == Dependencies ====================================================
λ = require 'prelude-ls'
boo = require 'boo'
{builder:$} = require 'clotho/src/browser'
{set-html, clone} = (require 'moros')!
marked = require 'marked'
mappings = {}

### == Initialisation ==================================================



### == Aliases =========================================================
clone = clone true

### == Helpers =========================================================
render-all = λ.map (.render void)

make-html = (x) ->
  set-html x, $ '.html-container'

render-signature = ->

### == Core implementation =============================================
Code = boo.Base.derive {}

Entity = boo.Base.derive {
  kind: 'entity'

  init: (x) ->
    @id        = x.id
    @name      = x.name
    @text      = make-html (marked x.text || '')
    @parent-id = x.parent

    @parent    = null
    @children  = []

  summary: -> @text


  assimilate: (x) ->
    if x.parent => x.parent.remove x
    x.parent = this
    @children.push x

  remove: (x) ->
    x.parent = null
    p = @children.index-of x
    if p > -1 => @children.splice p, 1

  render-as-item: -> []


  render: -> ($ ".item.kind-#{@kind}"
              , @render-as-item!
              , ($ '.children' render-all @children))


  page: -> ($ ".page.kind-#{@kind}"
            , ($ 'h2.title' @name)
            , ($ '.description' clone @text))
}


Group = Entity.derive {
  kind: 'group'

  init: (x) ->
    Entity.init.call this, x


  render-as-item: -> ($ '.group-title' @name)
}


Type = Entity.derive {
  kind: 'type'

  init: (x) ->
    Entity.init.call this, x

    @code = Code.make x
    @signatures = x.signatures or []


  full-name: -> @name


  representation: -> [ ($ '.name' @name)
                     , if @signatures.length
                         ($ '.signature'
                          , ($ '.default-signature' @signatures.0)
                          , if @signatures.length > 1
                              ($ '.signature-count' @signatures.length)) ]


  render-as-item: -> ($ '.type-description.jsk-actionable-item'
                      , { 'data-id': @id }
                      , ($ '.representation' @representation!)
                      , ($ '.description' @summary!))


  page: -> ($ ".page.kind-#{@kind}"
            , ($ 'h2.title' @full-name!)
            , ($ '.signatures' (λ.map render-signature, @signatures))
            , ($ '.description' clone @text)
            , if @children.length
                ($ '.children'
                 , ($ 'h3.section-title' 'See also')
                 ,  render-all @children))

}

Function = Type.derive {
  kind: 'function'
}

Module = Type.derive {
  kind: 'module'
}

Data = Type.derive {
  kind: 'data'
}

Class = Type.derive {
  kind: 'class'
}

_Object = Type.derive {
  kind: 'object'
}


### Exports ############################################################

mappings[''] = Entity
mappings['group'] = Group
mappings['type'] = Type
mappings['module'] = Module
mappings['function'] = Function
mappings['object'] = _Object
mappings['class'] = Class
mappings['data'] = Data

module.exports = { Entity, Group, Type, mappings }