class_name Player
extends CharacterBody3D

@onready var CameraPivot = $CameraPivot

var SPEED = 7
var DASH_SPEED = 24
var DASH_COOLDOWN = 0.2
var JUMP_VELOCITY = 8
var FALL_VELOCITY = 16
var FLOAT_VELOCITY = 3
var COYOTE_TIME = 0.2
var JUMP_BUFFER_TIMER = 0.14
var JUMP_CHAIN_GRACE_TIMER = 0.1
var SUPERDASH_GRACE_TIMER = 0.2
var look_sensitivity = 1500

var saved_delta = 0.0167

var juffer:Timer = Timer.new()
var coyote_time:Timer = Timer.new()
var dash_cooldown_timer:Timer = Timer.new()
var jump_chain_grace:Timer = Timer.new()
var superdash_grace:Timer = Timer.new()

var is_going_up:bool = false
var is_jumping: bool = false
var last_frame_on_floor:bool = false
var jump_chain = 0
var max_jump_chain = 2

var any_move_input:bool = false
var last_saved_direction:Vector3 = Vector3(1,0,0)
var dashes = 1
var max_dashes = 1
var dashing = false

var floating = false

func _init() -> void:
	coyote_time.one_shot = true
	juffer.one_shot = true
	dash_cooldown_timer.one_shot = true
	jump_chain_grace.one_shot = true
	superdash_grace.one_shot = true
	
	coyote_time.wait_time = COYOTE_TIME
	juffer.wait_time = JUMP_BUFFER_TIMER
	dash_cooldown_timer.wait_time = DASH_COOLDOWN
	jump_chain_grace.wait_time = JUMP_CHAIN_GRACE_TIMER
	superdash_grace.wait_time = SUPERDASH_GRACE_TIMER
	
	coyote_time.name = "CoyoteTimer"
	juffer.name = "Juffer"
	dash_cooldown_timer.name = "DashCDTimer"
	jump_chain_grace.name = "JumpChainGraceTimer"
	superdash_grace.name = "SuperdashGraceTimer"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_timers()

func _physics_process(delta: float) -> void:
	
	handle_float(Input.is_action_pressed("float"))
	saved_delta = delta
	if not is_on_floor():
		if not dashing:
			velocity += get_gravity() * delta * 4
			if is_falling():
				if floating:
					velocity.y = -FLOAT_VELOCITY
				else:
					velocity.y -= FALL_VELOCITY * delta
		else:
			velocity.y = clamp(velocity.y, 0, INF)
	else:
		dashes = max_dashes
		
	handle_jump(Input.is_action_just_pressed("jump"))
	dash(Input.is_action_just_pressed("dash"),last_saved_direction)
	
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if not dashing:
		if direction:
			velocity.x = move_toward(velocity.x, direction.x * SPEED, SPEED * 0.3) 
			velocity.z = move_toward(velocity.z, direction.z * SPEED, SPEED * 0.3)
			last_saved_direction = direction
			any_move_input = true
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			any_move_input = false

	move_and_slide()
	
func dash(dash_input:bool, direction):
	if dashes > 0 and dash_input and dash_cooldown_timer.is_stopped():
		dashing = true
		velocity.x = direction.x * DASH_SPEED
		velocity.z = direction.z * DASH_SPEED
		dashes -= 1
		dash_cooldown_timer.start()
		superdash_grace.start()
		await get_tree().create_timer(0.1).timeout
		dashing = false

func is_falling():
	return velocity.y <= 0.4 and not is_on_floor()

func handle_float(float_input:bool):
	if is_falling() and float_input:
		floating = true
	else:
		floating = false

#region Jump Logic
func handle_jump(want_to_jump:bool) -> void:
	if just_landed():
		jump_chain_grace.start()
		is_jumping = false
	
	if is_allowed_to_jump(want_to_jump):
		jump()
		
	handle_juffer(want_to_jump)
	handle_coyote_time()
		
	is_going_up = velocity.y > 0 and not is_on_floor()
	last_frame_on_floor = is_on_floor()

func just_landed() -> bool:
	return is_on_floor() and not last_frame_on_floor and is_jumping
	
func handle_juffer(want_to_jump:bool) -> void:
	if want_to_jump and not is_on_floor():
		juffer.start()
		
	if is_on_floor() and not juffer.is_stopped():
		jump()

func jump():
	juffer.stop()
	coyote_time.stop()
	
	if jump_chain_grace.time_left > 0 and not jump_chain_grace.is_stopped() and any_move_input:
		jump_chain = min(jump_chain + 1, max_jump_chain)
	else:
		jump_chain = 1
	jump_chain_grace.stop()
	
	is_jumping = true
	
	if not dashing:
		velocity.x += velocity.x * 0.4
		velocity.z += velocity.z * 0.4
	if not superdash_grace.is_stopped():
		print(superdash_grace.time_left)
		velocity.x = last_saved_direction.x * 56
		velocity.z = last_saved_direction.z * 56
	velocity.y = JUMP_VELOCITY * 2 * (1 + ((jump_chain - 1) * 0.4))

func is_allowed_to_jump(want_to_jump:bool) -> bool:
	return want_to_jump and (is_on_floor() or not coyote_time.is_stopped())

func has_stepped_off_ledge() -> bool:
	return not is_on_floor() and last_frame_on_floor and not is_jumping
	
func handle_coyote_time() -> void:
	if not is_on_floor() and last_frame_on_floor and not is_jumping:
		coyote_time.start()
	if not coyote_time.is_stopped() and not is_jumping:
		velocity.y = 0
		
	if is_on_floor() and not juffer.is_stopped():
		jump()
#endregion

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		var joystick_vector = Input.get_vector("gp_look_left", "gp_look_right", "gp_look_up", "gp_look_down")
		rotation.y -= joystick_vector.x
		CameraPivot.rotation.x -= joystick_vector.y
		CameraPivot.rotation.x = clamp(CameraPivot.rotation.x, deg_to_rad(-90), deg_to_rad(0))
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / look_sensitivity
		CameraPivot.rotation.x -= event.relative.y / look_sensitivity
		CameraPivot.rotation.x = clamp(CameraPivot.rotation.x, deg_to_rad(-90), deg_to_rad(0))
func add_timers():
	get_tree().root.add_child.call_deferred(juffer)
	get_tree().root.add_child.call_deferred(coyote_time)
	get_tree().root.add_child.call_deferred(dash_cooldown_timer)
	get_tree().root.add_child.call_deferred(jump_chain_grace)
	get_tree().root.add_child.call_deferred(superdash_grace)
