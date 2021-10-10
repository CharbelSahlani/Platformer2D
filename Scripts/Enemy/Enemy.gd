extends KinematicBody2D

enum Direction {RIGHT, LEFT}
export (Direction) var startDirection
var maxSpeed = 25
var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var gravity = 500

func _ready():
	direction = Vector2.RIGHT if startDirection == Direction.RIGHT else Vector2.LEFT
	$GoalDetector.connect("area_entered", self, "on_goal_entered")
	
func _process(delta):
	velocity.x = (direction * maxSpeed).x
	velocity = move_and_slide((velocity), Vector2.UP)
	#apply gravity
	velocity.y += gravity * delta
	$AnimatedSprite.flip_h = true if direction.x > 0 else false


func on_goal_entered(_aread2d):
	direction *= -1
