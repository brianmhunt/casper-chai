/* casper-chai version 0.1.5 */

// -- from: lib/casper-chai.coffee -- \\

/*
  Chai assertions for CasperJS
  ============================

  Copyright (C) 2012 Brian M Hunt

  Repository: http://github.com/brianmhunt/casper-chai.git
  License: MIT (see LICENSE.txt)
*/


(function() {
  var casperChai;

  casperChai = function(_chai, utils) {
    var assert, methods, properties, _addMethod, _addProperty, _exprAsFunction, _matches;
    properties = [];
    methods = [];
    assert = _chai.assert;
    /*
        Utilities
        ---------
    */

    _addProperty = function(name, func) {
      return _chai.Assertion.addProperty(name, func);
    };
    _addMethod = function(name, method) {
      return _chai.Assertion.addMethod(name, method);
    };
    /*
        @@@@ _exprAsFunction
    
        Given an expression, turn it in to something that can be
        evaluated remotely.
    
        `expr` may be
        
        1. a bare string e.g. "false" or "return true";
    
        2. a function string e.g. "function () { return true }"
    
        3. an actual function e.g. function () { return 'hello' }
    */

    _exprAsFunction = function(expr) {
      var fn;
      if (_.isFunction(expr)) {
        fn = expr;
      } else if (_.isString(expr)) {
        if (/^\s*function\s+/.test(expr)) {
          fn = expr;
        } else {
          if (expr.indexOf('return ') === -1) {
            fn = "function () { return " + expr + " }";
          } else {
            fn = "function () { " + expr + " }";
          }
        }
      } else {
        this.assert(false, "Expression " + expr + " must be a function, or a string");
      }
      return fn;
    };
    /*
        @@@@ _matches
    
        Returns true if a `against` matches `value`. The `against` variable
        can be a string or regular expression.
    
        If `isEqualFallback` is true then we also try `_.isEqual`.
    */

    _matches = function(against, value, isEqualFallback) {
      var regex;
      if (isEqualFallback == null) {
        isEqualFallback = false;
      }
      if (typeof against === 'string') {
        regex = new RegExp("^" + against + "$");
      } else if (_.isRegExp(against)) {
        regex = against;
      } else if (isEqualFallback) {
        if (toString.call(value) === "[object RuntimeArray]") {
          value = _.toArray(value);
        }
        return _.isEqual(against, value);
      } else {
        throw new Error("Test received " + against + ", but expected string", +" or regular expression.");
      }
      return regex.test(value);
    };
    /*
        Chai Tests
        ----------
    
        The following are the tests that are added onto Chai Assertion.
    */

    /*
        @@@@ fieldValue
        
    
        True when the named input provided has the given value.
    
        Wraps Casper's `__utils__.getFieldValue(selector)`.
    
        Examples:
    
        ```javascript
        expect("name_of_input").to.have.fieldValue("123");
        ```
    */

    _addMethod('fieldValue', function(givenValue) {
      var get_remote_value, remoteValue, selector;
      selector = this._obj;
      if (_.isString(selector)) {

      } else {
        expect(selector).to.be.inDOM;
      }
      get_remote_value = function(selector) {
        return __utils__.getFieldValue(selector);
      };
      remoteValue = casper.evaluate(get_remote_value, {
        selector: selector
      });
      return this.assert(remoteValue === givenValue, ("expected field(s) " + selector + " to have value " + givenValue + ", ") + ("but it was " + remoteValue), ("expected field(s) " + selector + " to not have value " + givenValue + ", ") + "but it was");
    });
    /*
        @@@@ inDOM
    
        True when the given selector is in the DOM
    
    
        ```javascript
          "#target".should.be.inDOM;
        ```
    
      Note: We use "inDOM" instead of "exist" so we don't conflict with
      the chai.js BDD.
    */

    _addProperty('inDOM', function() {
      var selector;
      selector = this._obj;
      return this.assert(casper.exists(selector), 'expected selector #{this} to be in the DOM, but it was not', 'expected selector #{this} to not be in the DOM, but it was');
    });
    /*
        @@@@ loaded
    
        True when the given resource exists in the phantom browser.
    
        ```javascript
        expect("styles.css").to.not.be.loaded
        "jquery-1.8.3".should.be.loaded
        ```
    */

    _addProperty('loaded', function() {
      var resourceTest;
      resourceTest = this._obj;
      return this.assert(casper.resourceExists(resourceTest), 'expected resource #{this} to exist, but it does not', 'expected resource #{this} to not exist, but it does');
    });
    /*
        @@@@ matchOnRemote
    
        Compare the remote evaluation to the given expression, and return
        true when they match. The expression can be a string or a regular
        expression. The evaluation is the same as for
        [`trueOnRemote`](#trueonremote).
    
        ```javascript
        expect("return 123").to.matchOnRemote(123)<br/>
    
        "typeof jQuery".should.not.matchOnRemote('undefined')
        ```
        
        or an example in CoffeeScript
    
        ```coffeescript
        (-> typeof jQuery).should.not.matchOnRemote('undefined')
        ```
    */

    _addMethod('matchOnRemote', function(matcher) {
      var expr, fn, remoteValue;
      expr = this._obj;
      fn = _exprAsFunction(expr);
      remoteValue = casper.evaluate(fn);
      return this.assert(_matches(matcher, remoteValue, true), "expected " + this._obj + " (" + fn + " = " + remoteValue + ") to match " + matcher, "expected " + this._obj + " (" + fn + ") to not match " + matcher + ", but it did");
    });
    /*
        @@@@ matchTitle
    
        True when the the title matches the given regular expression,
        or where a string is used match that string exactly.
    
        ```javascript
        expect("Google").to.matchTitle;
        ```
    */

    _addProperty('matchTitle', function() {
      var matcher, title;
      matcher = this._obj;
      title = casper.getTitle();
      return this.assert(_matches(matcher, title), 'expected title #{this} to match #{exp}, but it did not', 'expected title #{this} to not match #{exp}, but it did');
    });
    /*
        @@@@ matchCurrentUrl
    
        True when the current URL matches the given string or regular expression
    
        ```javascript
          expect(/https:\/\//).to.matchCurrentUrl;
        ```
    */

    _addProperty('matchCurrentUrl', function() {
      var currentUrl, matcher;
      matcher = this._obj;
      currentUrl = casper.getCurrentUrl();
      return this.assert(_matches(matcher, currentUrl), 'expected url #{exp} to match #{this}, but it did not', 'expected url #{exp} to not match #{this}, but it did');
    });
    /*
        @@@@ textInDOM
    
        The given text can be found in the phantom browser's DOM.
    
        ```javascript
        "search".should.be.textInDOM
        ```
    */

    _addProperty('textInDOM', function() {
      var haystack, needle;
      needle = this._obj;
      haystack = casper.evaluate(function() {
        return document.body.textContent || document.body.innerText;
      });
      return this.assert(haystack.indexOf(needle) !== -1, 'expected text #{this} to be in the document, but it was not', 'expected text #{this} to not be in the document, but it was found');
    });
    /*
        @@@@ textMatch
    
        The text of the given selector matches the expression (a string
        or regular expression).
    
        ```javascript
          expect("#element").to.have.textMatch(/case InSenSitIvE/i);
        ```
    */

    _addMethod('textMatch', function(matcher) {
      var selector, text;
      selector = this._obj;
      text = casper.fetchText(selector);
      return this.assert(_matches(matcher, text), "expected '" + selector + "' to match " + matcher + ", but it did not", "expected '" + selector + "' to not match " + matcher + ", but it did");
    });
    /*
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
    */

    _addProperty('trueOnRemote', function() {
      var expr, fn, remoteValue;
      expr = this._obj;
      fn = _exprAsFunction(expr);
      remoteValue = casper.evaluate(fn);
      return this.assert(remoteValue, "expected expression " + this._obj + " to be true, but it was " + remoteValue, "expected expression " + this._obj + " to not be true, but itw as " + remoteValue);
    });
    /*
        @@@@ visible
    
        The selector matches a visible element.
    
        ```javascript
        expect("#hidden").to.not.be.visible
        ```
    */

    return _addProperty('visible', function() {
      var selector;
      selector = this._obj;
      expect(selector).to.be.inDOM;
      return this.assert(casper.visible(selector), 'expected selector #{this} to be visible, but it was not', 'expected selector #{this} to not be, but it was');
    });
  };

  if (typeof require === "function" && typeof exports === "object" && typeof module === "object") {
    module.exports = casperChai;
  } else if (typeof define === "function" && define.amd) {
    define(function() {
      return casperChai;
    });
  } else {
    chai.use(casperChai);
  }

}).call(this);
