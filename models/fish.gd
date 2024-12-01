extends Node3D
var player_nearby = false

var origin = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	origin = global_position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Main.player.inside_fish and Main.player.position.y < 27:
		$Cylinder_001.visible = false 
		$OmniLight3D2.visible = false
		global_position = lerp(global_position, Main.player.global_position, delta*5.0)
	else:
		global_position.x = origin.x
		global_position.z = origin.z
	
	var temp_rot = rotation_degrees
	look_at(Main.player.global_position)
	rotation_degrees = Vector3(temp_rot.x, rotation_degrees.y+90.0, temp_rot.z)
	
	if player_nearby:
		position.y = lerp(position.y, 18.335 + sin(Time.get_ticks_msec()/700.0)*2.0, delta*4.0)
		rotation_degrees.z = lerp(rotation_degrees.z, 21.5, delta*1.0)
	else:
		position.y = lerp(position.y, -6.4 + sin(Time.get_ticks_msec()/700.0)*2.0, delta*4.0)
		rotation_degrees.z = lerp(rotation_degrees.z, 3.5, delta*1.0)
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == Main.player:
		player_nearby = true
		Main.player.cinematic = true
		Main.player.near_fish = true
	pass # Replace with function body.


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == Main.player:
		player_nearby = false
		Main.player.cinematic = false
		Main.player.near_fish = false
	pass # Replace with function body.
