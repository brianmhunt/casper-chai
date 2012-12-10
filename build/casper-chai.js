/* casper-chai version 0.1.3 */

// -- from: lib/casper-chai.coffee -- \\

/*
Chai assertions for CasperJS

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

    /*
        Returns true if a given string_or_regex matches the given value
    */

    _matches = function(string_or_regex, value) {
      var regex;
      if (typeof string_or_regex === 'string') {
        regex = new RegExp("^" + string_or_regex + "$");
      } else if (_.isRegExp(string_or_regex)) {
        regex = string_or_regex;
      } else {
        throw new Error("Test received " + string_or_regex + ", but expected string", +" or regular expression.");
      }
      return regex.test(value);
    };
    _addProperty = function(name, func) {
      return _chai.Assertion.addProperty(name, func);
    };
    _addMethod = function(name, method) {
      return _chai.Assertion.addMethod(name, method);
    };
    /*
        Given an expression, turn it in to something that can be
        evaluated remotely.
    
        expr may be
        
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
        Chai Tests
        ----------
    
        The following are the tests that are added onto Chai Assertion.
    */

    /*
        fieldValue
        ~~~~~~~~~~
    
        Wraps the __utils__.getFieldValue(selector)
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
    _addProperty('inDOM', function() {
      var selector;
      selector = this._obj;
      return this.assert(casper.exists(selector), 'expected selector #{this} to be in the DOM, but it was not', 'expected selector #{this} to not be in the DOM, but it was');
    });
    _addProperty('loaded', function() {
      var resourceTest;
      resourceTest = this._obj;
      return this.assert(casper.resourceExists(resourceTest), 'expected resource #{this} to exist, but it does not', 'expected resource #{this} to not exist, but it does');
    });
    /*
        matchOnRemote
        ~~~~~~~~~~~~~~
    */

    _addMethod('matchOnRemote', function(matcher) {
      var expr, fn, remoteValue;
      expr = this._obj;
      fn = _exprAsFunction(expr);
      remoteValue = casper.evaluate(fn);
      return this.assert(_matches(matcher, remoteValue), "expected " + this._obj + " (" + fn + " = " + remoteValue + ") to match " + matcher, "expected " + this._obj + " (" + fn + ") to not match " + matcher + ", but it did");
    });
    _addProperty('matchTitle', function() {
      var matcher, title;
      matcher = this._obj;
      title = casper.getTitle();
      return this.assert(_matches(matcher, title), 'expected title #{this} to match #{exp}, but it did not', 'expected title #{this} to not match #{exp}, but it did');
    });
    _addProperty('matchCurrentUrl', function() {
      var currentUrl, matcher;
      matcher = this._obj;
      currentUrl = casper.getCurrentUrl();
      return this.assert(_matches(matcher, currentUrl), 'expected url #{exp} to match #{this}, but it did not', 'expected url #{exp} to not match #{this}, but it did');
    });
    _addProperty('textInDOM', function() {
      var haystack, needle;
      needle = this._obj;
      haystack = casper.evaluate(function() {
        return document.body.textContent || document.body.innerText;
      });
      return this.assert(haystack.indexOf(needle) !== -1, 'expected text #{this} to be in the document, but it was not', 'expected text #{this} to not be in the document, but it was found');
    });
    _addMethod('textMatch', function(matcher) {
      var selector, text;
      selector = this._obj;
      text = casper.fetchText(selector);
      return this.assert(_matches(matcher, text), "expected '" + selector + "' to match " + matcher + ", but it did not", "expected '" + selector + "' to not match " + matcher + ", but it did");
    });
    /*
        trueOnRemote
        ~~~~~~~~~~~~
    
        This property is true when the given expression is true on the remote.
    
        For example:
    
            "true".should.be.trueOnRemote
    
        or
    
            (function() { return false }).should.not.be.trueOnRemote
    
        or
    
          expect("function () { return true }").to.be.trueOnRemote
    */

    _addProperty('trueOnRemote', function() {
      var expr, fn, remoteValue;
      expr = this._obj;
      fn = _exprAsFunction(expr);
      remoteValue = casper.evaluate(fn);
      return this.assert(remoteValue, "expected expression " + this._obj + " to be true, but it was " + remoteValue, "expected expression " + this._obj + " to not be true, but itw as " + remoteValue);
    });
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
