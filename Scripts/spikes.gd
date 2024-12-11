extends Area2D

@onready var timer: Timer = $Timer  # Optional, for delayed scene reload

func _on_area_entered(body: Node) -> void:
	# if body is Player:  # Ensure the object entering is the Player
		body.die()  # Trigger the player's death logic

		# Optional: Add a delay before reloading the scene
		if timer:
			timer.start()
		else:
			get_tree().reload_current_scene()

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
