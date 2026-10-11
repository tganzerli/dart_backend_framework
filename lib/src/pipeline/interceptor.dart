import 'dart:async';

import '../request/request.dart';
import '../response/response.dart';
import 'handler.dart';

/// A middleware/interceptor function in the request processing pipeline.
///
/// Can either short-circuit the request (returning a [Response] immediately)
/// or delegate to downstream handlers by invoking [next].
typedef InterceptorFunction = FutureOr<Response> Function(
  Request request,
  NextFunction next,
);

/// Interface for class-based interceptors.
abstract interface class Interceptor {
  /// Processes [request] and delegates to [next] or short-circuits with a [Response].
  FutureOr<Response> intercept(Request request, NextFunction next);
}
