class_name RecBuff 

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
var _max_size: int
var _max_count: int
var _node_3d: Node3D
var _aplayer: AnimationPlayer
var _multi_buffer: Dictionary[StringName, MemTools.Buffer]


func push_to_buffer(key: StringName, value: Variant) -> void:
    if _multi_buffer.has(key):
        _multi_buffer[key].push(value)


func _push_translation(position: Vector3, rotation: Vector3, velocity: Vector3) -> void:
    push_to_buffer(keys[POSITION], position)
    push_to_buffer(keys[ROTATION], rotation)
    push_to_buffer(keys[VELOCITY], velocity)


func _push_null_anim() -> void:
    push_to_buffer(keys[CURR_ANI], "")
    push_to_buffer(keys[ANIM_POS], 0.0)


func _push_animation(current_animation: StringName, current_animation_position: float) -> void:
    push_to_buffer(keys[CURR_ANI], current_animation)
    push_to_buffer(keys[ANIM_POS], current_animation_position)


func push_all() -> void:
    _push_translation(_node_3d.position, _node_3d.rotation, _node_3d.velocity)
    if not _aplayer: return
    if not _aplayer.current_animation: _push_null_anim(); return
    _push_animation(_aplayer.current_animation, _aplayer.current_animation_position)

    
func retrieve_all() -> void:
    var buffered_current_animation: StringName  = _multi_buffer[keys[CURR_ANI]].retrieve()
    var buffered_animation_position: float = _multi_buffer[keys[ANIM_POS]].retrieve()
    var buffered_position: Vector3 = _multi_buffer[keys[POSITION]].retrieve()
    var buffered_rotation: Vector3 = _multi_buffer[keys[ROTATION]].retrieve()
    var buffered_velocity: Vector3 = _multi_buffer[keys[VELOCITY]].retrieve()
    _node_3d.position = buffered_position
    _node_3d.rotation = buffered_rotation
    _node_3d.velocity = buffered_velocity
    if not _aplayer: return
    if not buffered_current_animation: 
        _aplayer.pause() 
        return
    _aplayer.current_animation = buffered_current_animation
    _aplayer.seek(buffered_animation_position)


func _init(node_3d: Node3D, max_size: int = -1, aplayer: AnimationPlayer = null) -> void:
    _max_size = max_size
    _max_count = max_size - 1
    _node_3d = node_3d
    _aplayer = aplayer
    _multi_buffer = { 
        keys[POSITION]: MemTools.Buffer
            .new()
            .set_max_size(_max_size)
            .set_op_mode(MemTools.Mode.FIFO)
            .set_retrieval_mode(MemTools.Mode.KEEP)
            .set_overflow_mode(MemTools.Mode.DROP)
        ,
        keys[ROTATION]: MemTools.Buffer
            .new()
            .set_max_size(_max_size)
            .set_op_mode(MemTools.Mode.FIFO)
            .set_retrieval_mode(MemTools.Mode.KEEP)
            .set_overflow_mode(MemTools.Mode.DROP)
        ,
        keys[VELOCITY]: MemTools.Buffer
            .new()
            .set_max_size(_max_size)
            .set_op_mode(MemTools.Mode.FIFO)
            .set_retrieval_mode(MemTools.Mode.KEEP)
            .set_overflow_mode(MemTools.Mode.DROP)
        ,
        keys[CURR_ANI]: MemTools.Buffer
            .new()
            .set_max_size(_max_size)
            .set_op_mode(MemTools.Mode.FIFO)
            .set_retrieval_mode(MemTools.Mode.KEEP)
            .set_overflow_mode(MemTools.Mode.DROP)
        ,
        keys[ANIM_POS]: MemTools.Buffer
            .new()
            .set_max_size(_max_size)
            .set_op_mode(MemTools.Mode.FIFO)
            .set_retrieval_mode(MemTools.Mode.KEEP)
            .set_overflow_mode(MemTools.Mode.DROP)
        ,
    }
