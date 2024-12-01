extends Node3D

@export_group("Properties")
var target = null

@export_group("Zoom")
var zoom_minimum = 14
var zoom_maximum = 6
@export var zoom_speed = 10

@export_group("Rotation")
@export var rotation_speed = 120

var camera_rotation:Vector3
var zoom = 4

var intro_speed_up = 0.0

var fade_out = false
var fade_in = false
var dark = false
var aim_height = 6.9
var unlock_timer = 0.0

var camera_rotation_degrees = Vector3.ZERO

@export var mouse_sensitivity = 3.0

@onready var camera = %CameraBody

func _ready():
	
	
	if Main.level == 0 and Main.door_to == 0:
		zoom = 4
	elif Main.level == 1:
		zoom = 20
	else:
		zoom = 16
	
	Main.camera = self


	
#	if fade_in:
	%GUI.circout.scale = Vector2(0.0, 0.0)
	%GUI.fadeout.modulate.a = 1.0
	dark = true
	
	camera_rotation = rotation_degrees # Initial rotation
	
	pass

func _physics_process(delta):
	#print(zoom)
	
	#print(zoom)
	
	
	mouse_sensitivity = 6.0*Main.sensi
	if target == null:
		target = Main.player
		if Main.level == 0:
			camera.position = Vector3(0, 4200, 1930)
	
	#if Input.is_action_just_pressed("debug"):
		#if !dark:
			#fade_out = true
		#else:
			#fade_in = true
	
	if fade_out and %GUI.fadeout.modulate.a < 1.0:
		%GUI.circout.scale -= Vector2(delta*8.0, delta*8.0)
		%GUI.circout.scale = clamp(%GUI.circout.scale, Vector2(0.05,0.05), Vector2(20.0,20.0))
		%GUI.circout.rotation -= delta*9.0
		if %GUI.circout.scale.x < 1.35:
			%GUI.fadeout.modulate.a += delta*5.0
			%GUI.fadeout.modulate.a = clamp(%GUI.fadeout.modulate.a, 0.0, 1.0)
		if %GUI.fadeout.modulate.a >= 1.0:	
			fade_out = false
			dark = true
	elif fade_in and %GUI.circout.scale.x < 10.5:
		%GUI.circout.scale += Vector2(delta*7.0, delta*7.0)
		%GUI.circout.rotation += delta*9.0
		if %GUI.circout.scale.x > 0.35:
			if Main.player.first_fall:
				%GUI.fadeout.modulate.a -= delta*0.9
			else:
				%GUI.fadeout.modulate.a -= delta*2.0
			%GUI.fadeout.modulate.a = clamp(%GUI.fadeout.modulate.a, 0.0, 1.0)
		if %GUI.circout.scale.x >= 10.5:	
			fade_in = false
			dark = false
	

		pass
		
	
	#print(camera.	position)
	# Set position and rotation to targets
	
	if Main.player.cinematic:
		
		if Main.player.first_zoom_out:
			if abs(camera.position.z-16.4) < 0.90:
