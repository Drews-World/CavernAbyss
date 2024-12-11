extends Area2D

@export var next_scene: String = "res://Scenes/pre_boss_fight.tscn" 

func _on_body_entered(body: Node2D) -> void:
	if body is Player3:  # Check if the player is entering the door
		get_tree().change_scene_to_file(next_scene) 
