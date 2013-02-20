(function(){
  var λ, entities, ref$, detach, listen, clear, query, append, addClass, removeClass, specifyClassState, each, $, bindings, top, matchesP, findTarget, activate, deactivate, rendered, makeEntity, makeBinding, resolveCrossReference, topLevelP, load, updateRender, doTransition, searchQuery, searchTimer, doSearch;
  λ = require('prelude-ls');
  entities = require('./entities');
  ref$ = require('moros')(), detach = ref$.detach, listen = ref$.listen, clear = ref$.clear, query = ref$.query, append = ref$.append, addClass = ref$.addClass, removeClass = ref$.removeClass, specifyClassState = ref$.specifyClassState, each = ref$.each;
  $ = require('clotho/src/browser').builder;
  bindings = {};
  top = [];
  matchesP = (function(el){
    return el.matchesSelector || el.oMatchesSelector || el.msMatchesSelector || el.mozMatchesSelector || el.webkitMatchesSelector;
  }.call(this, document.createElement('div')));
  findTarget = curry$(function(selector, parent, x){
    while (x !== parent) {
      if (matchesP.call(x, selector)) {
        return x;
      }
      x = x.parentElement;
    }
    return null;
  });
  activate = addClass('active');
  deactivate = removeClass('active');
  rendered = λ.map(function(it){
    return it.render(void 8);
  });
  makeEntity = function(x){
    switch (false) {
    case !(x.kind in entities.mappings):
      return entities.mappings[x.kind].make(x);
    default:
      throw new Error("Unknow entity type " + x.kind);
    }
  };
  makeBinding = function(x){
    return bindings[x.id] = x;
  };
  resolveCrossReference = function(x){
    var parent;
    parent = bindings[x.parentId];
    if (parent) {
      parent.assimilate(x);
    }
    return x;
  };
  topLevelP = function(it){
    return it.parent === null;
  };
  load = function(xs){
    var ys, as;
    ys = λ.map(compose$([makeBinding, makeEntity]), xs);
    λ.map(resolveCrossReference)(
    ys);
    as = λ.values(bindings);
    top.length = 0;
    top.push.apply(top, as.filter(topLevelP));
    return updateRender(top);
  };
  updateRender = function(xs){
    var entityList;
    entityList = query('#entity-list')[0];
    clear(entityList);
    return append(entityList, rendered(xs));
  };
  doTransition = function(){
    window.scrollTo(0, 0);
    addClass('in-transition', query('body'));
    return setTimeout(function(){
      return removeClass('in-transition', query('body'));
    }, 600);
  };
  listen('click', function(ev){
    var el, id, entity, p;
    el = findTarget('.jsk-actionable-item', ev.currentTarget, ev.target);
    if (el) {
      ev.preventDefault();
      id = el.getAttribute('data-id');
      entity = bindings[id];
      if (entity) {
        append(query('#viewport')[0], p = $('li.context.entity-details', $('.back-button'), entity.page()));
        deactivate(query('.context'));
        activate(p);
        addClass('prettyprint', query('pre', p));
        prettyPrint(void 8, p);
        return doTransition();
      }
    }
  })(
  query('#viewport'));
  listen('click', function(ev){
    var el, context;
    el = findTarget('.context > .back-button', ev.currentTarget, ev.target);
    if (el) {
      ev.preventDefault();
      context = el.parentElement;
      deactivate(context);
      activate(context.previousElementSibling);
      setTimeout(function(){
        return detach(context);
      }, 500);
      return doTransition();
    }
  })(
  query('#viewport'));
  searchQuery = query('#search-query')[0];
  searchTimer = null;
  listen('focus', function(ev){
    return activate(searchQuery.parentElement);
  })(
  searchQuery);
  listen('blur', function(ev){
    return deactivate(searchQuery.parentElement);
  })(
  searchQuery);
  listen('keyup', function(ev){
    clearTimeout(searchTimer);
    return setTimeout(doSearch, 1000);
  })(
  searchQuery);
  doSearch = function(){
    var value;
    value = new RegExp(searchQuery.value.replace(/\s*/g, '').replace(/(\W)/g, '\\s*\\$1\\s*'), 'i');
    return each(function(x){
      var entity, visible;
      entity = bindings[x.getAttribute('data-id')];
      if (entity) {
        visible = value.test(entity.id) || value.test(entity.name) || value.test(entity.markdown) || value.test((entity.signatures || []).join('\n'));
        return specifyClassState('hidden', !visible, x);
      }
    })(
    query('#entity-list .jsk-actionable-item'));
  };
  window.papyr = {
    load: load,
    bindings: bindings,
    top: top
  };
  function curry$(f, bound){
    var context,
    _curry = function(args) {
      return f.length > 1 ? function(){
        var params = args ? args.concat() : [];
        context = bound ? context || this : this;
        return params.push.apply(params, arguments) <
            f.length && arguments.length ?
          _curry.call(context, params) : f.apply(context, params);
      } : f;
    };
    return _curry();
  }
  function compose$(fs){
    return function(){
      var i, args = arguments;
      for (i = fs.length; i > 0; --i) { args = [fs[i-1].apply(this, args)]; }
      return args[0];
    };
  }
}).call(this);
