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

    <form action=''>
      <input id='afield' name='anamedfield' value='42' />
    </form>
  </body>
</html>"
      response.close()

    casper.start "http://localhost:8523/"

  describe "the attr method", ->
    it "matches 'class' by id", ->
      casper.then ->
        expect("#waldo").to.have.attr('class')

    it "matches class by id", ->
      casper.then ->
        expect("#waldo").to.not.have.attr('classless')

    it 'returns false where attribute is empty', ->
      casper.then ->
        expect("#waldo").to.not.have.attr("data-empty")

    it 'fails when more than one attribute is returned', ->
      casper.then ->
        # two div classes have 'class'; explicitly fail - use attrAny or
        # attrAll
        failed = false
        try
          expect("div").to.not.have.attr('class')
        catch err
          failed = true

        failed.should.be.true

  describe "the attrAny method", ->
    it "finds one div with an 'id' attribute", ->
      casper.then ->
        expect('div').to.have.attrAny("id")

    it "finds divs with an 'class' attribute", ->
      casper.then ->
        # all divs have the class attribute
        expect('div').to.have.attrAny("class")

    it "finds no divs with an 'data-empty' attribute", ->
      casper.then ->
        expect('div').to.not.have.attrAny("data-empty")

  describe "the attrAll method", ->
    it "finds not all divs have an 'id' attribute", ->
      casper.then ->
        expect('div').to.not.have.attrAll('id')

    it "finds that all divs have a 'class' attribute", ->
      casper.then ->
        expect("div").to.have.attrAll('class')

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

  describe "the isTextInDOM property", ->
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

  describe "the hasFieldValue method", ->
    it "matches anamedfield's value of 42", ->
      casper.then ->
        expect("anamedfield").to.have.fieldValue("42")

  describe "the textMatch method", ->
    it "matches #waldo's with a regular expression (/says/)", ->
      casper.then ->
        expect("#waldo").to.have.textMatch(/says/)

    it "matches a case insensitive regex expression (/says/i)", ->
      casper.then ->
        expect("#waldo").to.have.textMatch(/SAYS/i)

    it "matches multiple selectors with a regular expression", ->
      casper.then ->
        expect("div.says").to.have.textMatch(/says/)

    it "does not match multiple selectors against a given selection", ->
      casper.then ->
        expect("div.says").to.not.have.textMatch(/said/)

    it "matches a text string exactly", ->
      casper.then ->
        expect("#waldo").to.have.textMatch("Simon says")

    it "does not match a partial string", ->
      casper.then ->
        expect("#waldo").to.not.have.textMatch("Simon says, also")
        expect("#waldo").to.not.have.textMatch("Simon")

  describe "the trueOnRemote method", ->
    it "catches true function expressions", ->
      casper.then ->
        expect("function () { return true; }").to.be.trueOnRemote.and.be.ok

    it "catches true simple expressions", ->
      casper.then ->
        expect("return true").to.be.trueOnRemote

    it "catches untrue simple expressions", ->
      casper.then ->
        expect("false").to.not.be.trueOnRemote

    it "catches untrue function expressions", ->
      casper.then ->
        expect("function () { return false; }").to.not.be.trueOnRemote

    it "catches true function", ->
      casper.then ->
        expect(-> true).to.be.trueOnRemote

    it "catches false function", ->
      casper.then ->
        expect(-> 0).to.not.be.trueOnRemote

    it "test for jQuery", ->
      casper.then ->
        expect(-> typeof jQuery == typeof undefined).to.be.trueOnRemote

  describe "the matchOnRemote", ->
    it "correctly compares equal strings", ->
      casper.then ->
        expect("return \"hello\"").to.matchOnRemote("hello")

    it "correctly compares string to regular expression", ->
      casper.then ->
        expect("return \"hello\"").to.matchOnRemote(/HELLO/i)

    it "correctly compares simple expression to string", ->
      casper.then ->
        expect("\"hello\"").to.matchOnRemote("hello")

    it "correctly compares unequal strings", ->
      casper.then ->
        expect("\"hello\"").to.not.matchOnRemote("hZllo")
        expect(-> "hello").to.not.matchOnRemote(/hZllo/)

    it "compares arrays with deep equal", ->
      casper.then ->
        expect("[1,2,3]").to.matchOnRemote([1,2,3])

        # TODO: raw object/array [1,2,3].should.matchOnRemote?
        (-> [42,16,17]).should.matchOnRemote([42,16,17])

    it "compares unequal arrays with deep equal", ->
      casper.then ->
        (-> [42,16,17]).should.not.matchOnRemote([42,17,16])

    it "compares integers", ->
      casper.then ->
        expect(-> 42).to.matchOnRemote(42)

    it "compares returned value with a regular expression", ->
      casper.then ->
        expect(-> "aBcDe").to.matchOnRemote(/AbCdE/i)

    it "compares floats", ->
      casper.then ->
        # -0.29999999999999893 ~= -0.3
        expect(-> 13.3 - 13.6).to.matchOnRemote(13.3 - 13.6)

    it "compares objects with deep equal", ->
      casper.then ->
        expect(-> {a:1,b:2}).to.matchOnRemote({b:2,a:1})

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
        expect(-> typeof jQuery).to.matchOnRemote("undefined")

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
