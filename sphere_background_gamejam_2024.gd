extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#rotation_degrees.x += delta/99.0
	rotation_degrees.y += delta*2.0
	rotation_degrees.y =  fmod(rotation_degrees.y, 360.0)
	
	rotation_degrees.y += delta*8.0
	rotation_degrees.y =  fmod(rotation_degrees.y, 360.0)
	
	#rotation_degrees.z += delta/3.0
	if Main.player != null:
		global_position = Main.player.global_position 
		global_position.y += -80 + Main.camera.camera_rotation_degrees.x*3.0
	pass
