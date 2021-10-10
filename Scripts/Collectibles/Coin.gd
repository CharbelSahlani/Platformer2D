extends Node2D

func _ready():
	$Area2D.connect("area_entered", self, "on_area_entered")
	
#exactly like on collision enter
func on_area_entered(area2d):
	$AnimationPlayer.play("PickUp")
	call_deferred("disable_pickup")
#prevent the player from picking up the coin again	
func disable_pickup():
	$Area2D/CollisionShape2D.disabled = true
