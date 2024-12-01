extends HSlider
var closing = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Main.sensi = value
	
	
	if $"../ColorRect".modulate.a > 0.95 and closing:
	
		Main.level = 0
		Main.door_to = 0
		get_tree().change_scene_to_file("res://cloud.tscn")
	
	pass


func _on_button_pressed() -> void:
	closing = true

	pass # Replace with function body.
