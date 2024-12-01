extends Node3D

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
	
	#player_loc = $playerloc.global_position
	#origin_pos = $Mesh/pCube31.position
	#origin_rot = $Mesh/pCube31.rotation_degrees
	#$Portal.visible = false
	#Main.available_doors.append(self)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	
	points = Main.points
	
	if opened:
		
		$Counter.visible = false
		
		if additive < 1.0:
			$Mesh/Door_Lock.visible = false
		

		if additive < 8.0:
			opening += delta*0.1*additive
			additive = lerp(additive, opening, delta*2.9)
			$Mesh/Door_Lock/Padlock.material_override.set_shader_parameter("exploding", additive)
		else:
			$Mesh/Door_Lock.visible = false

		if player_nearby:
			$archwayhedge10/Bars.position.y = lerp($archwayhedge10/Bars.position.y, -17.0, delta*0.5)
			$Counter.visible = false
		else:
			#$PortalParticles.emitting = false
			#$archwayhedge10/Bars.position.y = lerp($archwayhedge10/Bars.position.y, 0.3, delta*1s.0)
			if !entered and !fixed:
				var temp_rot = rotation_degrees
				if Main.player != null and !entered:
					look_at(Main.player.global_position)
				rotation_degrees.x = temp_rot.x
				rotation_degrees.z = temp_rot.z
				rotation_degrees.y = rotation_degrees.y-180

			#$Mesh/pCube31.rotation_degrees.y = lerp($Mesh/pCube31.rotation_degrees.y, origin_rot.y, delta*4.0)
			#if abs($Mesh/pCube31.rotation_degrees.y-origin_rot.y) < 2.0:
				#$Portal.visible = false
			#$Mesh/pCube31.position = lerp($Mesh/pCube31.position, origin_pos, delta*4.0)
			#$CollisionShape3D.global_position = $Mesh/pCube31/CollisionShape3D2.global_position
			#$CollisionShape3D.global_rotation = $Mesh/pCube31/CollisionShape3D2.global_rotation

	else:
		
		$archwayhedge10/Bars.position.y = lerp($archwayhedge10/Bars.position.y, 0.3, delta*3.0)
		
		if Main.level == 2:
			
			additive = lerp(additive, opening, delta*2.9)
			
			if Main.special_points >= 2 and player_nearby and !opened:
				if !Main.player.door_opening:
					Main.final_points += 1 
					Main.player.door_opening = true

			#	$Counter.visible = false
				$Counter.text = str(Main.special_points) + "/2"
				if $Counter.modulate.a > 0.0 and opening > -.6:
					$Counter.modulate.a -= delta*4.0
					$Counter.outline_modulate.a = $Counter.modulate.a
				elif $Counter.modulate.a < 1.0:
					$Counter.position.y = 6.672 + sin(Time.get_ticks_msec()/200.0)/6.0
					$Counter.modulate.a += delta*4.0
					$Counter.modulate.a = clamp($Counter.modulate.a, 0.0, 1.0)
					$Counter.outline_modulate.a = $Counter.modulate.a
				#else:
					
				Main.player.door = self
				opening += delta*0.6
				
				%BackgroundMusic.volume_db -= delta*12.0
				
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
				$Counter.text = str(Main.special_points) + "/2"
		
		if !entered and !fixed:

			var temp_rot = rotation_degrees
			if Main.player != null and !entered:
				look_at(Main.player.global_position)
			rotation_degrees.x = temp_rot.x
			rotation_degrees.z = temp_rot.z
			rotation_degrees.y = rotation_degrees.y-180
			
		if 	!Main.player.door_opening:

			if player_nearby:
				$Counter.position.y =  6.672 + sin(Time.get_ticks_msec()/200.0)/6.0
				$Counter.modulate.a += delta*4.0
				$Counter.modulate.a = clamp($Counter.modulate.a, 0.0, 1.0)
				$Counter.outline_modulate.a = $Counter.modulate.a
			
			else:
				$Counter.position.y =  6.672 + sin(Time.get_ticks_msec()/200.0)/6.0
				$Counter.modulate.a -= delta*4.0
				$Counter.modulate.a = clamp($Counter.modulate.a, 0.0, 1.0)
				$Counter.outline_modulate.a = $Counter.modulate.a
			


func _on_interaction_area_body_entered(body: Node3D) -> void:
	
	if body == Main.player:
		#if !opened:
		player_nearby = true
		if !opened:
			Main.player.cinematic = true
	pass # Replace with function body.


func _on_interaction_area_body_exited(body: Node3D) -> void:
	if body == Main.player:
		if door_number == Main.door_to:
			Main.door_to = -1
		player_nearby = false
		#if !opened:
		Main.player.cinematic = false
	pass # Replace with function body.
