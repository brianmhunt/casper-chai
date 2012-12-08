
describe "the casperChai addons to Chai", ->

  it "includes the 'inDOM' property", ->
    casper.open "simple.html"
    casper.then ->
      expect("#header_1").to.be.inDOM
      expect("#hello").to.not.be.inDOM



