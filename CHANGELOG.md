# Changelog

## 0.1.0

First public release, consumed by `git` reference to the tag `v0.1.0`.

- `BackendServer` over `dart:io`, with a request body limit (`maxBodySize`), an error boundary that answers a
  generic `500`, `onError` reporting and a graceful `close()` that waits for in-flight requests and their hooks.
- `Request` / `Response` with typed per-request context (`RequestContext`, no `Zone`) and LIFO cleanup hooks
  that run after the response is fully written, including streamed bodies and client disconnects.
- `Pipeline` of interceptors, folded once at startup, with short-circuit.
- Radix/trie `Router`: static routes, `:param`, `*wildcard`, `404` and `405` with `Allow`.
- Middlewares: `cors()`, `requestLogger()`, `securityHeaders()`.
- No database dependency.
