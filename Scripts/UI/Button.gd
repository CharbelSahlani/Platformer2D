extends Button

func _ready():
	connect("mouse_entered", self, "on_mouse_entered")
	connect("mouse_exited", self, "on_mouse_exited")
	connect("pressed", self, "on_pressed")
	
	
func _process(delta):
	rect_pivot_offset = rect_min_size / 2
	
func on_mouse_entered():
	$HoverAnimationPlayer.play("Hover")
	
func on_mouse_exited():
	$HoverAnimationPlayer.play_backwards("Hover")

func on_pressed():
	$AudioStreamPlayer.play()
	$ClickAnimationPlayer.play("Click")
