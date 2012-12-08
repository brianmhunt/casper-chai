
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
    var _matches;
    _matches = function(string_or_regex, value) {
      var regex;
      console.log();
      if (typeof string_or_regex === 'string') {
        regex = new RegExp("^" + string_or_regex + "$");
      } else if (Object.prototype.toString.call(string_or_regex).indexOf('RegExp') !== -1) {
        regex = string_or_regex;
      } else {
        throw new Error("Test received " + string_or_regex + ", but expected string", +" or regular expression.");
      }
      return regex.test(value);
    };
    _chai.Assertion.addProperty('inDOM', function() {
      var selector;
      selector = this._obj;
      return this.assert(casper.exists(selector), 'expected selector #{this} to be in the DOM, but it was not', 'expected selector #{this} to not be in the DOM, but it was');
    });
    _chai.Assertion.addProperty('isVisible', function() {
      var selector;
      selector = this._obj;
      expect(selector).to.be.inDOM;
      return this.assert(casper.visible(selector), 'expected selector #{this} to be visible, but it was not', 'expected selector #{this} to not be, but it was');
    });
    _chai.Assertion.addProperty('isLoaded', function() {
      var resourceTest;
      resourceTest = this._obj;
      return this.assert(casper.resourceExists(resourceTest), 'expected resource #{this} to exist, but it does not', 'expected resource #{this} to not exist, but it does');
    });
    _chai.Assertion.addProperty('matchTitle', function() {
      var matcher, title;
      matcher = this._obj;
      title = casper.getTitle();
      return this.assert(_matches(matcher, title), 'expected title #{this} to match #{exp}, but it did not', 'expected title #{this} to not match #{exp}, but it did');
    });
    _chai.Assertion.addProperty('matchCurrentUrl', function() {
      var currentUrl, matcher;
      matcher = this._obj;
      currentUrl = casper.getCurrentUrl();
      return this.assert(_matches(matcher, currentUrl), 'expected url #{exp} to match #{this}, but it did not', 'expected url #{exp} to not match #{this}, but it did');
    });
    _chai.Assertion.addProperty('textInDOM', function() {
      var haystack, needle;
      needle = this._obj;
      haystack = casper.evaluate(function() {
        return document.body.textContent || document.body.innerText;
      });
      return this.assert(haystack.indexOf(needle) !== -1, 'expected text #{this} to be in the document, but it was not', 'expected text #{this} to not be in the document, but it was found');
    });
    return _chai.Assertion.addProperty("evalTrue", function() {
      var fn, subject;
      subject = this._obj;
      fn = function() {
        var val;
        return val = casper.evaluate(subject);
      };
      return this.assert(fn, 'expected selector #{this} to be in the DOM, but it was not', 'expected selector #{this} to not be in the DOM, but it was');
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
