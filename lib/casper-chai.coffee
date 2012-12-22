###
  Chai assertions for CasperJS
  ============================

  Copyright (C) 2012 Brian M Hunt

  Repository: http://github.com/brianmhunt/casper-chai.git
  License: MIT (see LICENSE.txt)

###

# TODO/FIXME: Pass the casper instance in (instead of using global casper)

casperChai = (_chai, utils) ->
  assert = _chai.assert
  Assertion = _chai.Assertion
  flag = utils.flag

  class RemoteSelector
    constructor: (@casper, @definition) ->

      # Creates a property for the 'length' so that we can (lazily) calculate
      # the number of elements that match this selector
      Object.defineProperty(@, 'length',
        get: =>
          len_fn = (_selector) ->
            return __utils__.findAll(_selector).length

          return @casper.evaluate(len_fn,
            _selector: @definition
          )
      )

      # simple boolean for testing type
      @isRemoteSelector = true

    #
    # map
    # ~~~
    #
    # Return a map of all elements that match the selector through the
    # given function. The 'this' of the function will be an element matched by
    # selector; any args (an array) passed in will be passed along to the
    # function (with .apply)
    #
    map: (fn, args) ->
      # remote function
      _rfn =  (_selector, _fn, _args) ->
        _casper_chai_elements = __utils__.findAll(_selector)
        _casper_results = []

        #console.log "Remote fn #{_fn}, sel #{_selector}, args: #{_args}"

        Array.prototype.forEach.call(_casper_chai_elements, (element) ->
          _casper_results.push(_fn.apply(element, _args))
        )

        return _casper_results

      # console.log "fn: #{fn}, definition: #{@definition}, args: #{args}"

      mapped = @casper.evaluate(_rfn,
        _selector: @definition,
        _fn: fn,
        _args: args,
      )

      return mapped

    #
    # get_attrs
    # ~~~~~~~~~
    #
    # Get the given attribute on all elements matching the current selector.
    # Returns a list of attributes with each item corresponding to an element
    # in the DOM.
    #
    attrs: (attr) ->
      fn = (_attr) -> @getAttribute(_attr)
      attr_list = @map(fn, [attr])
      return attr_list

    #
    # get_tagnames
    # ~~~~~~~~~~~~
    #
    # Return a list of tagNames for each element matching the current selector
    #
    tagnames: -> @map(-> @tagName)

  #
  # Base class
  # ----------
  #
  class CasperTest
    constructor: (@chai, @casper) ->

    # this should be overloaded for a class that performs tests
    method: ->

    #
    # addToChai
    # ~~~~~~~~~
    #
    # Add a given subclass of CasperTest to the list of tests.
    #
    # This is a class method that can be called without a CasperTest
    # instance ie CasperTest.addToChai.
    #
    @addToChai: (TestClass) ->
      # create an instance so we can test what methods it has
      test = new TestClass

      if _.isFunction(test['chainMethod'])

        # wrap the chain method
        _chainMethod = (args...) ->
          # @ is the chai instance
          casper = flag(@, 'object')
          #
          # TODO: Test to ensure casper is a Casper instance
          #
          test = new TestClass(@, casper)
          test.chainMethod.apply(test, args)

        _method = (args...) ->
          casper = flag(@, 'object')
          test = new TestClass(@, casper)
          test.method.apply(test, args)

        utils.addChainableMethod(Assertion.prototype, test.name,
          _method, _chainMethod)

    #
    # test_against_selector
    # ~~~~~~~~~~~~~~~~~~~~~
    #
    # Perform the given test against the elements matched by this test's
    # selector (the 'object'), honouring the numerosity flags ('one', 'always')
    #
    test_against_selector: (attrs, test_cb, test_description) ->
      sel = @get_selector() # for convenience
      if flag(@chai, 'always')
        @chai.assert(_.all(attrs, test_cb),
          "Expected all elements matching #{sel.definition} to have " +
          test_description + " but at least one did not"
        )

      else
        @chai.assert(_.any(attrs, test_cb),
          "Expected an element matching #{sel.definition} to have " +
          test_description + " but none did"
        )

      if flag(@chai, 'one')
        @chai.assert(_.filter(attrs, test_cb).length == 1,
          "Expected only one element matching #{sel.definition} to " +
          test_description + " but more than one did"
        )


    #
    # get_selector
    # ~~~~~~~~~~~~
    #
    # Return the selector for this set of tests, or a selector for the "html"
    # tag if one is not otherwise given.
    #
    # Tests should look like:
    #   expect(casper).selector("#abc")...
    # where 'selector' changes the 'object' to a Selector class.
    get_selector: ->
      selector = flag(@chai, 'object')

      # if no selector is given, we should use top-level selector of "html"
      if not selector.isRemoteSelector
        selector = new RemoteSelector(@casper, "html")

