class_name Vector1 extends RefCounted

var x: float

static func from(p_x: float) -> Vector1 {
	var vec := new()
	vec.x = p_x
	return vec
}
