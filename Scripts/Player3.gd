extends CharacterBody2D

class_name PlayerBoss

const SPEED = 300.0
const MAX_HEALTH = 5
var health: int = MAX_HEALTH
var current_attack: bool = false
var dir: int = 1  # Direction the player is facing (1 for right, -1 for left)
var dead: bool = false  # Flag to check if the player is dead

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea

func _ready() -> void:
	current_attack = false

	# Connect the attack area collision signal using Callable
	attack_area.connect("body_entered", Callable(self, "_on_attack_area_entered"))
	Global.player = self  # Set the player reference in the global script

func _physics_process(delta: float) -> void:
	if dead:
		# Prevent movement and actions if the player is dead
		return

	# Handle movement
	var movement_direction = Vector2.ZERO
	movement_direction.x = Input.get_axis("move_left", "move_right")
	movement_direction.y = Input.get_axis("move_up", "move_down")

	# Apply movement speed
	velocity = movement_direction * SPEED

	# Handle animations
	if !current_attack:
		if movement_direction.x > 0:
			dir = 1
			animated_sprite.play("RunRight")
		elif movement_direction.x < 0:
			dir = -1
			animated_sprite.play("RunLeft")
		elif movement_direction.y != 0:
			animated_sprite.play("RunRight" if dir == 1 else "RunLeft")  # Play running animation in the current direction
		else:
			animated_sprite.play("Idle")

	# Attack logic
	if Input.is_action_just_pressed("Attack") and !current_attack:
		current_attack = true
		animated_sprite.play("Attack" if dir == 1 else "AttackLeft")

	# Reset attack flag when the animation ends
	if !animated_sprite.is_playing() and current_attack:
		current_attack = false

	# Apply movement
	move_and_slide()

# When player's attack hits the enemy
func _on_attack_area_entered(body: Node) -> void:
	if body is BossEnemy and current_attack:  # Ensure the enemy is hit only during an attack
		var boss = body as BossEnemy
		boss.take_damage(1)  # Apply damage to the boss
		apply_knockback(boss)  # Apply knockback effect to the boss

func take_damage(amount: int) -> void:
	if dead:
		return  # Ignore further damage if the player is already dead

	health -= amount
	if health <= 0:
		die()
	else:
		animated_sprite.play("Hurt")

func die() -> void:
	dead = true  # Set dead flag
	animated_sprite.play("Die")
	await get_tree().create_timer(5.0).timeout  # Allow the death animation to play fully
	get_tree().reload_current_scene()  # Reset the scene after death

func apply_knockback(enemy: BossEnemy) -> void:
	enemy.velocity = Vector2(dir * -200, -100)  # Apply knockback effect