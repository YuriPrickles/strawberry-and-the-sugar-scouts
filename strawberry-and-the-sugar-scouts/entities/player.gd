extends CharacterBody3D

@onready var CameraPivot = $CameraPivot

const SPEED = 5
const JUMP_VELOCITY = 7
const FALL_VELOCITY = 32
const look_sensitivity = 1500

var jump_released
var juffer:Timer = Timer.new()
var coyote_time:Timer = Timer.new()

var is_going_up:bool = false
var is_jumping: bool = false
var last_frame_on_floor:bool = false

func _init() -> void:
	coyote_time.one_shot = true
	juffer.one_shot = true
	coyote_time.wait_time = 0.14
	juffer.wait_time = 0.2
	coyote_time.name = "CoyoteTimer"
	juffer.name = "Juffer"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_timers()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y <= 0.4:
			velocity.y -= FALL_VELOCITY * delta

	# Handle jump.
	handle_jump(Input.is_action_just_pressed("jump"))
	if Input.is_action_just_released("jump"):
		velocity.y = 0
	jump_released = !Input.is_action_pressed("jump")
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:  
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

#region Jump Logic
func handle_jump(want_to_jump:bool) -> void:
	if just_landed():
		is_jumping = false
	
	if is_allowed_to_jump(want_to_jump):
		jump()
		
	handle_juffer(want_to_jump)
	handle_coyote_time()
		
	is_going_up = velocity.y < 0 and not is_on_floor()
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
	is_jumping = true
	coyote_time.stop()
	velocity.y = JUMP_VELOCITY

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
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / look_sensitivity
		CameraPivot.rotation.x -= event.relative.y / look_sensitivity
		CameraPivot.rotation.x = clamp(CameraPivot.rotation.x, deg_to_rad(-90), deg_to_rad(0))
func add_timers():
	get_tree().root.add_child.call_deferred(juffer)
	get_tree().root.add_child.call_deferred(coyote_time)
