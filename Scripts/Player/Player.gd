extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var gravity = 1000
var velocity = Vector2.ZERO
var maxHorizontalSpeed = 140
var horizontalAcceleration = 2000
var jumpSpeed = 360
var jumpTerminationMultiplier = 4
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
	
	if (move_vector.y < 0 && is_on_floor()):
		velocity.y = move_vector.y * jumpSpeed
		
	if (velocity.y < 0 && !Input.is_action_pressed("jump")):
		velocity.y += gravity * jumpTerminationMultiplier * delta
	else:
		#accelerate at a rate of 300 pixles per second
		velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

func get_movement_vector():
	var move_vector = Vector2.ZERO
	move_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_vector.y = -1 if Input.is_action_just_pressed("jump") else 0
	return move_vector;
