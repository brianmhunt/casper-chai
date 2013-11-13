###
# Unit-tests for Casper-Chai
###
# TODO: Test 'loaded'

describe "Casper-Chai addons to Chai", ->
  before ->
    require("webserver").create().listen 8523, (request, response) ->
      response.writeHead 200,
        "Content-Type": "text/html"

      response.write "<!DOCTYPE html>
<html>
  <head>
    <title>The Title</title>
  </head>
  <body>
    <h1 id=\"header_1\">A Header</h1>

    <blockquote class='tagged'>
      “Do what you can, with what <em>you</em> have, where you are.”
      <small>THEODORE ROOSEVELT.</small>
    </blockquote>

    <div id='waldo' class='says tagged' style='display: none'
      data-empty=''>Simon says</div>

    <div class='says'>Also says</div>
    
    <div class='math'>(1 + 1) = 2</div>

    <form action=''>
      <input id='afield' name='anamedfield' value='42' />
      <input id='anotherfield' name='foo' type='number' />
    </form>
  </body>
</html>"
      response.close()

    casper.start "http://localhost:8523/"

  describe "the attr method", ->
    it "matches 'class' by id", ->
      casper.then ->
        expect("#waldo").to.have.attr('class')

    it 'does not match where attribute is empty', ->
      casper.then ->
        expect("#waldo").to.not.have.attr("data-empty")

    it "finds not all divs have an 'id' attribute", ->
      casper.then ->
        expect('div').to.not.have.attr('id')

    it "finds that all divs have a 'class' attribute", ->
      casper.then ->
        expect("div").to.have.attr('class')

    it 'should change the assertion subject to the attributes', ->
      casper.then ->
        expect('input').to.have.attribute('name').and.deep.equal(['anamedfield', 'foo'])

    describe "with element chain", ->
      it "matches any div with an 'id' attribute", ->
        casper.then ->
          expect('div').to.have.an.element.with.attr("id")

      it "finds divs with an 'class' attribute", ->
        casper.then ->
          # all divs have the class attribute
          expect('div').to.have.an.element.with.attr("class")

      it "finds no divs with an 'data-empty' attribute", ->
        casper.then ->
          expect('div').to.not.have.an.element.with.attr("data-empty")

  describe "the tagName method", ->
    it "finds that the '.says' tags are all 'divs'", ->
      casper.then ->
        expect(".says").to.have.tagName('div')

    it "finds that the .tagged tags are divs and blockquotes", ->
      casper.then ->
        expect(".says").to.have.tagName(['div', 'blockquote'])

    it "finds that the children of blockquotes are em and small tags", ->
      casper.then ->
        expect("blockquote *").to.have.tagName(['em', 'small'])

  describe "the inDOM property", ->
    it "matches a selector in the DOM", ->
      casper.then ->
        expect("#header_1").to.be.inDOM

    it "does not match a selector that is not in the DOM", ->
      casper.then ->
        expect("#not_in_dom").to.not.be.inDOM

  describe "the visible property", ->
    it "matches a visible property", ->
      casper.then ->
        expect("#header_1").to.be.visible

    it "does not match an invisible property", ->
      casper.then ->
        expect("#waldo").to.not.be.visible

  describe "the textInDOM property", ->
    it "finds text somewhere in the DOM", ->
      casper.then ->
        expect("THEODORE ROOSEVELT").to.be.textInDOM.and.be.ok

    it "does not find text that is not in the DOM", ->
      casper.then ->
        expect("THEODORE ROOSEVELt").to.not.be.textInDOM

  describe "the matchTitle property", ->
    it "matches a regular expression (/Title/)", ->
      casper.then ->
        expect(/Title/).to.matchTitle.and.be.ok

    it "does not match an given regular expression (/^Title/)", ->
      casper.then ->
        expect(/^Title/).to.not.matchTitle

    it "matches a given string when equal", ->
      casper.then ->
        expect("The Title").to.matchTitle

    it "does not match a partial title", ->
      casper.then ->
        expect("Title").to.not.matchTitle

  describe "BDD 'should' framework", ->
    it "should include the new asserts", ->
      "#header_1".should.be.inDOM.and.visible.and.ok
      "#header_X".should.not.be.inDOM.and.visible

  describe "the matchCurrentUrl property", ->
    it "matches /localhost/", ->
      casper.then ->
        expect(/localhost/).to.matchCurrentUrl.and.be.ok

    it "does not match /some_remote_host/", ->
      casper.then ->
        expect(/some_remote_host/).to.not.matchCurrentUrl

    it "matches the current url (a string) given by Casper", ->
      casper.then ->
        expect(casper.getCurrentUrl()).to.matchCurrentUrl

    it "does not match a string that is not the current url", ->
      casper.then ->
        expect(casper.getCurrentUrl()+"X").to.not.matchCurrentUrl

  describe "the fieldValue method", ->
    it "matches anamedfield's value of 42", ->
      casper.then ->
        expect("anamedfield").to.have.fieldValue("42")

  describe "the text method", ->
    it "matches #waldo's with a regular expression (/says/)", ->
      casper.then ->
        expect("#waldo").to.have.text(/says/)

    it "matches a case insensitive regex expression (/says/i)", ->
      casper.then ->
        expect("#waldo").to.have.text(/SAYS/i)

    it "matches multiple selectors with a regular expression", ->
      casper.then ->
        expect("div.says").to.have.text(/says/)

    it "does not match multiple selectors against a given selection", ->
      casper.then ->
        expect("div.says").to.not.have.text(/said/)

    it "matches a text string exactly", ->
      casper.then ->
        expect("#waldo").to.have.text("Simon says")
        expect(".math").to.have.text("(1 + 1) = 2")

    it "does not match a partial string", ->
      casper.then ->
        expect("#waldo").to.not.have.text("Simon says, also")
        expect("#waldo").to.not.have.text("Simon")

    it "does match a partial string with contains or include", ->
      casper.then ->
        expect("#waldo").to.contain.text("Simon")
        expect("#waldo").to.include.text("Simon")
        expect("div.says").to.contain.text("Also")

    it "does not falsely match a partial string with contains or include", ->
      casper.then ->
        expect("#waldo").to.not.contain.text("Simon also says")
        expect("#waldo").to.not.include.text("Simon is a monkey")
        expect("div.says").to.not.contain.text("ALSO")

  describe "evaluate language chain", ->
    it "evaluates functions", ->
      casper.then ->
        expect(->
          fruits = strawberry: 'red', orange: 'orange', kiwi: 'green'
          for fruit, color of fruits
            "#{fruit}:#{color}"
        ).to.evaluate.to.deep.equal ['strawberry:red', 'orange:orange', 'kiwi:green']

    it "evaluates function strings", ->
      casper.then ->
        expect("function () { return 'foo'; }").to.evaluate.to.equal 'foo'

    it "evaluates expression strings that contain 'return'", ->
      casper.then ->
        expect("return true").to.evaluate.to.be.true.and.ok

    it "evaluates expression strings that does not contain 'return'", ->
      casper.then ->
        expect("typeof {}").to.evaluate.to.equal('object')

  describe "trivial tests", ->
    before -> casper.start "http://localhost:10777/"

    it "to check for HttpStatus", ->
      casper.then ->
        expect(casper.currentHTTPStatus).to.equal(null) # we loaded from a file

      casper.thenOpen "http://localhost:8523/" # "remote" file

      casper.then ->
        expect(casper.currentHTTPStatus).to.equal(200) # we loaded over http

    it "to check remote content, created by a function remotely executed", ->
      casper.then ->
        remote_value = casper.evaluate(-> document.title + "eee")

        expect(remote_value).to.equal("The Titleeee")

  describe "test for loaded", ->
    it "checks for jQuery when it is not loaded", ->
      casper.then ->
        expect(-> typeof jQuery).to.evaluate.to.equal("undefined")

        expect('jquery-1.8.3').to.not.be.loaded.now

    it "checks for jQuery loaded by CDN", ->
      casper.then ->
        jQueryCDN = 'http://code.jquery.com/jquery-1.8.3.min.js'
        casper.waitStart()
        casper.page.includeJs jQueryCDN, ->
          console.log("\t(Loaded #{jQueryCDN})")
          casper.waitDone()

        # includeJs is basically equivalent to:
        # v = document.createElement("script");
        # v.src = "http://code.jquery.com/jquery-1.8.3.min.js";
        # document.body.appendChild(v);

      casper.then ->
        expect(-> typeof jQuery).to.not.matchOnRemote("undefined")
        (-> typeof jQuery).should.not.matchOnRemote('undefined')
        expect('jquery-1.8.3.min.js').to.be.loaded
