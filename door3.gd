extends StaticBody3D

var player_nearby = false
@export var opened = false
var additive = 0.0

@export var color: Color

@export var destination: String
@export var level_destination = 0
@export var door_to = 0
@export var door_number = 0

@export var total_count: int
var opening = -2.0
var player_loc = Vector3.ZERO
var points = 0
var origin_pos = Vector3.ZERO
var origin_rot = Vector3.ZERO
var entered = false
var fixed_cam = Vector3.ZERO


@export var end = false
@export var fixed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_nearby = false
	player_loc = $playerloc.global_position
	origin_pos = $Mesh/pCube31.position
	origin_rot = $Mesh/pCube31.rotation_degrees
	$Portal.visible = false
	Main.available_doors.append(self)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	

	var new_mat = $Mesh/pCube31.material_override.duplicate()
	$Mesh/pCube31.material_override = new_mat
	$Mesh/pCube31.material_override.albedo_color = color

	

	if entered:
		%BackgroundMusic.volume_db -= delta*24.0
		if Main.player.movement_speed > 0.0:
			Main.player.movement_speed -= delta*5000.0
		else:
			Main.player.movement_speed = 0.0

		if Main.camera.dark:
			Main.level = level_destination
			Main.door_to = door_to
			Main.door_from = door_number
			Main.available_doors.clear()
			#Main.points = 0.0
			get_tree().change_scene_to_file("res://" + destination + ".tscn")
			print("NEXT LEVEL")
