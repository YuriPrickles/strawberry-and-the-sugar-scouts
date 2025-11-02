class_name Player
extends CharacterBody3D

@onready var CameraPivot:Marker3D = $CameraPivot
@onready var StrawberryModel:Node3D = $Strawberry
@onready var StrawberryAnim:AnimationPlayer = $Strawberry/AnimationPlayer

var SPEED = 7
var DASH_SPEED = 32
var DASH_COOLDOWN = 0.2
var DASH_ATTACK = 0.2 ##Similar to hit indie platformer Celeste, dash attack is the small window of time where the player is still considered dashing even after the dash has ended.
var DESCEND_SPEED = 30
var DESCEND_REST_TIME = 0.2
var JUMP_VELOCITY = 8
var FALL_VELOCITY = 16
var FLOAT_VELOCITY = 3
var COYOTE_TIME = 0.08
var JUMP_BUFFER_TIME = 0.14
var JUMP_CHAIN_GRACE_TIME = 0.1
var SUPERDASH_GRACE_TIME = 0.2
var INVINCIBILITY_TIME = 0.2
var look_sensitivity = 1500

var saved_delta = 0.0167

var juffer:Timer = Timer.new()
var coyote_time:Timer = Timer.new()
var dash_cooldown_timer:Timer = Timer.new()
var jump_chain_grace:Timer = Timer.new()
var superdash_grace:Timer = Timer.new()
var inv_frames_timer:Timer = Timer.new()
var dash_attack_timer:Timer = Timer.new()
var descend_rest_timer:Timer = Timer.new()

var is_going_up:bool = false
var is_jumping: bool = false
var last_frame_on_floor:bool = false
var jump_chain = 0
var max_jump_chain = 2
var force_jumping = false

var any_move_input:bool = false
var last_saved_direction:Vector3 = Vector3(1,0,0)

var dashes = 1
var max_dashes = 1
var dash_attacking = false ##Handles interactions with dashable things.
var dashing = false

var floating = false
var descending = false
var descending_anim = false

var last_safe_position:Vector3
var health:int = 4
var max_health:int = 4

var can_move = true
var direction:Vector3

func _init() -> void:
	coyote_time.one_shot = true
	juffer.one_shot = true
	dash_cooldown_timer.one_shot = true
	jump_chain_grace.one_shot = true
	superdash_grace.one_shot = true
	inv_frames_timer.one_shot = true
	dash_attack_timer.one_shot = true
	descend_rest_timer.one_shot = true
	
	coyote_time.wait_time = COYOTE_TIME
	juffer.wait_time = JUMP_BUFFER_TIME
	dash_cooldown_timer.wait_time = DASH_COOLDOWN
	jump_chain_grace.wait_time = JUMP_CHAIN_GRACE_TIME
	superdash_grace.wait_time = SUPERDASH_GRACE_TIME
	inv_frames_timer.wait_time = INVINCIBILITY_TIME
	dash_attack_timer.wait_time = DASH_ATTACK
	descend_rest_timer.wait_time = DESCEND_REST_TIME
	
	coyote_time.name = "CoyoteTimer"
	juffer.name = "Juffer"
	dash_cooldown_timer.name = "DashCDTimer"
	jump_chain_grace.name = "JumpChainGraceTimer"
	superdash_grace.name = "SuperdashGraceTimer"
	inv_frames_timer.name = "InvincibilityTimer"
	dash_attack_timer.name = "DashAttackTimer"
	descend_rest_timer.name = "DescendRestTimer"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_timers()

func _physics_process(delta: float) -> void:
	if not can_move: return
	handle_float(Input.is_action_pressed("float"))
	saved_delta = delta
	if not is_on_floor() and not descending:
		if not dashing:
			velocity += get_gravity() * delta * 4
			if is_falling():
				if floating:
					velocity.y = -FLOAT_VELOCITY
				else:
					velocity.y -= FALL_VELOCITY * delta
		else:
			velocity.y = clamp(velocity.y, 0, INF)
	elif not dashing:
		dashes = max_dashes
	if is_on_floor():
		force_jumping = false
	if is_on_floor() and descending:
		velocity = Vector3.ZERO
		descend_rest_timer.start()
		descending = false
	descending_anim = descending or not descend_rest_timer.is_stopped()
	handle_jump(Input.is_action_just_pressed("jump"))
	if await dash(Input.is_action_just_pressed("dash"),last_saved_direction) and dash_attack_timer.is_stopped():
		dash_attack_timer.start()
		await dash_attack_timer.timeout
		dash_attacking = false
	handle_descend(Input.is_action_just_pressed("descend"))
	
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized().rotated(CameraPivot.position,CameraPivot.rotation.y)
	if not dashing and not descending and descend_rest_timer.is_stopped():
		if direction:
			velocity.x = move_toward(velocity.x, direction.x * SPEED, SPEED * 0.3) 
			velocity.z = move_toward(velocity.z, direction.z * SPEED, SPEED * 0.3)
			last_saved_direction = direction
			var dir_vector:Vector2 = Vector2(direction.x,direction.z)
			StrawberryModel.rotation.y = wrapf(rotate_toward(StrawberryModel.rotation.y, -dir_vector.angle() + deg_to_rad(90), delta * 10),-PI,PI)
			any_move_input = true
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			any_move_input = false
	handle_animations()
	move_and_slide()

