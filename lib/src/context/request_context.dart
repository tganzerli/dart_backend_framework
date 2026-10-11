import 'package:meta/meta.dart';

/// A lightweight, high-performance heterogeneous context container.
///
/// Designed explicitly to avoid the asynchronous overhead of Dart [Zone] /
/// `ZoneValues`, which introduces measurable latency tax across microtasks
/// under high throughput (>15,000 req/s).
///
/// Values can be keyed either by their static [Type] or by an explicit key.
@sealed
final class RequestContext {
  // Created on the first `set`: most requests do not use the context.
  Map<Object, Object?>? _data;

  /// Creates a new, empty [RequestContext], or pre-populates it from [initial].
  RequestContext([Map<Object, Object?>? initial])
      : _data = initial != null && initial.isNotEmpty
            ? Map<Object, Object?>.of(initial)
            : null;

  Map<Object, Object?> get _store => _data ??= <Object, Object?>{};

  /// Stores [value] indexed by its concrete type [T].
  ///
  /// Subsequent calls to [get] with type [T] will retrieve this instance.
  void set<T extends Object>(T value) {
    _store[T] = value;
  }

  /// Stores [value] under an explicit [key].
  void setKey<T>(Object key, T value) {
    _store[key] = value;
  }

  /// Retrieves the value of type [T].
  ///
  /// Throws [StateError] if no value of type [T] has been registered.
  T get<T extends Object>() {
    final value = _data?[T];
    if (value == null) {
      throw StateError('Context entry not found for type: $T');
    }
    return value as T;
  }

  /// Retrieves the value of type [T], or returns `null` if not found.
  T? getOrNull<T extends Object>() => _data?[T] as T?;

  /// Retrieves the value associated with [key], or returns `null` if not found.
  T? getKeyOrNull<T>(Object key) => _data?[key] as T?;

  /// Checks whether an entry for type [T] is present in this context.
  bool has<T extends Object>() => _data?.containsKey(T) ?? false;

  /// Checks whether an entry for [key] is present in this context.
  bool hasKey(Object key) => _data?.containsKey(key) ?? false;

  /// Removes the entry for type [T] from the context.
  T? remove<T extends Object>() => _data?.remove(T) as T?;

  /// Removes the entry for [key] from the context.
  Object? removeKey(Object key) => _data?.remove(key);

  /// Clears all entries from this context.
  void clear() => _data?.clear();

  /// Returns the number of entries stored in this context.
  int get length => _data?.length ?? 0;

  /// Whether the context has no entries.
  bool get isEmpty => length == 0;

  /// Whether the context has at least one entry.
  bool get isNotEmpty => length != 0;

  /// Returns a shallow clone of this [RequestContext].
  RequestContext clone() => RequestContext(_data);
}
