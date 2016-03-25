module.exports = function(chai, utils) {
  function matches(against, value) {
    return against instanceof RegExp ? against.test(value) : against === value
  }

  /*
    Language Chains
    ----------

    @@@@ element

    A language chain that sets an `element` flag that tells other casper-chai
    assertions to not require all elements to match the criteria, but at least one.

    ```javascript
    expect("ul.header li").to.have.an.element.with.attr('aria-selected')
    ```

    In this example, the assertion with pass if any `li` has the `aria-selected` attribute.
    Otherwise, by default `attr` will assert that all elements matched have that attribute.
  */
  chai.Assertion.addProperty('element', function() {
    return utils.flag(this, 'element', true)
  })

  /*
    @@@@ evaluate

    Change the assertion subject to the result of the expression evaluated
    in the page. An expression may be a function, a function string, or a simple expression.
    When a string is passed in it is wrapped in 'function () {}', with a 'return' statement
    added if one is not already included, and this wrapped function is
    evaluated as an ordinary function would be. When it is a function it is simply
    evaluated in the page as is.

    ```javascript
    "true".should.evaluate.to.true;

    (function() { return false }).should.evaluate.to.false;

    expect("function () { return true }").to.evaluate.to.true;

    "document.querySelectorAll('body').length".should.evaluate.to.be.at.least(1);

    var foo = function () { return typeof jQuery ; )
    expect(foo).to.evaluate.to.be.undefined; // unless jQuery is installed.

    "0 === -0".should.evaluate.to.be.false.wat
    ```
  */
  chai.Assertion.addProperty('evaluate', function() {
    var expr = utils.flag(this, 'object')
    if (typeof expr === 'string' && !/^\s*function\s+/.test(expr)) {
      if (expr.indexOf('return ') === -1) {
        expr = 'function () { return ' + expr + ' }'
      } else {
        expr = 'function () { ' + expr + ' }'
      }
    }
    return utils.flag(this, 'object', casper.evaluate(expr))
  })
  /*
    Casper-Chai Assertions
    ----------

    The following are the assertion tests that are added onto `Chai.Assertion`.
  */

  /*
    @@@@ attr(attributeName) / attribute(attributeName)

    Asserts that attribute `attribute_name` are on all elements matched by `selector`.
    If the `element` chain was used, it asserts that any element has that selector.

    ```javascript
    expect("#my_header").to.have.attr('class')
    expect("ul.header li").to.have.an.element.with.attribute('aria-selected')
    ```

    It also changes the subject of the assertion to the attributes, so you can do
    further assertions on those attributes

    ````javascript
    "#tabs li a".should.have.an.element.with.attribute('aria-selected')[0].that.equals('true')
    "section a.add".should.have.attr('data-bind')[0].and.contains('click:')
    ````
  */
  var assertAttr = function(attr) {
    var selector = this._obj,
        attrs = casper.getElementsAttribute(selector, attr)
    if (utils.flag(this, 'element')) {
      this.assert(attrs.some(function(a) {
        return a
      }), ('Expected some elements matching selector ' + selector + ' to have attribute') + ('' + attr + ' set, but none did'), ('Expected no elements matching selector ' + selector + ' to have attribute') + ('' + attr + ' set, but at least one did'))
    } else {
      this.assert(attrs.every(function(a) {
        return a
      }), ('Expected all elements matching selector ' + selector + ' to have attribute ') + ('' + attr + ' set, but some did not have it'), ('Expected no elements matching selector ' + selector + ' to have attribute ') + ('' + attr + ' set, but some had it'))
    }
    return utils.flag(this, 'object', attrs)
  }
  chai.Assertion.addMethod('attr', assertAttr)
  chai.Assertion.addMethod('attribute', assertAttr)

  /*
    @@@@ fieldValue


    True when the named input provided has the given value.

    Wraps Casper's `__utils__.getFieldValue(inputName)`.

    Examples:

    ```javascript
    expect("name_of_input").to.have.fieldValue("123");
    ```
  */
  chai.Assertion.addMethod('fieldValue', function(givenValue) {
    var name = this._obj,
    remoteValue = casper.evaluate(function(n) {
      return __utils__.getFieldValue(n)
    }, name)
    return this.assert(remoteValue === givenValue, ('expected field(s) ' + name + ' to have value ' + givenValue + ', ') + ('but it was ' + remoteValue), ('expected field(s) ' + name + ' to not have value ' + givenValue + ', ') + 'but it was')
  })

  /*
    @@@@ inDOM

    True when the given selector is in the DOM


    ```javascript
      "#target".should.be.inDOM;
    ```

  Note: We use "inDOM" instead of "exist" so we don't conflict with
  the chai.js BDD.
  */
  chai.Assertion.addProperty('inDOM', function() {
    var selector = this._obj
    return this.assert(casper.exists(selector), 'expected selector ' + selector + ' to be in the DOM, but it was not', 'expected selector ' + selector + ' to not be in the DOM, but it was')
  })

  /*
    @@@@ loaded

    True when the given resource exists in the phantom browser.

    ```javascript
    expect("styles.css").to.not.be.loaded
    "jquery-1.8.3".should.be.loaded
    ```
  */
  chai.Assertion.addProperty('loaded', function() {
    return this.assert(casper.resourceExists(this._obj), 'expected resource ' + this._obj + ' to exist, but it does not', 'expected resource ' + this._obj + ' to not exist, but it does')
  })

  /*
    @@@@ matchTitle

    True when the the title matches the given regular expression,
    or where a string is used match that string exactly.

    ```javascript
    expect("Google").to.matchTitle;
    ```
  */
  chai.Assertion.addProperty('matchTitle', function() {
    var matcher = this._obj,
        title = casper.getTitle()
    return this.assert(matches(matcher, title), 'expected title ' + matcher + ' to match ' + title + ', but it did not', 'expected title ' + matcher + ' to not match ' + title + ', but it did')
  })

  /*
    @@@@ matchCurrentUrl

    True when the current URL matches the given string or regular expression

    ```javascript
      expect(/https:\/\//).to.matchCurrentUrl;
    ```
  */
  chai.Assertion.addProperty('matchCurrentUrl', function() {
    var matcher = this._obj,
        currentUrl = casper.getCurrentUrl()
    return this.assert(matches(matcher, currentUrl), 'expected url ' + currentUrl + ' to match ' + this + ', but it did not', 'expected url ' + currentUrl + ' to not match ' + this + ', but it did')
  })
  /*
    @@@@ tagName

    All elements matching the given selector are one of the given tag names.

    In other words, given a selector, all tags must be one of the given tags.
    Note that those tags need not appear in the selector.

    ```javascript
    ".menuItem".should.have.tagName('li')

    "menu li *".should.have.tagName(['a', 'span'])
    ```
  */
  chai.Assertion.addMethod('tagName', function(ok_names) {
    var selector = this._obj
    if (typeof ok_names === 'string') {
      ok_names = [ok_names]
    } else if (!Array.isArray(ok_names)) {
      throw new Error('tagName must be a string or list, it was ' + typeof ok_names);
    }

    var tagnames = casper.evaluate(function(selector) {
      return Array.prototype.map.call(__utils__.findAll(selector), function(e) {
        return e.tagName.toLowerCase()
      })
    }, selector)

    var diff = tagnames.filter(function(t) {
      return ok_names.indexOf(t) < 0
    })

    return this.assert(diff.length === 0, ('Expected ' + selector + ' to have only tags [' + ok_names + '], but there was ') + ('also tag(s) [' + diff + ']'), ('Expected ' + selector + ' to have tags other than [' + ok_names + '], but ') + 'those were the only tags that appeared')
  })

  /*
    @@@@ textInDOM

    The given text can be found in the phantom browser's DOM.

    ```javascript
    "search".should.be.textInDOM
    ```
  */
  chai.Assertion.addProperty('textInDOM', function() {
    var needle = this._obj,
    haystack = casper.evaluate(function() {
      return document.body.textContent || document.body.innerText
    })
    return this.assert(haystack.indexOf(needle) !== -1, 'expected text ' + needle + ' to be in the document, but it was not', 'expected text ' + needle + ' to not be in the document, but it was found')
  })

  /*
    @@@@ text

    The text of the given selector matches the expression if it is a regular expression,
    or is equal to the text, if a string.

    It supports the `contains` and `include` language chain to do partial matching

    ```javascript
      expect("#element").to.have.text(/case InSenSitIvE/i);
      expect("#element").to.have.text("Welcome to My Site");
      expect("#element").to.contain.text("Welcome");
    ```
  */
  chai.Assertion.addMethod('text', function(matcher) {
    var selector = this._obj,
    text = casper.fetchText(selector)

    if (utils.flag(this, 'contains') && typeof matcher === 'string') {
      return this.assert((text != null ? text.indexOf(matcher) : void 0) >= 0, 'expected \'' + selector + '\' to contain ' + matcher + ', but it was "' + text + '"', 'expected \'' + selector + '\' to not contain ' + matcher + ', but it did')
    } else {
      var verb = matcher instanceof RegExp ? 'contain' : 'be'
      return this.assert(matches(matcher, text), 'expected \'' + selector + '\' to ' + verb + ' ' + matcher + ', but it was "' + text + '"', 'expected \'' + selector + '\' to not ' + verb + ' ' + matcher + ', but it did')
    }
  })

  /*
    @@@@ visible

    The selector matches a visible element.

    ```javascript
    expect("#hidden").to.not.be.visible
    ```
  */
  chai.Assertion.addProperty('visible', function() {
    var selector = this._obj
    return this.assert(casper.visible(selector), 'expected selector ' + selector + ' to be visible, but it was not', 'expected selector ' + selector + ' to not be visible, but it was')
  })
}
