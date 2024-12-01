extends CharacterBody3D

#signal coin_collected

@export_subgroup("Components")
var view = null


var movement_speed = 1550
var jump_strength = 29

var double_jump_allowed = true
var pickups = false
var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0
var land_timer = 0.0
var leaving_fish = false
var orig_level_mus = 0.0
var orig_level_amb = 0.0
var door = null
var music_quiet = false
var previously_floored = false
var inside_fish = false
var first_fall = true
var first_zoom_out = false
var first_slew = true
var first_camera_lock = true
@export var cinematic = false




var near_fish = false
var fix_door_timer = 0.0

var name_counter = 0

var door_opening = false
var door_pos = Vector3.ZERO

@onready var health_scene = preload("res://health_pickup.tscn")
@onready var pill_scene = preload("res://pickup.tscn")
@onready var env_scene = preload("res://envelope.tscn")

var pick_up_list = []
var health_pick_up_list = []
var env_pick_up_list = []

var idle_timer = 0.0

var jump_single = true
var jump_double = true

var above_mush = 0
var last_mush = 0


var door_left = false

var name_hold = 0.0
var coins = 0
var lean = 0.0
var old_rotation = Vector2(velocity.z, velocity.x).angle()
var old_pos = rotation.y
@onready var animation_player = $Character/uvliddell/AnimationPlayer

var first_load = true

var wait_once = 0.0

var first_time = 0.5
var first_fade = true

var origin_rotation = Vector3.ZERO
var morph_surface = Vector3.ZERO
var air_time = 0.0
var dead = false
var origin_position = Vector3.ZERO
var fixed_camera = Vector3.ZERO
var jump_timer = 0.0

var recent_point = 0.0
var recent_lives = 0.0
var recent_level = 0.0
var door_to_close = null
var new_timer = 0.0


#@onready var particles_trail = $ParticlesTrail
#@onready var #sound_footsteps = $SoundFootsteps
@onready var model = $Character
#@onready var #animation = $Character/#animationPlayer

var lives = 6

# Functions

func _init() -> void:
	
	
	
	Main.special_points = 0.0
	
	if Main.level == 0 and Main.door_to != 0:
		#$"../Sprite3D".visible = false
		
		Main.level = 99
	
	if Main.level == 0:

		first_fall = true
		first_zoom_out = false
		first_slew = true
		first_camera_lock = true
		cinematic = false
	else:
		first_fall = false
		first_zoom_out = false
		first_slew = false
		first_camera_lock = false
		cinematic = false

	Main.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func level_up():
	if !cinematic:
		%GUI.level_label.scale = Vector2(1.4,1.4)
		recent_level = 4.0
	$Sfx/SfxPickup2.play()
	pass


func live_up():
	if !cinematic:
		%GUI.lives.scale = Vector2(1.4,1.4)
		recent_lives = 4.0
	$Sfx/SfxPickup3.play()
	pass

func pick_up():
	if !cinematic:
		%GUI.points.scale = Vector2(1.4,1.4)
		recent_point = 3.0
		#if Main.level == 0 or Main.level == 99:
		#	%GUI.level_label.scale = Vector2(1.4,1.4)
		#	recent_level = 5.0
	$Sfx/SfxPickup.play()
	pass

