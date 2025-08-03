extends CharacterBody3D
class_name PlayerController
## Player Character Controller script.
## handles movement and plays animations from an animation player.
## records a set amount of translation data.
## which can be played back at the press of a button.

@export var speed = 10.0
@export var max_rec_frames: int = 360
@export var ani_player: AnimationPlayer

@onready var rec_buff = RecBuff.new(260, self, ani_player)

var is_playback: bool = false


## sets the velocity of the player based on detected Input values. 
## returns true if the player has velocity, false otherwise.
func apply_player_inputs() -> bool:      
    # stop movement when the player is not holding any movement keys
    if not Input.is_action_pressed("move_forward") and not Input.is_action_pressed("move_backward") and not Input.is_action_pressed("strafe_left") and not Input.is_action_pressed("strafe_right"):
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


## duplicate the player, set duplicate as player, add new player to scene
func spawn_new_player_instance() -> void:
    var new_self = self.duplicate()
    get_parent().add_child(new_self)
    new_self.is_playback = false


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
    if is_activate_playback_just_pressed(): activate_playback()
    if is_playback: rec_buff.playback_frame(); return
    var is_moving = apply_player_inputs()
    toggle_walk_animation_on(is_moving)
    move_and_slide()
    rec_buff.write_frame()
