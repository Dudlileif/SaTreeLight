# SaTreeLight

Continuation of the project at [SaTreeLight/SaTreeLight](https://github.com/satreelight/satreelight).

The updated application is hosted [here](https://dudlileif.github.io/apps/satreelight).

## Build

To generate potentially missing files you need to invoke the `build_runner`

> `dart run build_runner build`

To update generated files automatically when saving changes, run

> `dart run build_runner watch --delete-conflicting-output`.

The [data](data) directory must be copied and placed next to the built executable
or `index.html` after builds.

## Credits

Contains polygon data from OpenStreetMap, available under the Open Database License, © [OpenStreetMap](https://www.openstreetmap.org/copyright) contributors.