#		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
#		get_tree().quit()

	
	points = Main.points
	
	if opened:
		
		%ForestCounter.visible = false
		
		if additive < 1.0:
			$Mesh/Door_Lock.visible = false
		

		if additive < 8.0:
			opening += delta*0.1*additive
			additive = lerp(additive, opening, delta*2.9)
			$Mesh/Door_Lock/Padlock.material_override.set_shader_parameter("exploding", additive)
		else:
			$Mesh/Door_Lock.visible = false

		if player_nearby:
			
			
			if (Vector2(global_position.x, global_position.z).distance_to(Vector2(Main.player.global_position.x,Main.player.global_position.z)) < 3.8 or entered) and Main.player.door_left:
				Main.camera.fade_out = true
				if !entered:
					entered = true
				#Main.camera.global_position = fixed_cam
				#Main.player.speed_factor = 0.0
				#Main.player.velocity = Vector3.ZERO
					
			else:
				$PortalParticles.emitting = true
				if !entered and !fixed:
					var temp_rot = rotation_degrees
					if Main.player != null:
						look_at(Main.player.global_position)
					rotation_degrees.x = temp_rot.x
					rotation_degrees.z = temp_rot.z
					rotation_degrees.y = rotation_degrees.y+180.0
					rotation_degrees.y = fmod(rotation_degrees.y, 360.0)
			$CollisionShape3D.global_position = $Mesh/pCube31/CollisionShape3D2.global_position
			$CollisionShape3D.global_rotation = $Mesh/pCube31/CollisionShape3D2.global_rotation
			
			$Portal.visible = true
			$Mesh/pCube31.rotation_degrees.y = lerp($Mesh/pCube31.rotation_degrees.y, -124.0, delta*2.0)
			$Mesh/pCube31.position = lerp($Mesh/pCube31.position, Vector3(-1.90, -0.5, 0.15), delta*2.0)
			%ForestCounter.visible = false
		else:
			$PortalParticles.emitting = false

			if !entered and !fixed:
				var temp_rot = rotation_degrees
				if Main.player != null and !entered:
					look_at(Main.player.global_position)
				rotation_degrees.x = temp_rot.x
				rotation_degrees.z = temp_rot.z
				rotation_degrees.y = rotation_degrees.y-180

			$Mesh/pCube31.rotation_degrees.y = lerp($Mesh/pCube31.rotation_degrees.y, origin_rot.y, delta*4.0)
			if abs($Mesh/pCube31.rotation_degrees.y-origin_rot.y) < 2.0:
				$Portal.visible = false
			$Mesh/pCube31.position = lerp($Mesh/pCube31.position, origin_pos, delta*4.0)
			$CollisionShape3D.global_position = $Mesh/pCube31/CollisionShape3D2.global_position
			$CollisionShape3D.global_rotation = $Mesh/pCube31/CollisionShape3D2.global_rotation

	else:
		
		if Main.level == 1:
			
			additive = lerp(additive, opening, delta*2.9)
			
			if Main.final_points >= 3 and player_nearby and !opened:
				Main.player.door_opening = true

			#	%ForestCounter.visible = false
				%ForestCounter.text = str(Main.final_points) + "/3"
				if %ForestCounter.modulate.a > 0.0 and opening > -.6:
					%ForestCounter.modulate.a -= delta*4.0
					%ForestCounter.outline_modulate.a = %ForestCounter.modulate.a
				elif %ForestCounter.modulate.a < 1.0:
					%ForestCounter.position.y = 4.28 + sin(Time.get_ticks_msec()/200.0)/6.0
					%ForestCounter.modulate.a += delta*4.0
					%ForestCounter.modulate.a = clamp(%ForestCounter.modulate.a, 0.0, 1.0)
					%ForestCounter.outline_modulate.a = %ForestCounter.modulate.a
				#else:
					
				Main.player.door = self
				opening += delta*0.6
				
				
				Main.player.music_quiet = true
				#%BackgroundMusic.volume_db -= delta*12.0
				#%BackgroundAmbience.volume_db -= delta*12.0
				
				if additive > -0.1 and additive < 2.0 and !$Shatter.playing:
					$Shatter.play()
					Main.player.door_left = true
					
				
				if additive < 1.0:
					opening += delta*1.1
				if additive < 0.0:
					Main.camera.zoom -= delta*3.0


				else:
					Main.camera.zoom += delta*2.0 + delta*Main.camera.zoom
					opening += delta*0.1*additive
				if additive > 6.0:
					Main.player.door_opening = false
					Main.player.idle_timer = 0.0
					opened = true
					#Main.player.cinematic = false
				$Mesh/Door_Lock/Padlock.material_override.set_shader_parameter("exploding", additive)
			
			elif !opened:
				%ForestCounter.text = str(Main.final_points) + "/3"
		
		if !entered and !fixed:

			var temp_rot = rotation_degrees
			if Main.player != null and !entered:
				look_at(Main.player.global_position)
			rotation_degrees.x = temp_rot.x
			rotation_degrees.z = temp_rot.z
			rotation_degrees.y = rotation_degrees.y-180
			
		if 	!Main.player.door_opening:

			if player_nearby:
				%ForestCounter.position.y = 4.28 + sin(Time.get_ticks_msec()/200.0)/6.0
				%ForestCounter.modulate.a += delta*4.0
				%ForestCounter.modulate.a = clamp(%ForestCounter.modulate.a, 0.0, 1.0)
				%ForestCounter.outline_modulate.a = %ForestCounter.modulate.a
			
			else:
				%ForestCounter.position.y = 4.28 + sin(Time.get_ticks_msec()/200.0)/6.0
				%ForestCounter.modulate.a -= delta*4.0
				%ForestCounter.modulate.a = clamp(%ForestCounter.modulate.a, 0.0, 1.0)
				%ForestCounter.outline_modulate.a = %ForestCounter.modulate.a
			


func _on_interaction_area_body_entered(body: Node3D) -> void:
	
	if body == Main.player: #and door_number != Main.door_to:
		print("YI")
		#if !opened:
		player_nearby = true
		Main.player.cinematic = true
	pass # Replace with function body.


func _on_interaction_area_body_exited(body: Node3D) -> void:
	if body == Main.player:
		print("YAWW")
		if door_number == Main.door_to:
			Main.door_to = -1
		player_nearby = false
		Main.player.cinematic = false
	pass # Replace with function body.
