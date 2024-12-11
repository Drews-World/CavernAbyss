extends Area2D


func _on_body_entered(body: Node2D) -> void:
	
	if body == Global.playerBody:
		body.die()
	#await get_tree().create_timer(5.0).timeout  # Wait for 2 seconds to allow animation to finish
	#get_tree().reload_current_scene()  # Reset the scene
	
