extends Node2D


func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")


func _on_skip_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")