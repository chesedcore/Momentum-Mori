class_name WaveData extends Resource

enum BladeType {
	UNINIT_MONARCH_FORGOT_TO_ADD_STUFF_GO_KILL_HIS_ASS,
	ANGRY_GUY,
	AOE_GUY,
	CLONE_GUY,
	DRACULA_HIMSELF,
	SOME_GUY,
	PROJECTILE_GUY,
	SWORD_GUY,
}

@export var enemy_map: Dictionary[BladeType, int] = {
	BladeType.UNINIT_MONARCH_FORGOT_TO_ADD_STUFF_GO_KILL_HIS_ASS: 0
}
