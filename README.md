# Casper.JS Assertions for Chai [![Build Status](https://secure.travis-ci.org/brianmhunt/casper-chai.png?branch=master)](https://travis-ci.org/brianmhunt/casper-chai)

**Casper–Chai** provides a set of custom assertions for use with [CasperJS][].
You get all the benefits of [Chai][] to test with CasperJS.

It is an alternative to Casper's built-in [Tester][].  Instead of using
Casper's Tester you can use (in this case with [Mocha][] and Chai):

    describe("my page", function () {
      it("can be opened by Casper", function () {
        casper.open("http://www.google.com")

        casper.then(function () {
          expect(casper.currentHTTPStatus).to.equal(200);
        });

        casper.then(function () {
          expect("Google").to.matchTitle
        });
      });
    });

### Tests

<table>
  <thead>
    <th>Name</th>
    <th>Description</th>
  </thead>
  <tbody>
    <tr>
      <td><a href='casper-chai/blob/master/build/casper-chai.md#attr'>attr(attr_name)</a></td>
      <td>True when one selector has the given attribute
      </td>
    </tr>
    <tr>
      <td><a href='casper-chai/blob/master/build/casper-chai.md#attrany'>attrAny(attr_name)</a></td>
      <td>True when any selector has the given attribute
      </td>
    </tr>
    <tr>
      <td><a href='casper-chai/blob/master/build/casper-chai.md#attrall'>attrAll(attr_name)</a></td>
      <td>True when all elements matching selector have the given attribute
      </td>
    </tr>
    <tr>
      <td><a href='casper-chai/blob/master/build/casper-chai.md#fieldvalue'>fieldValue(value)</a></td>
      <td>
        the named input provided has the given value
      </td>
    </tr>
    <tr>
      <td><a href='casper-chai/blob/master/build/casper-chai.md#indom'>inDOM</a></td>
      <td>when the given selector is in the DOM</td>
    </tr>
    <tr>
      <td><a href='casper-chai/blob/master/build/casper-chai.md#loaded'>loaded</a></td>
      <td>when the given resource exists</td>
    </tr>
    <tr>
      <td><a href='casper-chai/blob/master/build/casper-chai.md#matchcurrenturl'>matchCurrentUrl</a></td>
      <td>the current URL matches</td>
    </tr>
    <tr>
      <td><a href='casper-chai/blob/master/build/casper-chai.md#matchonremote'>matchOnRemote</a></td>
      <td>compare the remote evaluation to the given expression</td>
    </tr>
    <tr>
      <td><a href='casper-chai/blob/master/build/casper-chai.md#matchtitle'>matchTitle</a></td>
      <td>the current Title matches</td>
    </tr>
    <tr>
      <td><a href='casper-chai/blob/master/build/casper-chai.md#tagname'>tagName(valid_tags)</a></td>
      <td>all elements matching the selectors are one of the given tags</td>
    </tr>
    <tr>
      <td><a href='casper-chai/blob/master/build/casper-chai.md#textindom'>textInDOM</a></td>
      <td>the text can be found in the DOM</td>
    </tr>
    <tr>
      <td><a href='casper-chai/blob/master/build/casper-chai.md#textmatch'>textMatch(expression)</a></td>
      <td>
        the text of the given selector matches the expression (a string
        or regular expression).
      </td>
    </tr>
    <tr>
      <td><a href='casper-chai/blob/master/build/casper-chai.md#trueonremote'>trueOnRemote</a></td>
      <td>the remote expression evaluates to something truthy</td>
    </tr>
    <tr>
      <td><a href='casper-chai/blob/master/build/casper-chai.md#visible'>visible</a></td>
      <td>the selector matches a visible element</td>
    </tr>
  </tbody>
</table>

More [documentation and examples](casper-chai/blob/master/build/casper-chai.md).

For even more examples, if you are cool with
[CoffeeScript](http://coffeescript.org/), check out the [unit
tests](https://github.com/brianmhunt/casper-chai/blob/master/test/common.coffee).


### Installation

Casper-Chai can be installed with [npm][] using `npm install casper-chai`, or
including
[`build/casper-chai.js`](https://raw.github.com/brianmhunt/casper-chai/master/build/casper-chai.js)
in a directory `require` will find it.

Add extensions to Chai with:

    casper_chai = require('casper-chai');
    chai.use(casper_chai);

To build locally, clone the project and run `cake toast test` in the
project directory. You may have to run `npm install` to get dependencies
(which, obviously, requires [npm][] to be installed), and make sure `cake` is
available - which should be possible by running `npm install -g coffee-script`.

### AMD

Casper–Chai supports being used as an [AMD][] module, registering itself
anonymously (just like Chai).

[CasperJS]: http://casperjs.org/
[Chai]: http://chaijs.com/
[Mocha]: http://visionmedia.github.com/mocha/
[AMD]: https://github.com/amdjs/amdjs-api/wiki/AMD
[npm]: https://npmjs.org/
[Tester]: http://casperjs.org/api.html#tester

