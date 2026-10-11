import 'dart:async';

import '../request/request.dart';
import '../response/response.dart';

/// A function that handles an incoming [Request] and produces a [Response].
typedef Handler = FutureOr<Response> Function(Request request);

/// Callback passed to an [Interceptor] to delegate to the next handler/interceptor.
typedef NextFunction = FutureOr<Response> Function(Request request);
