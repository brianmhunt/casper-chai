# Casper.JS Assertions for Chai

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
    <th>Test</th>
    <th>True when ... </th>
    <th>Examples</th>
  </thead>
  <tbody>
    <tr>
      <td>fieldValue(value)</td>
      <td>
        the named input provided has the given value
      </td>
      <td>
        <code>expect("name_of_input").to.have.fieldValue("123");</code>
      </td>
    </tr>
    <tr>
      <td>inDOM </td>
      <td>when the given selector is in the DOM</td>
      <td><code>expect("#target").to.be.inDOM;</code></td>
    </tr>
    <tr>
      <td>loaded</td>
      <td>when the given resource exists</td>
      <td><code>expect("styles.css").to.be.loaded</code></td>
    </tr>
    <tr>
      <td>visible</td>
      <td>the selector matches a visible element</td>
      <td><code>expect("#hidden").to.not.be.visible</code></td>
    </tr>
    <tr>
      <td>matchCurrentUrl</td>
      <td>the current URL matches</td>
      <td><code>expect(/https:\/\//).to.matchCurrentUrl</code></td>
    </tr>
    <tr>
      <td>matchTitle</td>
      <td>the current Title matches</td>
      <td><code>expect("Google").to.matchTitle</code></td>
    </tr>
    <tr>
      <td>textInDOM</td>
      <td>the text can be found in the DOM</td>
      <td><code>expect("search").to.be.textInDOM</code></td>
    </tr>
    <tr>
      <td>textMatch(expression)</td>
      <td>
        the text of the given selector matches the expression (a string
        or regular expression).
      </td>
      <td>
      <code>expect("#element").to.have.textMatch(/case InSenSitIvE/i)</code>
      </td>
    </tr>
  </tbody>
</table>

For more examples, if you are cool with
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


### AMD

Casper–Chai supports being used as an [AMD][] module, registering itself
anonymously (just like Chai).

[CasperJS]: http://casperjs.org/
[Chai]: http://chaijs.com/
[Mocha]: http://visionmedia.github.com/mocha/
[AMD]: https://github.com/amdjs/amdjs-api/wiki/AMD
[npm]: https://npmjs.org/
[Tester]: http://casperjs.org/api.html#tester

