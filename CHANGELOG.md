## 0.2.0
* Removed CLI alternative service wrapper because of experimental state and implemented a variant with nodo instead, which should be faster and more reliable.
* Updates from node gamedig 4.x to 5.x, which has some breaking changes, e.g.
  * changed game type names, e.g. `quake3` -> `q3a`
  * changes query parametesr, e.g. `maxAttempts` -> `maxRetries`
  * and more ...
* The returned is a new Object `GameDig::QueryResult` instead of a raw Hash now, which provides access by methods on first level, but can also be converted to a Hash by `#to_h`.
* Now support all parameters for the CLI variant, as well for the nodo variant.

## 0.1.0
* Initial release with basic CLI wrapper and experimental service wrapper using a tiny node webservice.
* Service variant supports only a subset of parameters for now: `type, host, protocol`.
* Based on gamedig 4.x.