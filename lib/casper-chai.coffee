###
Chai assertions for CasperJS

Copyright (C) 2012 Brian M Hunt

  Repository: http://github.com/brianmhunt/casper-chai.git
  License: MIT (see LICENSE.txt)

###

# TODO/FIXME: Pass the casper instance in (instead of using global casper)

casperChai = (_chai, utils) ->

  _matches = (string_or_regex, value) ->
    console.log()
    if typeof string_or_regex == 'string'
      regex = new RegExp("^#{string_or_regex}$")
    else if _.isRegExp(string_or_regex)
      regex = string_or_regex
    else
      throw new Error("Test received #{string_or_regex}, but expected string"
        + " or regular expression.")
    return regex.test(value)
    

  # use "inDOM" instead of "exist" so we don't conflict with
  # chai.js bdd
  _chai.Assertion.addProperty 'inDOM', () ->
    selector = @_obj
    @assert(casper.exists(selector),
        'expected selector #{this} to be in the DOM, but it was not',
        'expected selector #{this} to not be in the DOM, but it was'
    )

  # true when given selector is loaded
  _chai.Assertion.addProperty 'isVisible', () ->
    selector = @_obj
    expect(selector).to.be.inDOM
    @assert(casper.visible(selector),
        'expected selector #{this} to be visible, but it was not',
        'expected selector #{this} to not be, but it was'
    )

  # true when document is loaded
  _chai.Assertion.addProperty 'isLoaded', ->
    resourceTest = @_obj
    @assert(casper.resourceExists(resourceTest),
        'expected resource #{this} to exist, but it does not',
        'expected resource #{this} to not exist, but it does'
    )

  # true when the the title matches the given regular expression,
  # or where a string is used match that string exactly.
  _chai.Assertion.addProperty 'matchTitle', ->
    matcher = @_obj

    title = casper.getTitle()
    @assert(_matches(matcher, title),
        'expected title #{this} to match #{exp}, but it did not',
        'expected title #{this} to not match #{exp}, but it did',
    )

  _chai.Assertion.addProperty 'matchCurrentUrl', ->
    matcher = @_obj
    currentUrl = casper.getCurrentUrl()
    @assert(_matches(matcher, currentUrl),
      'expected url #{exp} to match #{this}, but it did not',
      'expected url #{exp} to not match #{this}, but it did'
    )

  _chai.Assertion.addProperty 'textInDOM', ->
    needle = @_obj
    haystack = casper.evaluate ->
      document.body.textContent or document.body.innerText

    @assert(haystack.indexOf(needle) != -1,
      'expected text #{this} to be in the document, but it was not'
      'expected text #{this} to not be in the document, but it was found'
    )

  _chai.Assertion.addMethod 'fieldValue', (givenValue) ->
    selector = @_obj

    if _.isString(selector)
      # TODO switch to a generic selector [name=selector]
    else
      # FIXME when we use a generic selector, always do this check
      expect(selector).to.be.inDOM

    # FIXME should use something like getFieldValue from casperjs::clientutils
    # but with all selectors
    get_remote_value = (selector) ->
      return __utils__.getFieldValue(selector)

    remoteValue = casper.evaluate(get_remote_value, selector: selector)

    @assert(remoteValue == givenValue,
      "expected field(s) #{selector} to have value #{givenValue}, " +
        "but it was #{remoteValue}",
      "expected field(s) #{selector} to not have value #{givenValue}, " +
        "but it was"
    )




#
# "Module systems magic dance"
#
if (typeof require == "function" and
    typeof exports == "object" and
    typeof module == "object")
  # NodeJS
  module.exports = casperChai
else if (typeof define == "function" and define.amd)
    # AMD
  define(() -> return casperChai)
else
  # Other environment (usually <script> tag):
  # plug in to global chai instance directly.
  chai.use(casperChai)


