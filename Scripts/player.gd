extends CharacterBody2D

class_name Player3

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_HEALTH = 5
var GRAVITY: float  # Gravity constant to be initialized in _ready()

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_sound: AudioStreamPlayer2D = $AttackSound


var current_attack: bool = false
var health: int = MAX_HEALTH
var dir: int = 1  # Direction the player is facing (1 for right, -1 for left)
var dead: bool = false  # Flag to check if the player is dead

func _ready() -> void:
	current_attack = false
	GRAVITY = 900.0

	# Connect the attack area collision signal using Callable
	attack_area.connect("body_entered", Callable(self, "_on_attack_area_entered"))
	Global.player = self

func _physics_process(delta: float) -> void:
	if dead:
		# Prevent any movement or actions if the player is dead
		return

	if !is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle movement
	var direction := Input.get_axis("move_left", "move_right")

	# Handle movement and animations
	if !current_attack:
		if direction > 0:
			dir = 1
			animated_sprite.play("RunRight")
		elif direction < 0:
			dir = -1
			animated_sprite.play("RunLeft")
		else:
			animated_sprite.play("Idle")

	velocity.x = direction * SPEED

	# Attack logic
	if Input.is_action_just_pressed("Attack") and !current_attack:
		current_attack = true
		animated_sprite.play("Attack" if dir == 1 else "AttackLeft")
		attack_sound.play()

	# Reset attack flag when animation ends
	if !animated_sprite.is_playing() and current_attack:
		current_attack = false

	move_and_slide()

# When player’s attack hits the enemy
func _on_attack_area_entered(body: Node) -> void:
	# Ensure the object is a GoblinEnemy and player is in attack mode
	if body is GoblinEnemy and current_attack:
		var goblin = body as GoblinEnemy
		goblin.take_damage(1)  # Calls take_damage on goblin
		apply_knockback(goblin)  # Apply knockback effect

func take_damage(amount: int) -> void:
	if dead or current_attack:
		return  # If already dead, ignore further damage

	health -= amount
	if health <= 0:
		die()
	else:
		animated_sprite.play("Idle")

func die() -> void:
	dead = true  # Set dead flag to prevent further actions
	animated_sprite.play("Die")
	await get_tree().create_timer(5.0).timeout  # Wait for 2 seconds to allow animation to finish
	get_tree().reload_current_scene()  # Reset the scene

func apply_knockback(enemy: GoblinEnemy) -> void:
	enemy.velocity = Vector2(dir * -200, -100)  # Apply knockback effect with upward movement
