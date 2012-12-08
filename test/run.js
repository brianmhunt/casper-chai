#!/usr/bin/env casperjs

if (!phantom.casperLoaded) {
    console.log('This script must be invoked using the casperjs executable');
    phantom.exit(1);
}

var fs          = require('fs'),
  colorizer     = require('colorizer'),
  utils         = require('utils'),
  cwd           = fs.workingDirectory,
  serverPort    = 8523, // the port where we create a server
  testServer    = "http://localhost:"+serverPort,
  any_failures  = false, // true when there has been a failure
  casper;


/* Change to the /test directory
 *
 * Figure out where we are by looking for package.json
 */
if (fs.exists(cwd + "/package.json")) {
  // we are in casper-chai
  fs.changeWorkingDirectory("test");
} else if (fs.exists(cwd + "/../package.json")) {
  // we are in casper-chai/*/ (likely * = test)
  fs.changeWorkingDirectory("../test");
} else {
  // oh for __file__.
  console.log("run.js must be called from casper-chai or casper-chai/test");
  casper.exit(1);
}

/*
 * Include modules that were installed with npm.
 */
function require_node_module(name) {
  var node_modules, pkg, pkg_main;
  node_modules = "../node_modules/";

  pkg = JSON.parse(fs.read(node_modules + name + "/package.json"));
  pkg_main = node_modules + name + "/" + pkg.main;
  return require("./" + pkg_main);
}

/*
 * Load dependencies
 */
_ = require_node_module("lodash");
_.str = require_node_module('underscore.string');
$ = require_node_module('jquery');
require_node_module('icolor');


/*
 * While we could use an npm module for the following, it's a pain because
 * PhantomJS does not have some modules (eg 'path') that Node does.
 *
 * The simple solution we use is to download a "pre-compiled" coffee-script.
 */
phantom.injectJs("../contrib/coffee-script.js"); // creates CoffeeScript
require('../contrib/mocha');
chai = require("../contrib/chai");

/* chai-isms
 */
assert = chai.assert;
expect = chai.expect;

// we don't get much debugging info on the console, so this can be helpful
chai.Assertion.includeStack = true;

// FIXME: the following throws
//      RangeError: Maximum call stack size exceeded.
// should = chai.should();

/*
 * Create the casper object we'll use for testing
 */
casper = require('casper').create({
    exitOnError: false,
    pageSettings: {
        loadImages: false,
        loadPlugins: false
    },
    onLoadError: function (err) {
      console.log("Unable to load resource: ".redbg.white + err);
    },
    onTimeout: function (err) {
      console.log(("Timeout: " + err).redbg.white);
    },
    // logLevel: 'debug',
    // verbose: true,
});

/*
 * Create a custom Mocha reporter.
 * 
 * See conversation at https://github.com/n1k0/casperjs/issues/278
 */
function CasperReporter(runner) {
  var self = this,
    stats = this.stats = {
        suites: 0,
        tests: 0,
        passes: 0,
        pending: 0,
        failures: 0
    },
    failures = [],
    indents = 0,
    symbols = {
      ok: '✓',
      err: '✖',
      middot: '•',
      dot: '․'
    };

  function indent(str) {
      return _.str.pad("", 2 * indents) + str;
  }

  if (!runner) {
      return;
  }

  this.runner = runner;
  runner.stats = stats;

  runner.on('start', function() {});

  runner.on('suite', function(suite) {
    console.log("\n" + indent(suite.title.cyan.underline));
    ++indents;
  });

  runner.on('suite end', function(suite) {
      --indents;
      if (1 === indents) {
          console.log();
      }
  });

  runner.on('test', function(test) {
    console.log("\n" + indent(symbols.middot + " " + test.title));
  });

  runner.on('pending', function(){
    console.log(indent("pending ".magenta + test.title));
  });

  runner.on('pass', function(test){
      console.log(indent(symbols.ok + " (" + test.title + ")").green);
      stats.passes++;
  });

  runner.on('fail', function(test, err){
    stats.failures++;
    test.err = err;
    failures.push(test);
    console.log(indent(symbols.err + " (" + test.title + ")").red +
      ": " + err);
  });

  runner.on('test end', function(test){
    stats.tests = stats.tests || 0;
    stats.tests++;
  });

  runner.on('end', function(){
    if (stats.failures) {
      msg = (stats.failures + " tests failed").red;
      any_failures = true;
    } else {
      msg = "All tests passed".green;
    }
    msg = "\n" + msg + " (" + stats.tests + " tests run).";
    console.log(msg);
  });
}