#				print("huh")
				#Main.player.cinematic = false
				Main.player.first_zoom_out = false
				Main.cloud_intro = false
				Main.player.idle_timer = 0.0
		
		if Main.player.first_fall and Main.level == 0:
			#ting = false
			if Main.player.first_camera_lock:
				#if %Floor != null:
				%Floor.mesh.material.set_shader_parameter("albedo", Color(1.0,1.0,1.0,0.0))
				
				camera.position = lerp(camera.position, Vector3(0, 2, -2), 1.4 * delta)
			else:
				if $"../Sprite3D".modulate.a > 0.0:
					$"../Sprite3D".modulate.a -= delta
					if $"../Sprite3D".modulate.a <= 0.0:
						$"../Sprite3D".visible = false
				
					
				%Floor.mesh.material.set_shader_parameter("albedo", Color(1.0,1.0,1.0,%Floor.mesh.material.get_shader_parameter("albedo").a + delta))
				camera.position = lerp(camera.position, Vector3(0, 2, -7), 0.04 * delta)
			position.y = lerp(position.y, 701.0, delta*0.4)
			self.position = self.position.lerp(target.position, delta * 0.0001)
		else:
			if Main.player.first_slew:
				intro_speed_up += delta/40.0
				#camera.position = lerp(camera.position, Vector3(0, 2, -10), 1.4 * delta)
				self.position = self.position.lerp(target.position, delta * intro_speed_up*intro_speed_up)
				if self.position.distance_to(target.position) < 3.0 and Main.player.first_slew:
					Main.player.first_slew = false
					Main.player.animation_player.play("get_up")
					Main.player.animation_player.speed_scale = 0.0
					#Main.player.cinematic = false
					Main.player.first_zoom_out = true
					zoom = 16.4

			else:
				if Main.player.first_zoom_out:
					Main.player.animation_player.speed_scale += (delta/60.0) +  delta*Main.player.animation_player.speed_scale*1.0 + delta*Main.player.animation_player.current_animation_position*1.0
					if Main.player.animation_player.current_animation_position > 0.4 and Main.player.animation_player.current_animation_position < 0.5:
						Main.player.animation_player.speed_scale = 0.05

					self.position = self.position.lerp(target.position, delta * 0.4)
				else:
					
					self.position = self.position.lerp(target.position, delta * 3)
	else:
		self.position = self.position.lerp(target.position, delta * 10)
	#rotation_degrees = Vector3(fmod(rotation_degrees.x, 360.0),fmod(rotation_degrees.y, 360.0),fmod(rotation_degrees.z, 360.0))
	#camera_rotation = Vector3(fmod(camera_rotation.x, 360.0),fmod(camera_rotation.y, 360.0),fmod(camera_rotation.z, 360.0))
	if !Main.player.first_fall:
		
		
		

		
		
		if Main.player.first_slew:
			#zoom = clamp(zoom, zoom_maximum, zoom_minimum)
			camera.position = lerp(camera.position, Vector3(0, 2, zoom+8), delta * intro_speed_up/30.0)
			rotation_degrees = rotation_degrees.lerp(camera_rotation, delta * intro_speed_up/30.0)
			#print("Y")
		else:
			zoom = clamp(zoom, zoom_maximum, zoom_minimum)
			if Main.player.first_zoom_out:
				camera.position = lerp(camera.position, Vector3(0, 2, zoom), 0.4 * delta)
			else:
				camera.position = lerp(camera.position, Vector3(0, 2, zoom), 6 * delta)

			if !Main.player.door_opening:
				rotation_degrees = rotation_degrees.lerp(camera_rotation, delta * 12)
				if Main.player.first_slew:
					rotation_degrees = rotation_degrees.lerp(camera_rotation, delta * 5)
				elif Main.player.first_zoom_out:
					
					#print("rr?")
					rotation_degrees = rotation_degrees.lerp(camera_rotation, delta * 0.2)
			#else:
				
	else:
		if Main.player.first_slew:
			rotation_degrees = rotation_degrees.lerp(camera_rotation, delta * delta * intro_speed_up/10.0)
		else:
			rotation_degrees = rotation_degrees.lerp(camera_rotation, delta * 5)
	
		

	if true:#!Main.player.door_opening:
		camera.look_at(%Player.global_position + Vector3(0.0, aim_height ,0.0))
		if Main.player.door_opening:
			aim_height = lerp(aim_height, (zoom/100.0)*49.4, delta*0.4)
		else:
			if !Main.player.first_zoom_out:

				aim_height = lerp(aim_height, (zoom/100.0)*29.4, delta*6.0)
			else:
				aim_height = lerp(aim_height, (zoom/100.0)*29.4, delta*0.4)
	#else:
	#	camera.look_at(%Player.global_position + Vector3(0.0, aim_height ,0.0))
	# 	aim_height = lerp(aim_height, (zoom/100.0)*29.4, delta*6.0)
			
	handle_input(delta)

# Handle input

func handle_input(delta):
	
	if Main.player.door_opening and !Main.player.dead:
		#rotation_degrees = Vector3(fmod(rotation_degrees.x, 360.0),fmod(rotation_degrees.y, 360.0),fmod(rotation_degrees.z, 360.0))
		#var old_rot = rotation_degrees
		#look_at(Main.player.door.global_position)
		pass
		#camera_rotation = rotation_degrees
		#rotation_degrees = old_rot
		#if zoom > zoom_minimum:
		#	zoom -= delta*3.9
		#else:
		#	zoom = zoom_minimum
			
#		unlock_timer += delta
			#if unlock_timer > 4.0:
#				Main.player.door_opening = false
#				Main.player.door.opened = true
#				Main.player.cinematic = false
	
	if !Main.player.dead and !Main.player.door_opening and !Main.player.first_slew and !Main.player.first_fall:
		var input := Vector3.ZERO
		input.y = Input.get_axis("camera_left", "camera_right")
		input.x = Input.get_axis("camera_up", "camera_down")
		camera_rotation += input.limit_length(1.0) * rotation_speed * delta
		camera_rotation.x = clamp(camera_rotation.x, -70, 30)
		camera_rotation_degrees = camera_rotation
		if !Main.player.cinematic:
			var old_zoom = clamp(zoom, zoom_maximum, zoom_minimum)
			zoom += Input.get_axis("zoom_in", "zoom_out") * zoom_speed * delta
			zoom = clamp(zoom, zoom_maximum, zoom_minimum)
			if old_zoom == zoom:
				if Input.is_action_just_pressed("zoom_in"):
					zoom -= 1.6
				if Input.is_action_just_pressed("zoom_out"):
					zoom += 1.6
			zoom = clamp(zoom, zoom_maximum, zoom_minimum)

func _input(event):
	if !Main.player.dead and !Main.player.door_opening and !Main.player.first_slew and !Main.player.first_fall:
		if event is InputEventMouseButton and 	Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			camera_rotation.x -= mouse_sensitivity*event.relative.y/10.0
			camera_rotation.y -= mouse_sensitivity*event.relative.x/10.0
			camera_rotation.x = clamp(camera_rotation.x, -70, 30)
