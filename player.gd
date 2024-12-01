extends CharacterBody3D


@export var mouse_sensitivity = 1.0
@export var head_bobbing = true
@export var head_bobbing_strength = 1.0
@export var head_bobbing_speed = 1.0


const SPEED = 6.0
const JUMP_VELOCITY = 14.5


func _init() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		if head_bobbing:
			$Camera3D.position.y = lerp($Camera3D.position.y, 1.45 + head_bobbing_strength * velocity.length() * sin(head_bobbing_speed * (Time.get_ticks_msec() / 75.0)) / 50.0, delta * 14.0)

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _input(event):
	if event is InputEventMouseButton and 	Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity/500.0)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity/500.0)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))
