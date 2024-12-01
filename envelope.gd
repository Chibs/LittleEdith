extends Area3D


@export var target: Control
var nearby = false
var picked_up = false
var random_offset = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	random_offset = randf()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$mesh.position.y = sin((random_offset*100.0) + Time.get_ticks_msec()/200.0)/6.0
	$mesh.rotation.y += delta*2
	$mesh.rotation.y = fmod($mesh.rotation.y, PI*2.0)
	
	if target != null:
		if nearby and !Main.player.first_fall and !Main.player.first_slew and !Main.player.first_zoom_out:
			if target.modulate.a < 1.0:
				target.modulate.a += delta*2.0
			else:
				target.modulate.a = 1.0
		else:
			if target.modulate.a > 0.0:
				target.modulate.a -= delta*4.0
			else:
				target.modulate.a = 0.0
			
		
	pass


func _on_body_entered(body: Node3D) -> void:
	if body == Main.player:
		
		Main.player.cinematic = true
		nearby = true
		pass
		
	


func _on_body_exited(body: Node3D) -> void:
	if body == Main.player:
		#pass
		nearby = false
		Main.player.cinematic = false
	
		pass # Replace with function body.
