
describe "the casperChai addons to Chai", ->

  it "includes the 'inDOM' property", ->
    casper.open "#{serverAddr}/test"
    casper.then ->
      expect("#hello").to.not.be.inDOM
      expect("#hello").to.not.be.inDOM



