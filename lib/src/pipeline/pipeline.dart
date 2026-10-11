import 'handler.dart';
import 'interceptor.dart';

/// Functional chaining builder for middlewares and interceptors.
///
/// Allows composing a sequence of [InterceptorFunction] or [Interceptor] instances around
/// a root [Handler].
///
/// Composition is performed at application setup time (`addHandler`), producing a single,
/// directly chained closure. During steady-state request processing, no auxiliary list or
/// iterator cursor is allocated.
final class Pipeline {
  final List<InterceptorFunction> _interceptors = <InterceptorFunction>[];

  /// Creates a new empty [Pipeline] instance.
  Pipeline();

  /// Registers an interceptor function [interceptor] at the end of the pipeline.
  ///
  /// Returns the [Pipeline] instance itself for chained calls.
  Pipeline add(InterceptorFunction interceptor) {
    _interceptors.add(interceptor);
    return this;
  }

  /// Ergonomic alias for [add].
  Pipeline addMiddleware(InterceptorFunction interceptor) => add(interceptor);

  /// Registers an object-oriented [Interceptor] instance in the pipeline.
  Pipeline addInterceptor(Interceptor interceptor) {
    _interceptors.add(interceptor.intercept);
    return this;
  }

  /// Completes the pipeline by attaching the terminal [rootHandler].
  ///
  /// Returns a single [Handler] that runs the interceptors in FIFO order on request entry
  /// and in LIFO order on response exit (onion model).
  ///
  /// If any interceptor returns a `Response` without invoking `next(request)`, the pipeline
  /// performs an immediate *short-circuit*, skipping downstream handlers.
  Handler addHandler(Handler rootHandler) {
    var current = rootHandler;

    for (var i = _interceptors.length - 1; i >= 0; i--) {
      final interceptor = _interceptors[i];
      final next = current;
      current = (request) => interceptor(request, next);
    }

    return current;
  }
}