/*
 * Set up Mocha with our custom reporter and BDD-style settings
 */
mocha.setup({
  ui: 'bdd',
  reporter: CasperReporter
});

/*
 * After every Mocha test we flush the Casper 'steps' stack.
 *
 * Because afterEach calls the asynchronous Casper steps, the actual
 * those tests can be synchronous. All Casper tests will occur in this
 * afterEach.
 */
afterEach(function (done) {
  // There is no need to print here b/c mocha test emit will
  // capture.
  if (casper.steps.length) {
    // There's work to be done.
    casper.run(function () { done(); });
  } else {
    // Nothing to see here. Move along.
    done();
  }
});

/*
 * Set up some color logging.
 */
casper.on('http.status.200', function(resource) {
    console.log("[HTTP 200]".greenbg.black + " <" + resource.url.green + ">");
});

casper.on('http.status.404', function(resource) {
    console.log("[HTTP 404]".redbg.black + " <" + resource.url.red + ">");
});

casper.on('http.status.500', function(resource) {
    console.log("[HTTP 500]".redbg.black + " <" + resource.url.red + ">");
});

//
// Capture remote log messages
//
casper.on('remote.message', function(msg) {
  console.log(">>> ".cyan + msg.bluebg.yellow);
});

// Set up casperChai.
// TODO: option to use ../lib/casper-chai (i.e. unbuilt coffeescript)
casperChai = require("../build/casper-chai");
chai.use(casperChai);

/*
 * Load all the .coffee files
 */
_.each(fs.list("./"), function (specFile) {
  // grep out files that do not end with .coffee
  if (!_.str.endsWith(specFile, ".coffee")) {
    return;
  }

  console.log("Loading", specFile.yellow);
  
  // the specFiles contain the tests i.e. describe(..., it ...)
  CoffeeScript.run(fs.read(specFile));
});


/* Patch Function.prototype.bind
 *
 * Workaround for PhantomJS 1.7.0 bug
 * http://code.google.com/p/phantomjs/issues/detail?id=522
 *
 * The following function is from:
 * https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Global_Objects/Function/bind
 */
if (!Function.prototype.bind) {
  Function.prototype.bind = function (oThis) {
    if (typeof this !== "function") {
      // closest thing possible to the ECMAScript 5 internal IsCallable function
      throw new TypeError("Function.prototype.bind - what is trying to be bound is not callable");
    }
 
    var aArgs = Array.prototype.slice.call(arguments, 1), 
        fToBind = this, 
        fNOP = function () {},
        fBound = function () {
          return fToBind.apply(this instanceof fNOP && oThis
              ? this
              : oThis,
              aArgs.concat(Array.prototype.slice.call(arguments)));
        };
 
    fNOP.prototype = this.prototype;
    fBound.prototype = new fNOP();
 
    return fBound;
  };
}
/*
 * Start Mongoose webserver
 * https://github.com/ariya/phantomjs/wiki/API-Reference
 */ 
require('webserver').create().listen(serverPort, function (request, response) {
  var fileToRead, content;
  response.statusCode = 200;

  /* For what should be obvious reasons, don't leave this running. 
   */
  fileToRead = "./" + _.str.strRightBack(request.url, "/");

  if (fileToRead.indexOf('..') !== -1) {
    response.statusCode = 403; // forbidden
    response.write("Forbidden: " + fileToRead);
  }

  console.log("[testServer:".inverse + fileToRead.inverse + "]".inverse);

  content = fs.read(fileToRead);
  response.write(content);

  response.close();
});

console.log("Started test webserver on localhost:".yellow + 
    String(serverPort).yellow);




/*
 * Start casper.
 */
casper.start();

// here we go.
mocha.run(function () {
  casper.exit(any_failures);
});

