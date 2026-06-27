extends Node2D

@export var stages: Array[StageData]

func get_stage_by_idx(idx: int) -> Option[StageData] {
	if idx >= stages.size() or idx < 0 {
		return Option.none()
	}
	
	return Option.some(stages[idx])
}

func find_stage_idx(stage_data: StageData) -> Option[int] {
	var idx := stages.find(stage_data)
	if idx == -1 {
		return Option.none()
	}
	return Option.some(idx)
}

func get_stage_by_modulo(idx: int, offset := 0) -> StageData {
	assert(not stages.is_empty(), "stages is empty!")
	idx = posmod(idx+offset, stages.size())
	return get_stage_by_idx(idx).unwrap()
}

func get_next_modulo_stage(stage: StageData) -> StageData {
	var idx := find_stage_idx(stage).unwrap()
	return get_stage_by_modulo(idx, 1)
}

func get_previous_modulo_stage(stage: StageData) -> StageData {
	var idx := find_stage_idx(stage).unwrap()
	return get_stage_by_modulo(idx, -1)
}
