class_name RecBuff 
extends Buffer

enum {
    POSITION,
    ROTATION,
    VELOCITY,
    CURR_ANI,
    ANIM_POS,
}
const keys: Dictionary = {
    POSITION: "position",
    ROTATION: "rotation",
    VELOCITY: "velocity",
    CURR_ANI: "curr_ani",
    ANIM_POS: "anim_pos",
}
var node_3d: Node3D
var aplayer: AnimationPlayer
var _frame_index := [0,0,0,0,0]


func _write_trans_frame(position: Vector3, rotation: Vector3, velocity: Vector3) -> void:
    update(keys[POSITION], position)
    update(keys[ROTATION], rotation)
    update(keys[VELOCITY], velocity)


func _write_null_ani_frame() -> void:
    update(keys[CURR_ANI], null)
    update(keys[ANIM_POS], 0.0)


func _write_ani_frame(current_animation: StringName, current_animation_position: float) -> void:
    update(keys[CURR_ANI], current_animation)
    update(keys[ANIM_POS], current_animation_position)


func write_frame() -> void:
    _write_trans_frame(node_3d.position, node_3d.rotation, node_3d.velocity)
    if not aplayer: return
    if not aplayer.current_animation: _write_null_ani_frame(); return
    _write_ani_frame(aplayer.current_animation, aplayer.current_animation_position)


func _get_frame_index(key, frame) -> int:
    if frame > store[key].size(): return 0
    var next_value = retrieve(key, frame)
    if next_value is NotaValue:
        return 0
    return frame + 1


func _update_frame_index(store_enum: int) -> void:
    _frame_index[store_enum] = _get_frame_index(keys[store_enum], _frame_index[store_enum])


func _playback_trans_frame() -> void:
    var position = retrieve(keys[POSITION], _frame_index[POSITION])
    _update_frame_index(POSITION)
    var rotation = retrieve(keys[ROTATION], _frame_index[ROTATION])
    _update_frame_index(ROTATION)
    var velocity = retrieve(keys[VELOCITY], _frame_index[VELOCITY])
    _update_frame_index(VELOCITY)
    if not position is NotaValue: node_3d.position = position
    if not position is NotaValue: node_3d.rotation = rotation
    if not position is NotaValue: node_3d.velocity = velocity


func _playback_anim_frame() -> void:
    if aplayer.current_animation == null: 
        _update_frame_index(CURR_ANI)
        _update_frame_index(ANIM_POS)
        return
    var current_animation = retrieve(keys[CURR_ANI], _frame_index[ROTATION])
    if current_animation == null:
        aplayer.pause()
        _update_frame_index(CURR_ANI)
        _update_frame_index(ANIM_POS)
        return
    if current_animation is NotaValue: return
    aplayer.current_animation = current_animation
    _update_frame_index(CURR_ANI)
    _update_frame_index(ANIM_POS)
    var current_animation_position = retrieve(keys[ANIM_POS], _frame_index[ANIM_POS])
    if not current_animation_position is float: return
    aplayer.play()
    aplayer.seek(current_animation_position)
    _update_frame_index(ANIM_POS)
    _update_frame_index(CURR_ANI)

    
func playback_frame() -> void:
    _playback_trans_frame()
    _playback_anim_frame()


func _init(_size: int, _node_3d: Node3D, _aplayer: AnimationPlayer = null) -> void:
    size = _size
    max_count = size - 1
    node_3d = _node_3d
    aplayer = _aplayer
    store = {
        keys[POSITION]: [],
        keys[ROTATION]: [],
        keys[VELOCITY]: [],
        keys[CURR_ANI]: [],
        keys[ANIM_POS]: [],
    }
