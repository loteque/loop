extends CharacterBody3D
class_name PlayerController
## Player Character Controller script.
## handles movement and plays animations from an animation player.
## records a set amount of translation data.
## which can be played back at the press of a button.

@export var speed = 10.0
@export var max_rec_frames: int = 360
@export var ani_player: AnimationPlayer

var is_playback: bool = false
var curr_frame_index: int = 0
var recording_buffer := {
    "position": [],
    "rotation": [],
    "velocity": [],
    "curr_ani": [],
    "anim_pos": [],
}


## sets the velocity of the player based on detected Input values. 
## returns true if the player has velocity, false otherwise.
func apply_player_inputs() -> bool:      
    # stop movement when the player is not holding any movement keys
    if not Input.is_action_pressed("move_forward") and not Input.is_action_pressed("move_backward"):
        velocity = Vector3(0, 0, 0)
    # update velocity with inputs
    if Input.is_action_pressed("move_forward"):
        velocity += -get_global_transform().basis.z
    if Input.is_action_pressed("move_backward"):
        velocity += get_global_transform().basis.z
    if Input.is_action_pressed("strafe_left"):
        velocity += -get_global_transform().basis.x
    if Input.is_action_pressed("strafe_right"):
        velocity += get_global_transform().basis.x
    # update veloxity with normalized direction vector, speed
    velocity = velocity.normalized() * speed
    # return true if we have velocity otherwise return false
    if velocity == Vector3(0, 0, 0): return false
    return true


## plays the walk animation if arg movement is true,
## pauses it when false
func toggle_walk_animation_on(movement: bool) -> void:
    if movement:
        ani_player.play("walk")
    else:
        ani_player.pause()


## delete the front and shift indicies if buffer size is at max_rec_frames.
func limit_buffer_size() -> void:
    if recording_buffer.position.size() - 1 >= max_rec_frames:
        recording_buffer.position.pop_front()
    if recording_buffer.rotation.size() - 1 >= max_rec_frames:
        recording_buffer.rotation.pop_front()
    if recording_buffer.velocity.size() - 1 >= max_rec_frames:
        recording_buffer.rotation.pop_front()
    if recording_buffer.curr_ani.size() - 1 >= max_rec_frames:
        recording_buffer.curr_ani.pop_front()
    if recording_buffer.anim_pos.size() - 1 >= max_rec_frames:
        recording_buffer.anim_pos.pop_front()


## record a null animation frame
func rec_null_ani_frame() -> void:
    recording_buffer.curr_ani.push_back(null)
    recording_buffer.anim_pos.push_back(0.0)


## records data per frame for the controller
func record_frame() -> void:
    recording_buffer.position.push_back(position)
    recording_buffer.rotation.push_back(rotation)
    recording_buffer.velocity.push_back(velocity)
    if not ani_player.current_animation: rec_null_ani_frame(); return
    recording_buffer.curr_ani.push_back(ani_player.current_animation)
    recording_buffer.anim_pos.push_back(ani_player.current_animation_position)


## update the recording_buffer buffer and limit it's size.
func update_recording_buffer() -> void:
    limit_buffer_size()
    record_frame()


## get the next frame in the playback loop;
## returns an index value as an integer.
func get_next_frame_index(frame_index: int) -> int:
    if frame_index >= max_rec_frames: return 0
    if frame_index + 1 <= recording_buffer.position.size() - 1: return frame_index + 1
    return 0


## playback a frame's translation data from the recording buffer by index
func playback_translation_frame(frame_index: int) -> void:
    position = recording_buffer.position[frame_index]


## playback a frame's animation data from the recording buffer by index
func playback_anim_frame(frame_index: int) -> void:
    if recording_buffer.curr_ani[frame_index] == null: ani_player.pause(); return
    ani_player.play(recording_buffer.curr_ani[frame_index]) 
    ani_player.seek(recording_buffer.anim_pos[frame_index])


## playback a frame from the recording buffer by index, then
## increment the current frame index value
func playback_frame(frame_index:int) -> void:
    playback_translation_frame(frame_index)
    playback_anim_frame(frame_index)
    curr_frame_index = get_next_frame_index(frame_index)


## duplicate the player, set duplicate as player, add new player to scene
func spawn_new_player_instance() -> void:
    var new_self = duplicate()
    new_self.is_playback = false
    get_parent().add_child(new_self)


## set the current player to playback mode, spawn a new player instance
func activate_playback() -> void:
    if is_playback: return
    is_playback = true
    spawn_new_player_instance()


## returns true if the 'activate_playback' action is pressed, otherwise false
func is_activate_playback_just_pressed() -> bool:
    if not Input.is_action_just_pressed("activate_playback"): return false
    return true


func _physics_process(_delta) -> void:
    ## if playback is active player loses control of this instance
    if is_activate_playback_just_pressed(): activate_playback()
    if is_playback: playback_frame(curr_frame_index); return
    var is_moving = apply_player_inputs()
    toggle_walk_animation_on(is_moving)
    move_and_slide()
    update_recording_buffer()
