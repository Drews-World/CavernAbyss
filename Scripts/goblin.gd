extends CharacterBody2D

class_name GoblinEnemy

const SPEED: float = 100.0
const GRAVITY: float = 900.0
const MAX_HEALTH: int = 2
const ATTACK_DAMAGE: int = 1
const ATTACK_INTERVAL: float = 2.0  # Time in seconds between attacks
const KNOCKBACK_FORCE: float = 200.0

var dir: Vector2 = Vector2.RIGHT
var is_goblin_chase: bool = false
var health: int = MAX_HEALTH
var dead: bool = false
var can_attack: bool = true  # Controls attack cooldown

@onready var animated_sprite = $AnimatedSprite2D
@onready var player: CharacterBody2D = null
@onready var attack_area: Area2D = $AttackArea
@onready var raycast_right: RayCast2D = $RayCastRight
@onready var raycast_left: RayCast2D = $RayCastLeft
@onready var raycast_floor: RayCast2D = $RayCastFloor
@onready var attack_sound: AudioStreamPlayer2D = $AttackSound


func _ready() -> void:
	raycast_right.enabled = true
	raycast_left.enabled = true
	raycast_floor.enabled = true
	player = Global.player  # Access the global player reference

	# Connect to the attack area signal
	attack_area.connect("body_entered", Callable(self, "_on_attack_area_entered"))
	attack_area.connect("body_exited", Callable(self, "_on_attack_area_exited"))

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	if !dead:
		check_distance_to_player()
		move_and_slide()

func check_distance_to_player() -> void:
	if player == null:  # Add a null check for the player
		return
	var distance = global_position.distance_to(player.global_position)
	if distance < 200:
		is_goblin_chase = true
	else:
		is_goblin_chase = false

	if is_goblin_chase and !can_attack:
		dir.x = 1 if player.global_position.x > global_position.x else -1
		velocity.x = 0  # Stop moving when close to attack
		animated_sprite.play("Attack")
	elif is_goblin_chase:
		dir.x = 1 if player.global_position.x > global_position.x else -1
		velocity.x = dir.x * SPEED
	else:
		roam()
		animated_sprite.play("Walk")

	# Flip goblin sprite based on direction
	animated_sprite.flip_h = dir.x < 0

func roam() -> void:
	if (dir == Vector2.RIGHT and raycast_right.is_colliding()) or (dir == Vector2.LEFT and raycast_left.is_colliding()) or !raycast_floor.is_colliding():
		dir.x = -dir.x
	velocity.x = dir.x * SPEED

# Player enters attack range
func _on_attack_area_entered(body: Node) -> void:
	if body is Player3 and can_attack:  # Type check for Player object
		animated_sprite.play("Attack")
		attack_sound.play()
		can_attack = false
		attack_player()
		await get_tree().create_timer(ATTACK_INTERVAL).timeout
		can_attack = true

# Player exits attack range
func _on_attack_area_exited(body: Node) -> void:
	if body == player:
		is_goblin_chase = false

func attack_player() -> void:
	if !dead and player.health > 0:
		player.take_damage(ATTACK_DAMAGE)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()
	else:
		animated_sprite.play("Hurt")
		# Apply knockback to the goblin in the opposite direction of the player
		velocity = Vector2(-dir.x * KNOCKBACK_FORCE, -500)

func die() -> void:
	dead = true
	animated_sprite.play("Die")
	await get_tree().create_timer(1.5).timeout  # Slight delay before disappearing
	queue_free()
