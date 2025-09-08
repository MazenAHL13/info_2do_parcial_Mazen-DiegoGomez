extends Control

func _ready() -> void:
	$Background/btn_moves_easy.pressed.connect(_on_moves_easy)
	$Background/btn_moves_hard.pressed.connect(_on_moves_hard)
	$Background/btn_timed_easy.pressed.connect(_on_timed_easy)
	$Background/btn_timed_hard.pressed.connect(_on_timed_hard)

func _on_moves_easy() -> void:
	get_tree().change_scene_to_file("res://scenes/game_moves_easy.tscn")

func _on_moves_hard() -> void:
	get_tree().change_scene_to_file("res://scenes/game_moves_hard.tscn")

func _on_timed_easy() -> void:
	get_tree().change_scene_to_file("res://scenes/game_timed_easy.tscn")

func _on_timed_hard() -> void:
	get_tree().change_scene_to_file("res://scenes/game_timed_hard.tscn")
