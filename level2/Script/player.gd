extends CharacterBody2D

const SPEED = 175.0
const JUMP_VELOCITY = -350.0
const MAX_HEALTH = 5

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var coytee_time: Timer = $Coytee_time


var health = MAX_HEALTH		#health variable
var dead = false			#Keeps track of Living state


func _ready():
	Global.playerBody = self

func _physics_process(delta: float) -> void:
	
	#Prevents movement if dead
	if dead:
		# Prevent any movement or actions if the player is dead
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() || !coytee_time.is_stopped()):
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	#checks and applies animation
	
		
	if is_on_floor():
		
		if direction > 0:
			animated_sprite_2d.play("Run_Right")
		elif direction < 0:
			animated_sprite_2d.play("Run_Left")
		else:
			animated_sprite_2d.play("Idle")
	else:
		if direction > 0:
			animated_sprite_2d.play("Jump_Right")
		elif direction < 0:
			animated_sprite_2d.play("Jump_Left")
	
	
	# Applies movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	if was_on_floor && !is_on_floor():
		coytee_time.start()



func die() -> void:
	dead = true  # Set dead flag to prevent further actions
	animated_sprite_2d.play("Die")
	await get_tree().create_timer(3.0).timeout  # Wait for 2 seconds to allow animation to finish
	get_tree().reload_current_scene()  # Reset the scene
	
func take_damage(amount: int) -> void:
	if dead:
		return  # If already dead, ignore further damage

	health -= amount
	if health <= 0:
		die()
	else:
		animated_sprite_2d.play("Hurt")
		
		
		
