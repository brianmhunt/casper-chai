###
  Chai assertions for CasperJS
  ============================

  Copyright (C) 2012 Brian M Hunt

  Repository: http://github.com/brianmhunt/casper-chai.git
  License: MIT (see LICENSE.txt)

###

# TODO/FIXME: Pass the casper instance in (instead of using global casper)

casperChai = (_chai, utils) ->
  properties = []
  methods = []
  assert = _chai.assert

  #
  #  Utilities
  #  ---------
  #

  _addProperty = (name, func) ->
    _chai.Assertion.addProperty(name, func)
    # assert[name] = Function.bind(assert, func)

  _addMethod = (name, method) ->
    _chai.Assertion.addMethod(name, method)
    # assert[name] = Function.bind(assert, method)

  #
  #  _exprAsFunction
  #
  #  Given an expression, turn it in to something that can be
  #  evaluated remotely.
  #
  # `expr` may be
  #
  # 1. a bare string e.g. "false" or "return true";
  #
  # 2. a function string e.g. "function () { return true }"
  #
  # 3. an actual function e.g. function () { return 'hello' }
  #
  _exprAsFunction = (expr) ->
    if _.isFunction(expr)
      fn = expr

    else if _.isString(expr)
      if /^\s*function\s+/.test(expr)
        # expr is a string containing a function expression
        fn = expr

      else
        # we have a bare string e.g. "true", or "jQuery == undefined"
        if expr.indexOf('return ') == -1
          # add a "return" function
          fn = "function () { return #{expr} }"
        else
          # the expression already contains a "return"; note that it may be
          # compound statement eg "console.log('yo'); return true"
          fn = "function () { #{expr} }"
      
    else
      @assert(false, "Expression #{expr} must be a function, or a string")

    # console.log("expr: ", expr.yellow, "=>", fn.green)

    return fn

  #
  # _matches
  #
  #  Returns true if a `against` matches `value`. The `against` variable
  #  can be a string or regular expression.
  #
  #  If `isEqualFallback` is true then we also try `_.isEqual`.
  #
  _matches = (against, value, isEqualFallback=false) ->
    if typeof against == 'string'
      regex = new RegExp("^#{against}$")
    else if _.isRegExp(against)
      regex = against
    else if isEqualFallback
      if toString.call(value) == "[object RuntimeArray]"
        # normalize the RuntimeArray type. This type is what arrays returned
        # from casper.evaluate tend to be, and _.isEqual will say it is
        # not equal to an Array class even if the values are otherwise
        # identical.
        value = _.toArray(value)

      return _.isEqual(against, value)
    else
      throw new Error("Test received #{against}, but expected string"
        + " or regular expression.")

    # console.log("RegExp", regex, "value", value)
    return regex.test(value)
  
  #
  # _get_attrs
  # ~~~~~~~~~~
  #
  # Return all values of `attr` on `selector` in the DOM.
  #
  #
  #
  _get_attrs = (selector, attr) ->
    fn = (selector, _attr) ->
      _casper_chai_elements = __utils__.findAll(selector)
      _casper_attrs = []
      Array.prototype.forEach.call(_casper_chai_elements, (e) ->
        _casper_attrs.push(e.getAttribute(_attr))
      )
      return _casper_attrs

    attrs = casper.evaluate(fn,
      _selector: selector
      _attr: attr
    )

    return attrs


  ###
    Chai Tests
    ----------

    The following are the tests that are added onto Chai Assertion.
  ###
  
  

  
  ###
    @@@@ attr(attribute_name)

    True when the attribute `attribute_name` on `selector` is true.
  
    If the selector matches more than one element with the attribute set, this
    will fail. In those cases [attrAll](#attrall) or [attrAny](#attrany).


    ```javascript
    expect("#my_header").to.have.attr('class')
    ```
  ###
  _addMethod 'attr', (attr) ->
    selector = @_obj

    attrs = _get_attrs(selector, attr)

    assert.equal(attrs.length, 1,
      "Expected #{selector} to have one match, but it had #{attrs.length}")

    attr_v = attrs[0]

    @assert(attr_v,
      "Expected selector #{selector} to have attribute #{attr}, but it did not",
      "Expected selector #{selector} to not have attribute #{attr}, " +
        "but it was #{attr_v}"
    )

  ###
    @@@@ attrAny(attribute_name)

    True when an attribute is set on at least one of the given selectors.

    ```javascript
    expect("div.menu li").to.have.attrAny('selected')
    ```
  ###
  _addMethod 'attrAny', (attr) ->
    selector = @_obj
    attrs = _get_attrs(selector, attr)

    @assert(_.any(attrs),
      "Expected one element matching selector #{selector} to have attribute" +
        "#{attr} set, but none did",
      "Expected no elements matching selector #{selector} to have attribute" +
        "#{attr} set, but at least one did"
    )

  ###
    @@@@ attrAll(attribute_name)

    True when an attribute is set on all of the given selectors.

    ```javascript
    expect("div.menu li").to.have.attrAll('class')
    ```
  ###
  _addMethod 'attrAll', (attr) ->
    selector = @_obj
    attrs = _get_attrs(selector, attr)

    @assert(_.all(attrs),
      "Expected all elements matching selector #{selector} to have attribute" +
        "#{attr} set, but one did not have it",
      "Expected one elements matching selector #{selector} to not have " +
        " attribute #{attr} set, but they all had it"
    )

  ###
    @@@@ fieldValue
    

    True when the named input provided has the given value.

    Wraps Casper's `__utils__.getFieldValue(selector)`.

    Examples:

    ```javascript
    expect("name_of_input").to.have.fieldValue("123");
    ```
  ###
  _addMethod 'fieldValue', (givenValue) ->
    selector = @_obj

    if _.isString(selector)
      # TODO switch to a generic selector [name=selector]
    else
      # FIXME when we use a generic selector, always do this check
      expect(selector).to.be.inDOM

    # FIXME should use something like getFieldValue from casperjs::clientutils
    # but with all selectors
    get_remote_value = (selector) ->
      return __utils__.getFieldValue(selector)

    remoteValue = casper.evaluate(get_remote_value, selector: selector)

    @assert(remoteValue == givenValue,
      "expected field(s) #{selector} to have value #{givenValue}, " +
        "but it was #{remoteValue}",
      "expected field(s) #{selector} to not have value #{givenValue}, " +
        "but it was"
    )

  ###
    @@@@ inDOM

    True when the given selector is in the DOM


    ```javascript
      "#target".should.be.inDOM;
    ```

  Note: We use "inDOM" instead of "exist" so we don't conflict with
  the chai.js BDD.

  ###
  _addProperty 'inDOM', () ->
    selector = @_obj
    @assert(casper.exists(selector),
        'expected selector #{this} to be in the DOM, but it was not',
        'expected selector #{this} to not be in the DOM, but it was'
    )

  ###
    @@@@ loaded

    True when the given resource exists in the phantom browser.

    ```javascript
    expect("styles.css").to.not.be.loaded
    "jquery-1.8.3".should.be.loaded
    ```
  ###
  _addProperty 'loaded', ->
    resourceTest = @_obj
    @assert(casper.resourceExists(resourceTest),
        'expected resource #{this} to exist, but it does not',
        'expected resource #{this} to not exist, but it does'
    )

  ###
    @@@@ matchOnRemote

    Compare the remote evaluation to the given expression, and return
    true when they match. The expression can be a string or a regular
    expression. The evaluation is the same as for
    [`trueOnRemote`](#trueonremote).

    ```javascript
    expect("return 123").to.matchOnRemote(123)

    "typeof jQuery".should.not.matchOnRemote('undefined')

    "123.toString()".should.matchOnRemote(/\d+/)
    ```
    
    or an example in CoffeeScript

    ```coffeescript
    (-> typeof jQuery).should.not.matchOnRemote('undefined')
    ```
  ###
  _addMethod 'matchOnRemote', (matcher) ->
    expr = @_obj

    fn = _exprAsFunction(expr)

    remoteValue = casper.evaluate(fn)

    @assert(_matches(matcher, remoteValue, true),
      "expected #{@_obj} (#{fn} = #{remoteValue}) to match #{matcher}",
      "expected #{@_obj} (#{fn}) to not match #{matcher}, but it did"
    )

  ###
    @@@@ matchTitle

    True when the the title matches the given regular expression,
    or where a string is used match that string exactly.

    ```javascript
    expect("Google").to.matchTitle;
    ```
  ###
  _addProperty 'matchTitle', ->
    matcher = @_obj

    title = casper.getTitle()
    @assert(_matches(matcher, title),
        'expected title #{this} to match #{exp}, but it did not',
        'expected title #{this} to not match #{exp}, but it did',
    )

  ###
    @@@@ matchCurrentUrl

    True when the current URL matches the given string or regular expression

    ```javascript
      expect(/https:\/\//).to.matchCurrentUrl;
    ```
  ###
  _addProperty 'matchCurrentUrl', ->
    matcher = @_obj
    currentUrl = casper.getCurrentUrl()
    @assert(_matches(matcher, currentUrl),
      'expected url #{exp} to match #{this}, but it did not',
      'expected url #{exp} to not match #{this}, but it did'
    )

  ###
    @@@@ tagName

    All elements matching the given selector are one of the given tag names.

    In other words, given a selector, all tags must be one of the given tags.
    Note that those tags need not appear in the selector.

    ```javascript
    ".menuItem".has.tagName('li')

    "menu li *".has.tagName(['a', 'span'])
    ```
  ###
  _addMethod 'tagName', (ok_names) ->
    selector = @_obj

    if _.isString(ok_names)
      ok_names = [ok_names]
    else if not _.isArray(ok_names)
      assert.ok(false, "tagName must be a string or list, it was " +
          typeof ok_names)

    _get_tagnames = (selector) ->
      fn = (selector, _attr) ->
        _casper_chai_elements = __utils__.findAll(selector)
        _casper_tags = []
        Array.prototype.forEach.call(_casper_chai_elements, (e) ->
          _casper_tags.push(e.tagName.toLowerCase())
        )
        return _casper_tags

      _tagnames = casper.evaluate(fn, _selector: selector)
      return _tagnames

    tagnames = _get_tagnames(selector)

    diff = _.difference(tagnames, ok_names)

    @assert(diff.length == 0,
      "Expected #{selector} to have only tags #{ok_names}, but there was" +
        "tag(s) #{diff} appeared",
      "Expected #{selector} to have tags other than #{ok_names}, but " +
        "those were the only tags that appeared",
    )

  ###
    @@@@ textInDOM

    The given text can be found in the phantom browser's DOM.

    ```javascript
    "search".should.be.textInDOM
    ```
  ###
  _addProperty 'textInDOM', ->
    needle = @_obj
    haystack = casper.evaluate ->
      document.body.textContent or document.body.innerText

    @assert(haystack.indexOf(needle) != -1,
      'expected text #{this} to be in the document, but it was not'
      'expected text #{this} to not be in the document, but it was found'
    )

  ###
    @@@@ textMatch

    The text of the given selector matches the expression (a string
    or regular expression).

    ```javascript
      expect("#element").to.have.textMatch(/case InSenSitIvE/i);
    ```
  ###
  _addMethod 'textMatch', (matcher) ->
    selector = @_obj
    text = casper.fetchText(selector)
    @assert(_matches(matcher, text),
      "expected '#{selector}' to match #{matcher}, but it was \"#{text}\"",
      "expected '#{selector}' to not match #{matcher}, but it did"
    )

  ###
    @@@@ trueOnRemote

    The given expression evaluates to true on the remote page. Expression may
    be a function, a function string, or a simple expression. Where a function
    is passed in, the return value is tested. Where a simple expression is
    passed in it is wrapped in 'function () {}', with a 'return' statement
    added if one is not already included, and this wrapped function is
    evaluated as an ordinary function would be.

    ```javascript
    "true".should.be.trueOnRemote;

    expect("true").to.be.trueOnRemote;

    (function() { return false }).should.not.be.trueOnRemote;

    expect("function () { return true }").to.be.trueOnRemote;

    expect("return false").to.not.be.trueOnRemote;

    var foo = function () { return typeof jQuery == typeof void 0; )
    foo.should.be.trueOnRemote; // unless Query is installed.

    expect("function () { return 1 == 0 }").to.not.be.trueOnRemote;
    ```
  ###
  _addProperty 'trueOnRemote', () ->
    expr = @_obj

    fn = _exprAsFunction(expr)

    remoteValue = casper.evaluate(fn)

    # console.log("returns".magenta, remoteValue)

    @assert(remoteValue,
      "expected expression #{@_obj} to be true, but it was #{remoteValue}",
      "expected expression #{@_obj} to not be true, but itw as #{remoteValue}"
    )

  ###
    @@@@ visible

    The selector matches a visible element.

    ```javascript
    expect("#hidden").to.not.be.visible
    ```
  ###
  _addProperty 'visible', () ->
    selector = @_obj
    expect(selector).to.be.inDOM
    @assert(casper.visible(selector),
        'expected selector #{this} to be visible, but it was not',
        'expected selector #{this} to not be, but it was'
    )


#
# "Module systems magic dance"
#
if (typeof require == "function" and
    typeof exports == "object" and
    typeof module == "object")
  # NodeJS
  module.exports = casperChai
else if (typeof define == "function" and define.amd)
    # AMD
  define(() -> return casperChai)
else
  # Other environment (usually <script> tag):
  # plug in to global chai instance directly.
  chai.use(casperChai)


