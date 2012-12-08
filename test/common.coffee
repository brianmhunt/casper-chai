

describe "the Casper-Chai addons to Chai", ->
  it "includes the 'inDOM' property", ->
    casper.open "simple.html" # local fiel

    casper.then ->
      expect("#header_1").to.be.inDOM
      expect("#not_in_dom").to.not.be.inDOM

  it "includes 'isVisible' property", ->
    casper.then ->
      expect("#header_1").to.be.visible
      expect("#waldo").to.not.be.visible

  it "includes 'isTextInDOM' property", ->
    casper.then ->
      expect("THEODORE ROOSEVELT").to.be.textInDOM
      expect("THEODORE ROOSEVELt").to.not.be.textInDOM

  it "includes 'matchTitle' property", ->
    casper.then ->
      expect(/Title/).to.matchTitle
      expect(/^Title/).to.not.matchTitle
      expect("Title").to.not.matchTitle
      expect("The Title").to.matchTitle

  it "includes the 'matchCurrentUrl' property", ->
    casper.then ->
      expect(/simple.html/).to.matchCurrentUrl
      expect(/some_remote_host/).to.not.matchCurrentUrl

      expect(casper.getCurrentUrl()).to.matchCurrentUrl
      expect(casper.getCurrentUrl()+"X").to.not.matchCurrentUrl


  it "is easy to test HttpStatus", ->
    casper.then ->
      expect(casper.currentHTTPStatus).to.equal(null) # we loaded from a file

    casper.thenOpen testServer + "/simple.html" # "remote" file

    casper.then ->
      expect(casper.currentHTTPStatus).to.equal(200) # we loaded over http