func _physics_process(delta):



	if Main.level == 3 and !first_load:
		if %MusicLight.light_energy > 0.1:
			%MusicLight.light_energy = lerp(%MusicLight.light_energy, 0.0, delta*5.0)
			%MusicLight.visible = true
		else:
			%MusicLight.visible = false
	
		
	
	if music_quiet or inside_fish:
		if inside_fish and !%BackgroundMusic2.playing:
			%BackgroundMusic2.play()
		%BackgroundMusic.volume_db = lerp(%BackgroundMusic.volume_db, -80.0, delta*6.0) 
		%BackgroundAmbience.volume_db = lerp(%BackgroundAmbience.volume_db, -80.0, delta*6.0) 
	else:
		%BackgroundMusic.volume_db = lerp(%BackgroundMusic.volume_db, orig_level_mus, delta*6.0) 
		%BackgroundAmbience.volume_db = lerp(%BackgroundAmbience.volume_db, orig_level_amb, delta*6.0) 
		#orig_level_mus = 
		#orig_level_amb = %BackgroundAmbience.volume_db


	
	if Main.level == 2 and !first_load and !pickups:
		#print("YP")
		var pickupscene = load("res://pickups_maze.tscn")
		var new_pickups = pickupscene.instantiate()
		get_parent().add_child(new_pickups);
		new_pickups.set_owner(get_parent());
		pickups = true

	
	if Main.level == 2 and !first_load:

		%insidefish.visible = inside_fish
		if inside_fish and Main.camera.dark and !leaving_fish:
			if dead:
				dead = false
				lives -= 1
				recent_lives = 5.0

				$Character.rotation.x = 0
				print("Yestbi")

			print("Yest")
			velocity.x = 0.0
			velocity.z = 0.0
			velocity.y = 0.0
			position = Vector3(1317.904, 69.012, -3416.584)
			Main.camera.dark = false
			Main.camera.fade_in = true
		if inside_fish and leaving_fish and Main.camera.dark:
			%BackgroundMusic2.stop()
			$"../Fish".global_position = $"../Fish".origin
			inside_fish = false
			position = Vector3(-520.8, 8.365, -144)
			Main.camera.dark = false
			Main.camera.fade_in = true
			leaving_fish = false
	
	
	if Main.level == 2 and !first_load:
		%WorldEnvironment.environment.fog_light_color = lerp(%WorldEnvironment.environment.fog_light_color, Color("2b2130"), delta*0.0014)
		%WorldEnvironment.environment.background_energy_multiplier = lerp(%WorldEnvironment.environment.background_energy_multiplier, 0.10, delta*0.0014)
		%WorldEnvironment.environment.fog_density = lerp(%WorldEnvironment.environment.fog_density, 0.0095, delta*0.0014)
	#print(Main.level)
	#print(Main.player.door_left)
	
	#if fix_door_timer < 1.0:
	#	fix_door_timer += delta
	#else:
		#Main.player.door_left = false
	
	
	if Main.gui != null:
		if Main.level == 0 or Main.level == 99:
			Main.gui.level_label.text = str(clamp(Main.points, 0, 40)) + "/40"
		elif Main.level == 2:
			Main.gui.level_label.text = str(clamp(Main.special_points, 0, 2)) + "/2"
		elif Main.level == 3:
			Main.gui.level_label.text = str(clamp(Main.special_points, 0, 7)) + "/7"
	if Main.level != 0:
		
		if new_timer > 0.0 and new_timer < 1.1:
			Main.camera.zoom += delta/1.5
		
		if new_timer > 0.0 and !first_load and %View.position.y  > 100.0:
			if Main.level == 99:
				$"../Sprite3D".visible = false
				$WindFall.stop()
				$WindFall.volume_db = -80.0
				$"../LevelSpecifics/Door".opened = true
				#if $"../LevelSpecifics/Envelope2" != null:
				#	$"../LevelSpecifics/Envelope2".queue_free()
				#$"../LevelSpecifics/Envelope3".queue_free()
				%View.position.y = position.y
		if new_timer > 1.1 and !door_left:
			if door_to_close == null:
				door_left = true
			else:
				door_to_close.player_nearby = false
				cinematic = false
				door_left = true

		else:
			new_timer += delta
	if Main.level != 0 and first_load:
		
		var new_position
		for each_door in Main.available_doors:
			if each_door.door_number == Main.door_to:
				global_position = each_door.player_loc
				each_door.player_nearby = true
				cinematic = true
				door_to_close = each_door
	
	if Main.level == 0 and !first_load:
	
		var name_wait_time = 3.0
	
		
		if (name_counter >= 1 and name_hold > 0.0) or name_counter >= 2:
			%Maria.position.y += delta*1.5
		if (name_counter >= 3 and name_hold > 0.0) or name_counter >= 4:
			%Mathijs.position.y += delta*1.5
		if (name_counter >= 5 and name_hold > 0.0) or name_counter >= 6:
			%Talha.position.y += delta*1.5
		if (name_counter >= 7 and name_hold > 0.0) or name_counter >= 8:
			%Present.position.y += delta*1.5
	#%Maria.position.y = sin(Time.get_ticks_msec()/4500.0)/20.0
		%Maria.position.x = -sin(Time.get_ticks_msec()/6710.0)*sin(Time.get_ticks_msec()/3710.0)*6.0
		%Maria.position.z = -3 + sin(Time.get_ticks_msec()/6710.0)*sin(Time.get_ticks_msec()/4400.0)*6.0
		%Mathijs.position.x = -sin(Time.get_ticks_msec()/6710.0)*cos(Time.get_ticks_msec()/3210.0)*5.0
		%Mathijs.position.z = -3 +  cos(Time.get_ticks_msec()/6710.0)*sin(Time.get_ticks_msec()/4100.0)*5.0
		%Talha.position.x = -sin(Time.get_ticks_msec()/6710.0)*sin(Time.get_ticks_msec()/3410.0)*3.0
		%Talha.position.z = 2 + sin(Time.get_ticks_msec()/6710.0)*cos(Time.get_ticks_msec()/4600.0)*3.0
		%Present.position.x = -sin(Time.get_ticks_msec()/6710.0)*sin(Time.get_ticks_msec()/5410.0)*2.0
		%Present.position.z = sin(Time.get_ticks_msec()/9710.0)*cos(Time.get_ticks_msec()/7600.0)*2.0
			
		if name_counter == 1:
			
			

			
			name_hold += delta
			if %Maria.modulate.a < 1.0 &&  name_hold > 0.0:
				%Maria.modulate.a += delta/2.0
				#%Maria.outline_modulate.a = %Maria.modulate.a
				
			elif name_hold > name_wait_time:
				name_counter = 2
				name_hold = 0.0
		elif name_counter == 2:
			if %Maria.modulate.a > 0.0:
				%Maria.modulate.a -= delta/2.0
				#%Maria.outline_modulate.a = %Maria.modulate.a
			else:
				name_counter = 3
				name_hold = -2.0
		elif name_counter == 3:
			name_hold += delta
			if %Mathijs.modulate.a < 1.0 &&  name_hold > 0.0:
				%Mathijs.modulate.a += delta/1.0
				#%Mathijs.outline_modulate.a = %Mathijs.modulate.a
				
			elif name_hold > name_wait_time:
				name_counter = 4
				name_hold = -2.0
		elif name_counter == 4:
			if %Mathijs.modulate.a > 0.0:
				%Mathijs.modulate.a -= delta
			#	%Mathijs.outline_modulate.a = %Mathijs.modulate.a
			else:
				name_counter = 5
				name_hold = -2.0
		elif name_counter == 5:
			name_hold += delta
			if %Talha.modulate.a < 1.0 &&  name_hold > 0.0:
				%Talha.modulate.a += delta/1.0
			#	%Talha.outline_modulate.a = %Talha.modulate.a
				
			elif name_hold > name_wait_time:
				name_counter = 6
				name_hold = 0.0
		elif name_counter == 6:
			if %Talha.modulate.a > 0.0:
				%Talha.modulate.a -= delta/2.0
				#%Talha.outline_modulate.a = %Talha.modulate.a
			else:
				name_counter = 7
				name_hold = -3.0
		elif name_counter == 7:
			name_hold += delta
			if %Present.modulate.a < 1.0 &&  name_hold > 0.0:
				%Present.modulate.a += delta/2.5
			#	%Talha.outline_modulate.a = %Talha.modulate.a
				
			elif name_hold > name_wait_time:
				name_counter = 8
				name_hold = 0.0
		elif name_counter == 8:
			if %Present.modulate.a > 0.0:
				%Present.modulate.a -= delta/2.0
				#%Talha.outline_modulate.a = %Talha.modulate.a
			else:
				name_counter = 9
				name_hold = 0.0
		#if animation_player.current_animation == "get_up" and !animation_player.is_playing():
		#	animation_player.play("idle")

		
		if first_fall:
			$Character.rotation.z =  air_time * 0.1*(-sin(Time.get_ticks_msec()/6710.0)*sin(Time.get_ticks_msec()/3710.0)*0.04)
			$Character.rotation.x = air_time * 0.1* (-sin(Time.get_ticks_msec()/9710.0)*cos(Time.get_ticks_msec()/6710.0)*0.07)
			$Character.position.y = sin(Time.get_ticks_msec()/450.0)/1.0
			$Character.position.x = sin(Time.get_ticks_msec()/310.0)/1.0
			$Character.position.z = sin(Time.get_ticks_msec()/600.0)/1.0
		else:
			$Character.position = Vector3.ZERO
		
		if door_opening:
			pass
			#global_position = lerp(global_position, door_pos, delta*2.0)
			#look_at(door.global_position)
	
	if cinematic:
		%GUI.cineup.position.y = lerp(%GUI.cineup.position.y, 0.0, delta*8.0)
		%GUI.cinedown.position.y = lerp(%GUI.cinedown.position.y, 440.0, delta*8.0)
	else:
		%GUI.cineup.position.y = lerp(%GUI.cineup.position.y, -45.0, delta*6.0)
		%GUI.cinedown.position.y = lerp(%GUI.cinedown.position.y, 485.0, delta*6.0)
		
	if Input.is_action_just_pressed("pickup_1"):
		var new_pill = pill_scene.instantiate()
		pick_up_list.append(new_pill)
		%Pickups.add_child(new_pill)
		new_pill.global_position = global_position + Vector3(0.0, 1.5, 0.0)

	if Input.is_action_just_pressed("pickup_2"):
		var new_pill = health_scene.instantiate()
		health_pick_up_list.append(new_pill)
		%Pickups.add_child(new_pill)
		new_pill.global_position = global_position + Vector3(0.0, 1.5, 0.0)
		
	if Input.is_action_just_pressed("pickup_3"):
		var new_pill = env_scene.instantiate()
		env_pick_up_list.append(new_pill)
		%Pickups.add_child(new_pill)
		new_pill.global_position = global_position + Vector3(0.0, 1.5, 0.0)

	if Input.is_action_just_pressed("debug"):
		#pickups = false
		print("PILLS")
		for item in pick_up_list:
			print("Vector3" + str(item.global_position) + "," )
		print("HEALTH")
		for item in health_pick_up_list:
			print("Vector3" + str(item.global_position) + "," )
		print("ENVELOPES")
		for item in env_pick_up_list:
			print("Vector3" + str(item.global_position) + "," )

		

	if (recent_level > 0.0 and !cinematic) or (idle_timer > 4.0 and !cinematic):
		%GUI.level.position.y = lerp(%GUI.level.position.y, 0.0, delta*8.0)
		recent_level -= delta 
	else:
		%GUI.level.position.y = lerp(%GUI.level.position.y, -98.0, delta*10.0)
		recent_level = 0.0


	if (recent_lives > 0.0 and !cinematic) or (idle_timer > 4.0 and !cinematic):
		%GUI.lives.position.y = lerp(%GUI.lives.position.y, 0.0, delta*8.0)
		recent_lives -= delta 
	else:
		%GUI.lives.position.y = lerp(%GUI.lives.position.y, -98.0, delta*10.0)
		recent_lives = 0.0
		
	if (recent_point > 0.0 and !cinematic) or (idle_timer > 4.0 and !cinematic):
		%GUI.points.position.y = lerp(%GUI.points.position.y, 0.0, delta*10.0)
		recent_point -= delta
	else:
		recent_point = 0.0
		%GUI.points.position.y = lerp(%GUI.points.position.y, -98.0, delta*8.0)
	
	%GUI.lives_label.text = str(lives)
	%GUI.points_label.text = str(Main.points)
	
	%GUI.lives.scale = lerp(%GUI.lives.scale, Vector2.ONE, delta*6.0)
	%GUI.points.scale = lerp(%GUI.points.scale, Vector2.ONE, delta*6.0)
	%GUI.level_label.scale = lerp(%GUI.level_label.scale, Vector2.ONE, delta*6.0)
	
	if view == null:
		view = Main.camera
	
	if Input.is_action_pressed("jump") and !first_fall and !first_slew and !first_zoom_out:
		jump_timer += delta
		if jump_timer < 0.15:
			gravity -= delta*98.0
	
	if first_time > 0.0 and first_fade:
		first_time -= delta
		if first_time <= 0.0:
			first_fade = false
			Main.camera.fade_in = true
	
	if dead:
		#animation_player.play("RESET")
		

		$Character.rotation_degrees.x = 90
		Main.camera.camera.global_position = fixed_camera
		#delta = 0.0
		velocity = Vector3.ZERO
		
		if Main.camera.dark:
			if wait_once < 1.0:
				global_position = origin_position
				global_rotation = origin_rotation
				wait_once += delta*4.0
			else:
				
				dead = false
				Main.camera.fade_in = true
				wait_once = 0.0
				lives -= 1
				recent_lives = 5.0
				$Character.rotation.x = 0
		else:
			Main.camera.fade_out = true		
		
		
		
	if position.y < 0.5 or (inside_fish and position.y < 35.598):
		$Particles/LandingParticles.position.y = 3.0
		$Particles/LandingParticles.emitting = true
		#$Particles/JumpParticles.emitting = true	
		#$Particles/JumpParticles.restart()
		#if(int(Time.get_ticks_msec()*2.0) % 10 > 5 ):
			#$Particles/LandingParticles.restart()
		if !dead and !near_fish and !inside_fish:
			$Sfx/SfxSplash.play()
			dead = true
			fixed_camera = Main.camera.camera.global_position
		if (near_fish and !inside_fish) or (!near_fish and inside_fish and position.y < 35.598):
			if (!near_fish and inside_fish and position.y < 35.598):
				if !dead:
					dead = true
					$Sfx/SfxSplash.play()

			inside_fish = true
			$Sfx/SfxSplash.play()
			fixed_camera = Main.camera.camera.global_position
			Main.camera.fade_out = true		

	else:
		$Particles/LandingParticles.position.y = -0.12

		
		
	
	if first_load:
		orig_level_mus = %BackgroundMusic.volume_db
		orig_level_amb = %BackgroundAmbience.volume_db

		
		if Main.level == 0:
			%GUI.lives.position.y -98.0
			%GUI.points.position.y -98.0
			cinematic = true
		else:
			%BackgroundMusic.play()
			%BackgroundAmbience.play()
		
		
		origin_rotation = global_rotation
		origin_position = global_position
		$Particles/LandingParticles.emitting = true
		$Particles/JumpParticles.emitting = true	

		first_load = false
	
	
	
	if air_time > 48.0 and first_fall:
		first_fall = false
		
		name_counter = 1
		animation_player.play("lay_still")
		rotation_degrees.x = 0.0
		#air_time = 0.0

	
	if Main.level == 0 and !first_fall and first_slew:
		if !%BackgroundMusic.playing:
			%BackgroundMusic.play()
	
	if air_time > 8.0 and first_camera_lock:
		first_camera_lock = false
		

		if $"../JumpParticles".speed_scale > 0.2:
			$"../JumpParticles".speed_scale -= delta
			$"../JumpParticles".lifetime += delta*2.0
		air_time = 0.0
	elif first_camera_lock:
		gravity = 0.0
	
	
	
	if !first_camera_lock:
	
		gravity += 40 * delta + delta * 10.0* air_time*air_time

	#print(lean)
	old_pos = rotation.y	
	if gravity > 0 and is_on_floor():
		old_pos = rotation.y	
		jump_single = true
		gravity = 0
	
	

	var applied_velocity: Vector3

	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity

	velocity = applied_velocity
	if !dead:
		move_and_slide()
		var mush_collide = null
		if Main.level == 3:
			var mush_found = false
			for each_floor in get_slide_collision_count():
				var collisions = get_slide_collision(each_floor)
				if collisions.get_collider() ==  %mushroomcap_1:
					mush_collide = collisions.get_collider()
					above_mush = 1
					recent_level = 2.0
					mush_found = true
				elif collisions.get_collider() ==  %mushroomcap_2:
					mush_collide = collisions.get_collider()
					above_mush = 2
					recent_level = 2.0
					mush_found = true
				elif collisions.get_collider() ==  %mushroomcap_3:
					mush_collide = collisions.get_collider()
					above_mush = 3
					recent_level = 2.0
					mush_found = true
				elif collisions.get_collider() ==  %mushroomcap_4:
					mush_collide = collisions.get_collider()
					above_mush = 4
					recent_level = 2.0
					mush_found = true
				elif collisions.get_collider() ==  %mushroomcap_5:
					mush_collide = collisions.get_collider()
					above_mush = 5
					recent_level = 2.0
					mush_found = true
				elif collisions.get_collider() ==  %mushroomcap_6:
					mush_collide = collisions.get_collider()
					above_mush = 6
					recent_level = 2.0
					mush_found = true
				elif collisions.get_collider() ==  %mushroomcap_7:
					mush_collide = collisions.get_collider()
					above_mush = 7
					recent_level = 2.0
					mush_found = true
			#if !mush_found:
				#above_mush = 0				
			
			if above_mush != last_mush and Main.special_points != 7:
				#print(above_mush)
				if last_mush+1 == above_mush or above_mush == 1:
					if above_mush == 1:
						Main.special_points = 1
					else:
						Main.special_points += 1
					mush_collide.get_node("AudioStreamPlayer3D").play()
					if Main.special_points == 7:
						$"../mushroom_4/mushroomcap_4/AudioStreamPlayer3D2".play()
					$MusicLight.light_energy = 100.0
					recent_level = 4.0
					last_mush = above_mush
				else:
					if Main.special_points != 7 and Main.special_points != 0:
						Main.special_points = 0
						recent_level = 4.0
						last_mush = 0
				
			


			#if $ShadowCast.get_collider() == %mushroomcap_1:
		#
				#above_mush = 1
				#land_timer = 100
				#first_fall = false
			#elif $ShadowCast.get_collider() == %mushroomcap_2:
				#above_mush = 2
				#land_timer = 100
				#first_fall = false
			#elif $ShadowCast.get_collider() == %mushroomcap_3:
				#above_mush = 3
				#land_timer = 100
				#first_fall = false
			#elif $ShadowCast.get_collider() == %mushroomcap_4:
				#above_mush = 4
				#land_timer = 100
				#first_fall = false
			#elif $ShadowCast.get_collider() == %mushroomcap_5:
				#above_mush = 5
				#land_timer = 100
				#first_fall = false
			#elif $ShadowCast.get_collider() == %mushroomcap_6:
				#above_mush = 6
				#land_timer = 100
				#first_fall = false
			#elif $ShadowCast.get_collider() == %mushroomcap_7:
				#above_mush = 7
				#land_timer = 100
				#first_fall = false
			#else:
				#above_mush = 0
			##print(above_mush)	
			#
			#if last_mush+1 == above_mush:
				#Main.special_points += 1
				#recent_level = 4.0
			#else:
				#Main.special_points = 0
		#
			#print(above_mush)	
			#last_mush = above_mush



			
	#var collision = get_last_slide_collision()
	#if collision:
		#if collision.get_collider() is Area3D:
		#print(collision.get_collider().get_collision_layer())
	# Rotation
	#old_rotation = fmod(rotation_direction, PI)
	if !first_fall:

		if Vector2(velocity.z, velocity.x).length() > 0:

			rotation_direction = Vector2(velocity.z, velocity.x).angle()
		
		
	#lean -= delta*300*clamp((old_rotation-fmod(rotation_direction, PI)), -delta*300.0, delta*300.0)
		
		#@$Character.rotation.z += lean
	
	
	#lean = lerp(lean, 0.0, delta*8.0)
	#if abs(lean) < 0.01:
	#	lean = 0.0
		#print(velocity.x)


	if !first_fall:
		rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)

	# Falling/respawning

	#if position.y < -10:
	#	get_tree().reload_current_scene()

	# #animation for scale (jumping and landing)


	# #animation when landing

	if is_on_floor() and gravity > 0.4 and !previously_floored:
		
		
		land_timer = 0.0
		if first_fall:
			name_counter = 1
			rotation_degrees.x = 0.0
			first_fall = false
			$WindFall.stop()
			first_slew = true
		else:
			$Sfx/SfxLand.play()
		jump_timer = 0.0

		model.scale = Vector3(1.25, 0.5, 1.25)

		
		#Audio.play("res://sounds/land.ogg")

	previously_floored = is_on_floor()
	if !is_on_floor():
		land_timer += delta