#      if flag(@chai, 'one')
#        selector_count = selector.length
#
#        @chai.assert(selector_count == 1,
#          "Expected one selector to match '#{selector.definition}', " +
#          "but got #{selector_count}"
#        )

      return selector

  #
  #  Utilities
  #  ---------
  #

  _addProperty = (name, func) ->
    return
    _chai.Assertion.addProperty(name, func)
    # assert[name] = Function.bind(assert, func)

  _addMethod = (name, method) ->
    return
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
  _get_attrs = (selector, attr, _casper) ->
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


  ```javascript
  expect(casper).selector("#header_1").to.have.attr("class")
  expect(casper).selector("#header_1").to.have.attr("class").equal("title")
  ```
  ###
  class AttrTest extends CasperTest
    name: 'attr'

    chainMethod: () ->
      # console.log("Chaining attr")

    method: (attr_name) ->
      # for convenience: our selector
      sel = @get_selector()

      # get the list of attributes e.g. for 'href'
      # ['http://www.example.com', 'https://localhost']
      attrs = sel.attrs(attr_name)

      # the callback that determines which attributes match
      test_cb = (attr) -> attr

      @test_against_selector(attrs, test_cb, "attribute \"#{attr_name}\"")

      # set attrs list as the object for subsequent elements on the chain
      flag(@chai, 'object', attrs)
  CasperTest.addToChai(AttrTest)


  ###
  @@@@ tagName

  ###
  class TagNameTest extends CasperTest
    name: 'tagName'

    chainMethod: ->

    method: (ok_tags) ->
      if _.isString(ok_tags)
        ok_tags = [ok_tags]
      else if not _.isArray(ok_tags)
        assert.ok(false, "tagName must be a string or list, it was " +
            typeof ok_tags)

  CasperTest.addToChai(TagNameTest)
      



  ###
  @@@@ one


  ###
  class OneFlag extends CasperTest
    name: 'one'
    chainMethod: -> flag(@chai, 'one', true)
  CasperTest.addToChai(OneFlag)


  ###
  @@@@ always

  ###
  class AlwaysFlag extends CasperTest
    name: 'always'
    chainMethod: -> flag(@chai, 'always', true)
  CasperTest.addToChai(AlwaysFlag)
      


  ###
  @@@@ selector(css3_selector)

  When chained, returns a selector class with the string passed in, otherwise
  it returns true when the selector is found at least once in the DOM.
  
  expect(casper).selector("#existent_header").attr("class", "title")
  ###
  class SelectorTest extends CasperTest
    name: 'selector'

    chainMethod: (selector) ->
      # ...

    method: (selector) ->
      # console.log "Setting object to RemoteSelector #{selector}"
      flag(@chai, 'object', new RemoteSelector(@casper, selector))

  CasperTest.addToChai(SelectorTest)


      





  ###
    @@@@ attr(attribute_name)

    True when the attribute `attribute_name` on `selector` is true.
  
    If the selector matches more than one element with the attribute set, this
    will fail. In those cases try [attrAll](#attrall) or [attrAny](#attrany).


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


