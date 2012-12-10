###
# Unit-tests for Casper-Chai
#
###
# TODO: Test 'loaded'

describe "Casper-Chai addons to Chai", ->
  before ->
    casper.open "simple.html" # local file

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
        expect("THEODORE ROOSEVELT").to.be.textInDOM

    it "does not find text that is not in the DOM", ->
      casper.then ->
        expect("THEODORE ROOSEVELt").to.not.be.textInDOM

  describe "the matchTitle property", ->
    it "matches a regular expression (/Title/)", ->
      casper.then ->
        expect(/Title/).to.matchTitle

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
      "#header_1".should.be.inDOM
      "#header_X".should.not.be.inDOM

  describe.skip "TDD 'assert' framework", ->
    it "should have bound methods inDOM and others", ->
      assert.inDOM("#header_1")


  describe "the matchCurrentUrl property", ->
    it "matches /simple.html/", ->
      casper.then ->
        expect(/simple.html/).to.matchCurrentUrl

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
        expect("function () { return true; }").to.be.trueOnRemote

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

    it "compares arrays with _.isEqual", ->
      casper.then ->
        expect("[1,2,3]").to.matchOnRemote([1,2,3])

        # TODO: raw object/array [1,2,3].should.matchOnRemote?
        (-> [42,16,17]).should.matchOnRemote([42,16,17])

    it "compares unequal arrays", ->
      casper.then ->
        (-> [42,16,17]).should.not.matchOnRemote([42,17,16])

    it "compares integers (with _.isEqual)", ->
      casper.then ->
        expect(-> 42).to.matchOnRemote(42)

    it "compares floats (with _.isEqual)", ->
      casper.then ->
        # -0.29999999999999893 ~= -0.3
        expect(-> 13.3 - 13.6).to.matchOnRemote(13.3 - 13.6)

    it "compares objects (with _.isEqual)", ->
      casper.then ->
        expect(-> {a:1,b:2}).to.matchOnRemote({b:2,a:1})

  describe "trivial tests", ->
    before -> casper.open "simple.html"

    it "to check for HttpStatus", ->
      casper.then ->
        expect(casper.currentHTTPStatus).to.equal(null) # we loaded from a file

      casper.thenOpen testServer + "/simple.html" # "remote" file

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

        expect('jquery-1.8.3').to.not.be.loaded


    it "checks for jQuery loaded by CDN", ->
      casper.then ->
        casper.waitStart()
        casper.page.includeJs(jQueryCDN, ->
          console.log("\t(Loaded #{jQueryCDN.green})")
          casper.waitDone()
        )

        # includeJs is basically equivalent to:
        # v = document.createElement("script");
        # v.src = "http://code.jquery.com/jquery-1.8.3.min.js";
        # document.body.appendChild(v);

      casper.then ->
        expect(-> typeof jQuery).to.not.matchOnRemote("undefined")
        (-> typeof jQuery).should.not.matchOnRemote('undefined')
        expect('jquery-1.8.3.min.js').to.be.loaded





