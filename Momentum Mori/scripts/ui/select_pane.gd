class_name StageSelect extends Control

signal cascaded_out
signal enter_this_stage(stage: StageData)

var current_stage: StageData

@export var previous: Btn
@export var next: Btn
@export var back: Btn
@export var select: Btn
@export var enemy_portrait: TextureRect
@export var boss_name_label: HiFidelityLabel

@export var select_cascade: CascadeV3

var needs_init := false

static func from(idx: int) -> StageSelect {
	var s := Registry.create_stage_select()
	s.update_data_using(Stages.get_stage_by_idx(idx).unwrap())
	s.needs_init = true
	return s
}

func _ready() -> void {
	_wire_up_signals()
	
	if needs_init {
		animate_data_using_stage(current_stage)
	} else { 
		get_current_stage() 
	}
}

func get_current_stage() -> StageData {
	if not current_stage {
		mend_stage_into_default()
	}
	return current_stage
}

func mend_stage_into_default() -> void {
	print("No current stage found, mending into default level 0!")
	update_using(Stages.get_stage_by_idx(0).unwrap())
}

func _wire_up_signals() -> void {
	back.hovered.connect(func(): back.move_to_front())
	select.hovered.connect(func(): select.move_to_front())
	previous.clicked.connect(_on_previous_clicked)
	next.clicked.connect(_on_next_clicked)
	back.clicked.connect(cascade_out)
	select.clicked.connect(_on_select_clicked)
}

func _on_select_clicked() -> void {
	cascade_out_to_new_stage()
}

func _on_previous_clicked() -> void {
	var this_stage := get_current_stage()
	update_using(Stages.get_previous_modulo_stage(this_stage))
}

func _on_next_clicked() -> void {
	var this_stage := get_current_stage()
	update_using(Stages.get_next_modulo_stage(this_stage))
}

func cascade_out() -> void {
	select_cascade.cascade_out()
	select_cascade.cascade_out_chain_finished.connect(
		_on_cascaded_out, CONNECT_ONE_SHOT
	)
}

func cascade_out_to_new_stage() -> void {
	select_cascade.cascade_out()
	select_cascade.cascade_out_chain_finished.connect(
		enter_this_stage.emit.bind(get_current_stage()),
		CONNECT_ONE_SHOT
	)
}

func _on_cascaded_out() -> void {
	cascaded_out.emit()
	queue_free.call_deferred()
}

func update_data_using(using_stage: StageData) -> void {
	current_stage = using_stage
}

func update_using(using_stage: StageData) -> void {
	if using_stage == current_stage {
		return
	}
	
	animate_data_using_stage(using_stage)
}

func animate_data_using_stage(using_stage: StageData) -> void {
	current_stage = using_stage
	boss_name_label.morph_into(using_stage.get_boss_name())
	enemy_portrait.texture = using_stage.get_boss_texture().unwrap()
}
