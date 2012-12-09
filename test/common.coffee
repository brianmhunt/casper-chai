

describe "the Casper-Chai addons to Chai", ->
  before ->
    casper.open "simple.html" # local file

  describe "the inDOM property", ->
    it "matches a selector in the DOM", ->
      casper.then ->
        expect("#header_1").to.be.inDOM

    it "does not match a selector that is not in the DOM", ->
      casper.then ->
        expect("#not_in_dom").to.not.be.inDOM

  describe "the isVisible property", ->
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

  describe "trivial tests", ->
    it "to check for HttpStatus", ->
      casper.then ->
        expect(casper.currentHTTPStatus).to.equal(null) # we loaded from a file

      casper.thenOpen testServer + "/simple.html" # "remote" file

      casper.then ->
        expect(casper.currentHTTPStatus).to.equal(200) # we loaded over http

    it "to check remote content", ->
      casper.then ->
        remote_value = casper.evaluate(-> document.title + "eee")

        expect(remote_value).to.equal("The Titleeee")

