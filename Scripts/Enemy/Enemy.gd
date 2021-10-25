extends KinematicBody2D


var maxSpeed = 25
var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var gravity = 500
var startDirection = Vector2.RIGHT
func _ready():
	direction = startDirection
	$GoalDetector.connect("area_entered", self, "on_goal_entered")
	$HitBoxArea.connect("area_entered", self, "on_hitbox_entered")
func _process(delta):
	velocity.x = (direction * maxSpeed).x
	velocity = move_and_slide((velocity), Vector2.UP)
	#apply gravity
	velocity.y += gravity * delta
	$AnimatedSprite.flip_h = true if direction.x > 0 else false


func on_goal_entered(_aread2d):
	direction *= -1
	
func on_hitbox_entered(_area2d):
	$"/root/Helpers".apply_camera_shake(1)
	queue_free()
