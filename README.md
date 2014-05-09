fishpond-client
===============

JavaScript client for Fishpond/iFish.io

To work directly on this library, you'll need to have [npm]() installed, and
install all the development dependencies locally with:

```
$ npm install
```


## Testing

Tests are written in nodeunit coffeescript and can be found in the `/test`
directory. To run the tests locally just do:

```
$ grunt test
```

## Building

Building is easy, you just do:

```
$ grunt build
```

Which will clean up old build files and rebuild everything from scratch.


## Releasing

__Note:__ This step is only for contributors with write-access to this
repository.

Release management is easy, once you're finished writing your new features and
everything is tested and merged onto master, simply run one of the following
(depending on what sort of release you're doing):

```
$ grunt release:patch
$ grunt release:minor
$ grunt release:major
```

These tasks will test, bump the version (as specified), rebuild the JavaScript,
commit the new build, tag the commits and push everything back to Github.
