extends CharacterBody2D

class_name BossEnemy

# Constants
const SPEED: float = 100.0
const MAX_HEALTH: int = 4
const ATTACK_DAMAGE: int = 2
const ATTACK_INTERVAL: float = 5.0  # Time between attacks
const CHASE_DISTANCE: float = 300.0  # Distance to start chasing
const ATTACK_DISTANCE: float = 75.0  # Distance to attack
const SAFE_DISTANCE: float = 40.0  # Minimum distance to maintain from the player
const KNOCKBACK_FORCE: float = 200.0
const PUSH_BACK_FORCE: float = 50.0  # Push-back force when overlapping

# Variables
var dir: Vector2 = Vector2.ZERO  # Direction vector for movement
var is_boss_chase: bool = false
var health: int = MAX_HEALTH
var dead: bool = false
var can_attack: bool = true  # Controls attack cooldown
var player: Player_Boss = null

# Nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_sound: AudioStreamPlayer2D = $AttackSound


# Map boundaries
const MAP_BOUNDARY_TOP: float = -154.0
const MAP_BOUNDARY_BOTTOM: float = 235.0
const MAP_BOUNDARY_LEFT: float = -308.0
const MAP_BOUNDARY_RIGHT: float = 1834.0

func _ready() -> void:
	player = Global.player  # Access the global player reference
	if player == null:
		print("Player not found. Ensure Global.player is set correctly.")
	attack_area.connect("body_entered", Callable(self, "_on_attack_area_entered"))

func _physics_process(delta: float) -> void:
	if dead:
		return  # Prevent movement if dead

	if player != null:
		check_distance_to_player()

	if is_boss_chase:
		move_towards_player(delta)
	else:
		roam()

	enforce_boundaries()
	move_and_slide()

func check_distance_to_player() -> void:
	# Determine distance to the player
	var distance = global_position.distance_to(player.global_position)
	
	# Set chasing flag if within chase range
	if distance <= CHASE_DISTANCE:
		is_boss_chase = true
	else:
		is_boss_chase = false

func move_towards_player(delta: float) -> void:
	if player == null:
		return

	# Calculate direction toward the player
	var distance = global_position.distance_to(player.global_position)
	var direction = (player.global_position - global_position).normalized()

	if distance <= SAFE_DISTANCE:
		# Push back slightly to prevent overlapping
		var push_back = (global_position - player.global_position).normalized() * PUSH_BACK_FORCE
		move_and_collide(push_back)
		velocity = Vector2.ZERO
		animated_sprite.play("Idle")
	elif distance <= ATTACK_DISTANCE:
		# Stop moving and attack
		velocity = Vector2.ZERO
		if can_attack:
			animated_sprite.play("Attack")
			attack_sound.play()
			can_attack = false
			attack_player()
			await get_tree().create_timer(ATTACK_INTERVAL).timeout
			can_attack = true
	else:
		# Chase the player
		velocity = direction * SPEED
		animated_sprite.play("Idle")

	# Flip the sprite based on movement direction
	animated_sprite.flip_h = velocity.x > 0

func roam() -> void:
	if dir == Vector2.ZERO or randf() < 0.01:  # Occasionally change direction
		dir = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	velocity = dir * SPEED
	animated_sprite.play("Idle")
	animated_sprite.flip_h = dir.x > 0

func enforce_boundaries() -> void:
	# Prevent leaving the map boundaries
	if global_position.x < MAP_BOUNDARY_LEFT:
		global_position.x = MAP_BOUNDARY_LEFT
	if global_position.x > MAP_BOUNDARY_RIGHT:
		global_position.x = MAP_BOUNDARY_RIGHT
	if global_position.y < MAP_BOUNDARY_TOP:
		global_position.y = MAP_BOUNDARY_TOP
	if global_position.y > MAP_BOUNDARY_BOTTOM:
		global_position.y = MAP_BOUNDARY_BOTTOM

func _on_attack_area_entered(body: Node) -> void:
	# Attack player if they enter the attack range
	if body is Player_Boss and animated_sprite.get_animation() == "Attack":
		attack_player()

func attack_player() -> void:
	if !dead and player != null:
		player.take_damage(ATTACK_DAMAGE)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()
	else:
		animated_sprite.play("Idle")
		# Apply knockback in the opposite direction of the player
		var knockback_dir = (global_position - player.global_position).normalized()
		move_and_collide(knockback_dir * KNOCKBACK_FORCE)

func die() -> void:
	dead = true
	animated_sprite.play("Die")
	await get_tree().create_timer(4.5).timeout
	get_tree().change_scene_to_file("res://Scenes/ending_scene.tscn")
	queue_free()
