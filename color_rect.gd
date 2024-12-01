extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if $"../HSlider".closing:
		modulate.a = lerp(modulate.a, 1.0, delta*1.0)
		$"../AudioStreamPlayer".volume_db = lerp($"../AudioStreamPlayer".volume_db, -80.0, delta*0.3)
	else:
		modulate.a = lerp(modulate.a, 0.0, delta*1.0)
	pass
