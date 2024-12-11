extends CharacterBody2D


var direction: Vector2 = Vector2.ZERO
@export var speed: int = 300

func _process(delta):
	direction = Input.get_vector("move_left","move_right","move_up","move_down")
	
func _physics_process(delta):
	velocity = direction * speed
	move_and_slide()
