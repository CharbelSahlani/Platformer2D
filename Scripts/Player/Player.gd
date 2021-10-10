extends KinematicBody2D

var gravity = 1000
var velocity = Vector2.ZERO
var maxHorizontalSpeed = 140
var horizontalAcceleration = 2000
var jumpSpeed = 360
var jumpTerminationMultiplier = 4
var hasDoubleJump = false



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var move_vector = get_movement_vector()
	velocity.x += move_vector.x * horizontalAcceleration * delta
	if (move_vector.x == 0):
		velocity.x = lerp(0, velocity.x, pow(2, -50 * delta))
	
	velocity.x = clamp(velocity.x, -maxHorizontalSpeed, maxHorizontalSpeed)
	
	if (move_vector.y < 0 && (is_on_floor() || 
				 !$CoyoteTimer.is_stopped() ||
				 hasDoubleJump)):
		velocity.y = move_vector.y * jumpSpeed
		#to treat the coyote jump as a regular jump and allow the player to double jump
		if (!is_on_floor() && $CoyoteTimer.is_stopped()):
			hasDoubleJump = false
		$CoyoteTimer.stop()
		
	if (velocity.y < 0 && !Input.is_action_pressed("jump")):
		velocity.y += gravity * jumpTerminationMultiplier * delta
	else:
		#accelerate at a rate of 300 pixles per second
		velocity.y += gravity * delta
		
	var wasOnFloor = is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)
	#needed to give the player some time to execute a jump even when falling off
	#a platform
	if (wasOnFloor && ! is_on_floor()):
		$CoyoteTimer.start()
	
	#double jump
	if (is_on_floor()):
		hasDoubleJump = true
		
	update_animation()
	
#to get the movement vector of the player	
func get_movement_vector():
	var move_vector = Vector2.ZERO
	move_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_vector.y = -1 if Input.is_action_just_pressed("jump") else 0
	return move_vector;

#to update the animation accordingly
func update_animation():
	var moveVec = get_movement_vector()
	
	if (!is_on_floor()):
		$AnimatedSprite.play("Jump")
	elif (moveVec.x != 0):
		$AnimatedSprite.play(("Run"))
	else:
		$AnimatedSprite.play(("Idle"))
	if (moveVec.x != 0):
		$AnimatedSprite.flip_h = true if moveVec.x > 0 else false