# Handle #animation(s)

	if is_on_floor() and !dead:
		model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 7.0)

		if air_time > 0.2:
			$Particles/LandingParticles.emitting = true	
			$Particles/LandingParticles.restart()			
		air_time = 0.0
		
		var horizontal_velocity = Vector2(velocity.x, velocity.z)
		var speed_factor = horizontal_velocity.length() / movement_speed / delta
		if speed_factor > 0.15:
			idle_timer = 0.0
			$Character/uvliddell.scale.y = 1.0 + sin(Time.get_ticks_msec()/40.0)/18.0
			$Character/uvliddell.rotation.z = sin(Time.get_ticks_msec()/80.0)/18.0
			
			if door == null or !door.entered:
				
				if sin(Time.get_ticks_msec()/80.0) > 0.8:
					if !$Sfx/SfxFootstepsL.playing:
						$Sfx/SfxFootstepsL.play()
				elif sin(Time.get_ticks_msec()/80.0) < -0.8:
					if !$Sfx/SfxFootstepsR.playing:
						$Sfx/SfxFootstepsR.play()
				
				$Particles/WalkingParticles.emitting = true
			#print(speed_factor)
			#if #animation.current_#animation != "walk":
				#animation.play("walk", 0.1)
			animation_player.play("running_2")
			animation_player.speed_scale = speed_factor*2.3
		elif !first_zoom_out and !first_slew and !first_fall:
			idle_timer += delta
			$Particles/WalkingParticles.emitting = false
			animation_player.play("idle")
			animation_player.speed_scale = 1.0

			if speed_factor > 0.3:
				pass
	else:
		model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 3.0)

		$Particles/WalkingParticles.emitting = false
		air_time += delta
		if jump_single:
			animation_player.play("slide")
			animation_player.speed_scale = 2.5
		else:
			if !jump_single and !jump_double:
				animation_player.play("jump_2")
				animation_player.speed_scale = 0.5
			else:
				animation_player.play("jump")
				animation_player.speed_scale = 0.5


	var input := Vector3.ZERO
	if !dead and !door_opening and !first_fall and !first_slew:
		input.x = Input.get_axis("move_left", "move_right")
		input.z = Input.get_axis("move_forward", "move_back")

	input = input.rotated(Vector3.UP, view.rotation.y)

	if input.length() > 1:
		input = input.normalized()

	movement_velocity = input * movement_speed * delta

	# Jumping

	if Input.is_action_just_pressed("jump") and  !first_fall and !first_slew:
		first_zoom_out = false
		if jump_single or (jump_double and double_jump_allowed):
			jump_timer = 0.0
			air_time = 0.0
			$Sfx/SfxJump.play()
			if jump_double:
				#velocity.y -= 1000.0
				gravity = -0.5*jump_strength+abs(velocity.length())*0.11
			else:
				gravity -= 0.5*jump_strength+abs(velocity.length())*0.11

			model.scale = Vector3(0.5, 1.4, 0.5)
			if jump_single:
				$Particles/JumpParticles.emitting = true	
				$Particles/JumpParticles.restart()
				jump_single = false
				jump_double = true
			else:
				$Particles/LandingParticles.emitting = true	
				$Particles/LandingParticles.restart()
				jump_double = false
			animation_player.play("jump")

	if $ShadowCast.is_colliding():
		
		
		var distance = global_position.distance_to($ShadowCast.get_collision_point())
		%Shadow.global_position = $ShadowCast.get_collision_point()
		%Shadow.scale = Vector3(1.0-(distance/20.0), 1.0-(distance/20.0), 1.0-(distance/20.0))
		%Shadow.rotation = $ShadowCast.get_collision_normal()
		%Shadow.scale = clamp(%Shadow.scale, Vector3(0.1,0.1,0.1), Vector3.ONE)
	
	if !is_on_floor():
		
		$Character.rotation.z = lerp($Character.rotation.z, clamp((old_pos-rotation.y)*14.0,  -1.25	, 1.25)/3.3, delta*2.8)
	else:
		$Character.rotation.z = lerp($Character.rotation.z, clamp((old_pos-rotation.y)*14.0,  -1.25	, 1.25)/3.3, delta*10.8)
		
	if dead:
		animation_player.play("lay_down")
		
	if first_fall:
		#%GUI.overlay.modulate.a 
		rotation_degrees.x = 50.0
		rotation.y += delta*2.0
		#position.x = 313.678 + sin(Time.get_ticks_msec()/400.0)*2.5
		#position.z = -274.009 + sin(Time.get_ticks_msec()/500.0)*2.3
		#position.y = 700 + sin(Time.get_ticks_msec()/200.0)*0.3
	#$mesh.position.y = sin((random_offset*100.0) + Time.get_ticks_msec()/200.0)/6.0
	#$mesh.rotation.y += delta*3
	#$mesh.rotation.y = fmod($mesh.rotation.y, PI*2.0)

	if Main.player.first_slew and !first_fall:
		#%BackgroundMusic.volume_db -= delta*2.0
		if name_counter > 8:
			animation_player.play("lay_down")
			animation_player.speed_scale = lerp(animation_player.speed_scale, 1.8, delta)
		else:
			animation_player.speed_scale = 0.0
			animation_player.play("lay_still")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == Main.player:
		if !leaving_fish:
			Main.camera.fade_out = true
			leaving_fish = true
			$Sfx/SfxSplash.play()
	pass # Replace with function body.
