(function(){
  var λ, boo, $, ref$, setHtml, clone, marked, mappings, renderAll, makeHtml, renderSignature, Code, Entity, Group, Type, Function, Module, Data, Class, _Object;
  λ = require('prelude-ls');
  boo = require('boo');
  $ = require('clotho/src/browser').builder;
  ref$ = require('moros')(), setHtml = ref$.setHtml, clone = ref$.clone;
  marked = require('marked');
  mappings = {};
  clone = clone(true);
  renderAll = λ.map(function(it){
    return it.render(void 8);
  });
  makeHtml = function(x){
    return setHtml(x, $('.html-container'));
  };
  renderSignature = function(x){
    return $('.signature', x);
  };
  Code = boo.Base.derive({});
  Entity = boo.Base.derive({
    kind: 'entity',
    init: function(x){
      this.id = x.id;
      this.name = x.name;
      this.text = makeHtml(marked(x.text || ''));
      this.markdown = x.text || '';
      this.parentId = x.parent;
      this.parent = null;
      return this.children = [];
    },
    summary: function(){
      return clone(this.text);
    },
    assimilate: function(x){
      if (x.parent) {
        x.parent.remove(x);
      }
      x.parent = this;
      return this.children.push(x);
    },
    remove: function(x){
      var p;
      x.parent = null;
      p = this.children.indexOf(x);
      if (p > -1) {
        return this.children.splice(p, 1);
      }
    },
    renderAsItem: function(){
      return [];
    },
    render: function(){
      return $(".item.kind-" + this.kind, this.renderAsItem(), $('.children', renderAll(this.children)));
    },
    page: function(){
      return $(".page.kind-" + this.kind, $('h2.title', this.name), $('.description', clone(this.text)));
    }
  });
  Group = Entity.derive({
    kind: 'group',
    init: function(x){
      return Entity.init.call(this, x);
    },
    renderAsItem: function(){
      return $('.group-title', this.name);
    }
  });
  Type = Entity.derive({
    kind: 'type',
    init: function(x){
      Entity.init.call(this, x);
      this.code = Code.make(x);
      return this.signatures = x.signatures || [];
    },
    fullName: function(){
      return this.name;
    },
    representation: function(){
      return [$('.name', this.name), this.signatures.length ? $('.signature', $('.default-signature', this.signatures[0]), this.signatures.length > 1 ? $('.signature-count', "+" + (this.signatures.length - 1)) : void 8) : void 8];
    },
    renderAsItem: function(){
      return $('.type-description.jsk-actionable-item', {
        'data-id': this.id
      }, $('.representation', this.representation()), $('.description', this.summary()));
    },
    page: function(){
      return $(".page.kind-" + this.kind, $('h2.title', this.fullName()), $('.signatures', λ.map(renderSignature, this.signatures)), $('.description', clone(this.text)), this.children.length ? $('.children', $('h3.section-title', 'See also'), renderAll(this.children)) : void 8);
    }
  });
  Function = Type.derive({
    kind: 'function'
  });
  Module = Type.derive({
    kind: 'module'
  });
  Data = Type.derive({
    kind: 'data'
  });
  Class = Type.derive({
    kind: 'class'
  });
  _Object = Type.derive({
    kind: 'object'
  });
  mappings[''] = Entity;
  mappings['group'] = Group;
  mappings['type'] = Type;
  mappings['module'] = Module;
  mappings['function'] = Function;
  mappings['object'] = _Object;
  mappings['class'] = Class;
  mappings['data'] = Data;
  module.exports = {
    Entity: Entity,
    Group: Group,
    Type: Type,
    mappings: mappings
  };
}).call(this);
