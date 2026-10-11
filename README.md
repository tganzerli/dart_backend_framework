# dart_backend_framework

High-throughput, low-allocation HTTP backend framework for Dart.

## Overview

`dart_backend_framework` is an HTTP transport and execution framework designed to avoid unnecessary
garbage-collector pressure and to stay close to the throughput of raw `dart:io`.

It has no database dependency. Database integrations are separate packages that plug into it, the way
`shelf_router` plugs into `shelf`: [`dart_backend_framework_postgres`](https://github.com/tganzerli/dart_backend_framework_postgres)
adds a per-request row-level-security transaction over
[`dart_db_connector_postgres`](https://github.com/tganzerli/dart_db_connector_postgres). An app depends on the
framework, on the database packages it needs (several are fine) and on the extensions it wants.

**Experimental, not on pub.dev yet.** Install by `git` reference to a tag:

```yaml
dependencies:
  dart_backend_framework:
    git:
      url: https://github.com/tganzerli/dart_backend_framework
      ref: v0.1.0
```

## Core Architecture Principles

1. **High Throughput & Low Allocation (P1/P2)**: Direct streaming to native `HttpResponse` without pre-buffering; minimal intermediate objects in the request critical path.
2. **Type-Safe RequestContext without Zone (P3)**: Heterogeneous O(1) typed storage directly on the `Request` instance, avoiding the asynchronous performance tax of Dart `ZoneValues`.
3. **Composable Pre-Folded Pipeline (P4)**: Interceptors chained and statically folded at server startup with zero per-request allocation overhead and short-circuit support.
4. **Radix/Trie High Performance Router (P5)**: O(k) URL segment lookup with static route precedence, dynamic parameters (`:id`), wildcards (`*path`), 405 Method Not Allowed (`Allow` header) and 404 Not Found.
5. **Guaranteed Lifecycle Cleanup (P6)**: LIFO execution of cleanup hooks (`request.addCleanupHook`) in a `try/finally` that closes only **after the response is fully written** (streamed bodies included), so connections borrowed from pools are released deterministically, also upon uncaught errors or client TCP disconnects.
6. **Decoupled Architecture (P7)**: Database-agnostic web transport; database access lives in the app or in extension packages.

## Quickstart

```dart
import 'dart:io';
import 'package:dart_backend_framework/dart_backend_framework.dart';

void main() async {
  final router = Router();

  router.get('/health', (request) => Response.json({'status': 'ok'}));
  router.get('/users/:id', (request) {
    final id = request.pathParam('id');
    return Response.ok(body: 'User: $id');
  });

  final app = Pipeline()
      .add(securityHeaders())
      .add(requestLogger())
      .addHandler(router.handler);

  final server = await BackendServer.bind(
    handler: app,
    address: InternetAddress.anyIPv4,
    port: 8080,
  );

  print('Server listening on http://localhost:${server.port}');
}
```

## Safety Defaults

* **Body limit:** `request.readAsBytes()` / `readAsString()` / `readAsJson()` reject bodies above
  `maxBodySize` (default 1 MiB) with `PayloadTooLargeException`, answered as `413`. Configure it in
  `BackendServer.bind(maxBodySize: ...)`; `null` disables the limit.
* **Error reporting:** unhandled handler errors and response-write failures go to `onError`
  (default: one line on `stderr`). The client only sees a generic `500`.
* **Response writing:** an invalid header value (e.g. containing `\r\n`) yields a `500` instead
  of a hanging connection.
* **CORS:** `cors()` with `'*'` answers `Access-Control-Allow-Origin: *` and cannot be combined with
  `allowCredentials`. With an explicit list, the request `Origin` is reflected when allowed (plus
  `Vary: Origin`); other origins get no CORS headers. Only `OPTIONS` requests carrying `Origin` and
  `Access-Control-Request-Method` are treated as preflight.
* **Path parameters** are percent-decoded before reaching the handler.

## Example with PostgreSQL

A runnable CRUD server wired to `dart_db_connector_postgres` lives in the
[`dart_backend_framework_postgres`](https://github.com/tganzerli/dart_backend_framework_postgres) repository
(`example/postgres_crud_server.dart`), because it is the package that depends on both.

## License

MIT, see `LICENSE`.
