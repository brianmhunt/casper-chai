# Casper.JS Assertions for Chai

**Casper–Chai** provides a set of custom assertions for use with [CasperJS][].
You get all the benefits of [Chai][] to test using CasperJS.

Instead of using Casper's Tester:

you can say

```javascript
***
```

### AMD

Casper–Chai supports being used as an [AMD][] module, registering itself
anonymously (just like Chai). So, assuming you have configured your loader to
map the Chai and Casper–Chai files to the respective module IDs `"chai"` and
`"casper-chai"`, you can use them as follows:

[CasperJS]: http://casperjs.org/
[Chai]: http://chaijs.com/
[Mocha]: http://visionmedia.github.com/mocha/
[AMD]: https://github.com/amdjs/amdjs-api/wiki/AMD
