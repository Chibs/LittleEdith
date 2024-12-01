extends Area3D

var picked_up = false
var random_offset = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Main.possible_points += 1
	random_offset = randf()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$mesh.position.y = sin((random_offset*100.0) + Time.get_ticks_msec()/200.0)/6.0
	$mesh.rotation.y += delta*5
	$mesh.rotation.y = fmod($mesh.rotation.y, PI*2.0)
	
	if picked_up:
		global_position = lerp(global_position,Main.player.global_position, delta*6.0   + delta*(12.0-global_position.distance_to(Main.player.global_position)))
		
		if global_position.distance_to(Main.player.global_position) < 1.3:
			Main.points += 1
			Main.player.pick_up()
			self.queue_free()
			
	
	pass


func _on_body_entered(body: Node3D) -> void:
	if body == Main.player:
		picked_up = true
		pass
	
