###
# Casper-jQuery

Add a function as `casper.$` for performing remote jQuery functions
###
wrapped = [
  "attr", # (name[, value])
  "css", # (name[, value])
  "data", # (name[, value])
  "class", # (className)
  "id", # (id)
  "is", # (:attr)
  "html", # (html)
  "text", # (text)
  "value", # (value)
  "visible",
  "hidden",
  "selected",
  "checked",
  "disabled",
  "empty",
  "exist",
  "match", # (selector) / be", # (selector)
  "contain", # (text)
  "have", # (selector)
]

class JQueryCasperWrapper
  constructor: (@casper, @selector) ->
    _.each(wrapped, (method) =>
      wrapper = (args...) => @jQueryThere(method, args)
      @[method] = wrapper
    )

    #
    # ### .length
    #
    # This gets the length of elements of the selector on the client
    #
    Object.defineProperty(@, 'length',
      get: =>
        len_fn = (_selector) ->
          return $(_selector).length

        return @casper.evaluate(len_fn,
          _selector: @selector
        )
    )

  fn: {}
 
  jQueryThere: (methodName, args) ->
    remote_fn = (_selector, _methodName, _args) ->
      jobj = jQuery(_selector)
      return jobj[_methodName].apply(jobj, _args)
      
    return casper.evaluate(remote_fn,
      _selector: @selector
      _methodName: methodName
      _args: args
    )
 
###
  jQueryInCasper
  --------------

  A wrapper for jQuery
###
jQueryInCasper = (selector) ->
  return new JQueryCasperWrapper(@, selector)

jQueryInCasper.fn = {}
jQueryInCasper.each = (items, cb) ->
  # replicate $.each
  return _.each(items, (item, index) -> cb(index, item))
  
require('casper').Casper::$ = jQueryInCasper

old_$ = $
# window.$ = $ = global.$ = window.jQuery = global.$ = exports.$ = casper.$
window.jQuery = casper.$
chai_jquery = require('./node_modules/chai-jquery/chai-jquery')
chai.use(chai_jquery)
$ = old_$


