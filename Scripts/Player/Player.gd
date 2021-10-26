extends KinematicBody2D

signal died

var playerDeathScene = preload("res://Scenes/Player.tscn")

enum State { NORMAL, DASHING}

export (int, LAYERS_2D_PHYSICS) var dashHazardMask

var gravity = 1000
var velocity = Vector2.ZERO
var maxDashSpeed = 500
var minDashSpeed = 200
var maxHorizontalSpeed = 140
var horizontalAcceleration = 2000
var jumpSpeed = 320
var jumpTerminationMultiplier = 4
var hasDoubleJump = false
var hasDash = false
var currentState = State.NORMAL
var isStateNew = true
var isDying = false
var defaultHazardMask = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	$HazardArea.connect("area_entered", self, "on_hazard_area_entered")
	defaultHazardMask = $HazardArea.collision_mask

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match currentState:
		State.NORMAL:
			process_normal(delta)
		State.DASHING:
			process_dash(delta)
	isStateNew = false
func change_state(newState):
	currentState = newState
	isStateNew = true	
	
	
	


func process_normal(delta):
	if (isStateNew):
		$DashArea/CollisionShape2D.disabled = true
		$HazardArea.collision_mask = defaultHazardMask
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
			$"/root/Helpers".apply_camera_shake(.75)
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
		hasDash = true
		
	if (hasDash && Input.is_action_just_pressed("Dash")):
		call_deferred("change_state", State.DASHING)
		hasDash = false
		
	update_animation()
	
func process_dash(delta):
	if (isStateNew):
		$"/root/Helpers".apply_camera_shake(.75)
		$DashArea/CollisionShape2D.disabled = false
		$AnimatedSprite.play("Jump")
		$HazardArea.collision_mask = dashHazardMask
		var moveVector = get_movement_vector()
		var velocityMod = 1
		#get the direction of movement in negative or positive
		#to be able to dash to left and dash to the right
		if (moveVector.x != 0):
			velocityMod = sign(moveVector.x)
		else:
			velocityMod = 1 if $AnimatedSprite.flip_h else -1
			
		velocity = Vector2(maxDashSpeed * velocityMod, 0)
		
	velocity = move_and_slide(velocity, Vector2.UP)
	velocity.x = lerp(0, velocity.x, pow(2, -10 * delta))
	
	if (abs(velocity.x) < minDashSpeed):
		call_deferred("change_state", State.NORMAL)
	
	
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

func kill():
	if (isDying):
		return
	isDying = true
	var playerDeathInstance = playerDeathScene.instance()
	get_parent().add_child_below_node(self, playerDeathInstance)
	playerDeathInstance.global_position = global_position
	playerDeathInstance.velocity = velocity;
	emit_signal("died")

func on_hazard_area_entered(area2d):
	$"/root/Helpers".apply_camera_shake(1)
	call_deferred("kill")
	
