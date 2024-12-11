extends Area2D

@onready var timer: Timer = $Timer

var isHurt = false
var pain_timer = 0



func _on_body_entered(body: CharacterBody2D) -> void:
	body.take_damage(1)
	if(body == Global.playerBody):
		isHurt = true
		timer.start()
	else:
		body.die()

func _on_body_exited(body: Node2D) -> void:
	if body == Global.playerBody:
		isHurt = false
		timer.stop()
		

func _on_timer_timeout() -> void:
	if isHurt == true:
		Global.playerBody.take_damage(1)
