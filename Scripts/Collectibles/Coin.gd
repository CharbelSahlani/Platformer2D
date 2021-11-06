extends Node2D

func _ready():
	$Area2D.connect("area_entered", self, "on_area_entered")
	
#exactly like on collision enter
func on_area_entered(area2d):
	$AnimationPlayer.play("PickUp")
	call_deferred("disable_pickup")
	
	#collected coins script
	var baseLevel = get_tree().get_nodes_in_group("base_level")[0]
	baseLevel.coin_collected()
	$RandomAudioStreanLayer.play()
	$RandomAudioStreanLayer2.play()
#prevent the player from picking up the coin again	
func disable_pickup():
	$Area2D/CollisionShape2D.disabled = true
