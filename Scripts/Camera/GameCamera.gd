extends Camera2D
var targetPosition = Vector2.ZERO
#to change the background color from the editor (like serializefield)
export(Color, RGB) var backgroundColor

func _ready():
	#to change the background color in the game
	VisualServer.set_default_clear_color(backgroundColor)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	acquire_target_position()
	global_position = lerp(targetPosition, global_position, pow(2, -15 * delta))	
	
func acquire_target_position():
	#this returns an array of nodes
	var players = get_tree().get_nodes_in_group("player")
	if (players.size() > 0):
		var player = players [0]
		targetPosition = player.global_position
