extends CharacterBody3D

## top down character coltroller script
var speed = 10.0

## moves the player based on detected Input values. 
## returns true if the player is moving
func get_movement() -> bool:
    # stop movement when the player is not holding any movement keys
    if not Input.is_action_pressed("move_forward") and not Input.is_action_pressed("move_backward"):
        velocity = Vector3(0, 0, 0)

    # move the player
    if Input.is_action_pressed("move_forward"):
        print("get_movement forward")
        velocity += -get_global_transform().basis.z
    if Input.is_action_pressed("move_backward"):
        velocity += get_global_transform().basis.z
    if Input.is_action_pressed("strafe_left"):
        velocity += -get_global_transform().basis.x
    if Input.is_action_pressed("strafe_right"):
        velocity += get_global_transform().basis.x

    velocity = velocity.normalized() * speed
    move_and_slide()
    if velocity == Vector3(0, 0, 0):
        return false
    else: 
        return true

## plays the walk animation if arg movement is true
func play_walk_animation(movement: bool) -> void:
    if movement:
        $CatModel/AnimationPlayer.play("walk")
    else:
        $CatModel/AnimationPlayer.pause()


func _physics_process(_delta):
    var is_moving = get_movement()
    play_walk_animation(is_moving)
        