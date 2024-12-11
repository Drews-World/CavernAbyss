extends CharacterBody2D

@onready var timer: Timer = $Timer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hunt_radius: CollisionShape2D = $"Detection Area/Hunt radius"
@onready var hunt_start: AudioStreamPlayer2D = $hunt_start
@onready var song: AudioStreamPlayer2D = $"sound range/CollisionShape2D/Song"



const SPEED = 100.0		# speed of Bee
const MAX_HP = 3

var dir: Vector2		# direction that the bee is headed
var is_bee_hunting: bool# Is the Bee hunting the player
var player : CharacterBody2D


# Life details
var health = MAX_HP
var dead = false

func _ready():
	is_bee_hunting = false

func _physics_process(delta: float) -> void:
	move(delta)

func move(delta):
	if is_bee_hunting:
		if Global.playerBody == null:
			return  # Exit if playerBody is not set
		player = Global.playerBody
		velocity += (player.position - position).normalized() * SPEED / 25
		dir.x = (abs(velocity.x) / velocity.x)
	else:
		velocity += dir * SPEED * delta
	move_and_slide()
	
	#play movement
	animateMove()
	velocity -= velocity/100

func _on_timer_timeout() -> void:
	timer.wait_time = choose([.5, .8, 1.0])
	
	#check for player follow
	if !is_bee_hunting:
		dir = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])


func choose(array): 
	array.shuffle()
	return array.front()
	
#animates moving sprite the sprite
func animateMove():
	animated_sprite.play("Fly")
	#check for direction
	if dir.x == -1:
		animated_sprite.flip_h =true
	else:
		animated_sprite.flip_h = false
	
	
# Function for enemy Death
func die() -> void:
	dead = true  # Set dead flag to prevent further actions
	animated_sprite.play("Die")
	
# Function when enemy takes Damage
func take_damage(amount: int) -> void:
	if dead:
		return  # If already dead, ignore further damage

	health -= amount
	if health <= 0:
		die()
	else:
		animated_sprite.play("Hurt")
		
		
# Check for player enter
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body == Global.playerBody:
		is_bee_hunting = true
		hunt_start.play()


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == Global.playerBody:
		is_bee_hunting = false









func _on_sound_range_body_entered(body: Node2D) -> void:
	if body == Global.playerBody:
		song.play()



func _on_sound_range_body_exited(body: Node2D) -> void:
	if body == Global.playerBody:
		song.stop()
