class_name Tools

static func flatten_array[T](arr: Array) -> T {
	var value = arr
	while value is Array {
		value = value[0]
	}
	return value as T
}
