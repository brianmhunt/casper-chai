

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

  it "is easy to test HttpStatus", ->
    casper.then ->
      expect(casper.currentHTTPStatus).to.equal(null) # we loaded from a file

    casper.thenOpen testServer + "/simple.html" # "remote" file

    casper.then ->
      expect(casper.currentHTTPStatus).to.equal(200) # we loaded over http


