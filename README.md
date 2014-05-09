fishpond-client
===============

JavaScript client for Fishpond/iFish.io


## Testing

Tests are written in nodeunit coffeescript and can be found in the `/test`
directory. To run the tests locally just do:

```
$ grunt test
```


## Building

To build the fishpond client on your machine, first you need to install all the
modules:

```
$ npm install
```

Once that's done, you can run:

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