func handle_animations():
	if descending_anim:
		StrawberryAnim.play("strawberry_anims/Strawberry_Descend_Animation")
		return
	if dash_attacking:
		StrawberryAnim.play("strawberry_anims/Strawberry_Dash_Animation")
		return
	if floating:
		StrawberryAnim.play("strawberry_anims/Strawberry_Glide_Animation")
		return
	if is_falling():
		StrawberryAnim.play("strawberry_anims/Strawberry_Fall_Animation")
		return
	if is_jumping:
		if last_frame_on_floor:
			StrawberryAnim.play("strawberry_anims/Strawberry_Jump_Animation")
			return
		return
	if any_move_input:
		StrawberryAnim.play("strawberry_anims/Strawberry_Run_Animation")
		return
	else:
		StrawberryAnim.play("strawberry_anims/Strawberry_Idle_Animation-loop")

func hurt(unrecoverable:bool=false):
	health -= 1
	LevelManager.current_session.damage_taken += 1
	HUD.update_health()
	if health < 1:
		await kill()
		return
	if unrecoverable:
		inv_frames_timer.start(2)
		await State.respawn_player()
	else:
		inv_frames_timer.start(0.5)

func kill():
	LevelManager.set_session_timer_ignore_pauses(true)
	get_tree().paused = true
	Transitioner.do_transition(0.1)
	await State.faded_in
	LevelManager.get_current_level().respawn_room(true)
	health = max_health
	LevelManager.current_session.deaths += 1
	HUD.update_health()
	await State.faded_out
	get_tree().paused = false
	LevelManager.set_session_timer_ignore_pauses(false)

func dash(dash_input:bool, dash_direction) -> bool:
	if not dashing and dashes > 0 and dash_input and dash_cooldown_timer.is_stopped():
		dashing = true
		dash_attacking = true
		velocity.x = dash_direction.x * DASH_SPEED
		velocity.z = dash_direction.z * DASH_SPEED
		var dir_vector:Vector2 = Vector2(dash_direction.x,dash_direction.z)
		StrawberryModel.rotation.y = rotate_toward(StrawberryModel.rotation.y, -dir_vector.angle() + deg_to_rad(90), 10000)
		dashes -= 1
		dash_cooldown_timer.start()
		superdash_grace.start()
		await get_tree().create_timer(0.1).timeout
		dashing = false
		return true
	return false

func is_falling():
	return velocity.y <= 0.4 and not is_on_floor() and not descending

func handle_descend(descend_input):
	if not is_on_floor() and descend_input:
		velocity.x = 0
		velocity.z = 0
		velocity.y = -DESCEND_SPEED
		descending = true

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
	return is_on_floor() and not last_frame_on_floor and is_jumping and not force_jumping
	
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
		velocity.x = last_saved_direction.x * 56
		velocity.z = last_saved_direction.z * 56
	velocity.y = JUMP_VELOCITY * 2 * (1 + ((jump_chain - 1) * 0.4))

func force_jump(jump_speed=JUMP_VELOCITY):
	juffer.stop()
	coyote_time.stop()
	is_jumping = true
	force_jumping = true
	velocity.y = jump_speed

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
	if not State.no_cam_control:
		if event is InputEventJoypadMotion:
			var joystick_vector = Input.get_vector("gp_look_left", "gp_look_right", "gp_look_up", "gp_look_down")
			rotation.y -= joystick_vector.x
			CameraPivot.rotation.x -= joystick_vector.y
			CameraPivot.rotation.x = clamp(CameraPivot.rotation.x, deg_to_rad(-90), deg_to_rad(0))
		if event is InputEventMouseMotion:
			CameraPivot.rotation.x -= event.relative.y / look_sensitivity
			CameraPivot.rotation.x = clamp(CameraPivot.rotation.x, deg_to_rad(-90), deg_to_rad(0))
			CameraPivot.rotation.y -= event.relative.x / look_sensitivity



func add_timers():
	get_tree().root.add_child.call_deferred(juffer)
	get_tree().root.add_child.call_deferred(coyote_time)
	get_tree().root.add_child.call_deferred(dash_cooldown_timer)
	get_tree().root.add_child.call_deferred(jump_chain_grace)
	get_tree().root.add_child.call_deferred(superdash_grace)
	get_tree().root.add_child.call_deferred(inv_frames_timer)
	get_tree().root.add_child.call_deferred(dash_attack_timer)
	get_tree().root.add_child.call_deferred(descend_rest_timer)
