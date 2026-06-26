class_name Tools

static func flatten_array[T](arr: Array) -> T {
	var value = arr
	while value is Array {
		value = value[0]
	}
	return value as T
}

static func reciprocal_inverse(f: float) -> float {
	return 1.0 / f
}

static func try_disconnect(sig: Signal, fn: Callable) -> void {
	if sig.is_connected(fn) {
		sig.disconnect(fn)
	}
}
