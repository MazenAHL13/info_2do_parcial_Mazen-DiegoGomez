extends TextureRect

@onready var score_label = $MarginContainer/HBoxContainer/score_label
@onready var counter_label = $MarginContainer/HBoxContainer/counter_label

# top_ui.gd

func set_score(n: int) -> void:
	if score_label:
		score_label.text = str(n)

func set_moves(n: int) -> void:
	if counter_label:
		counter_label.text = str(n)

func set_time(seconds: int) -> void:
	if counter_label:
		counter_label.text = str(seconds)

func set_mode_moves() -> void:
	if counter_label:
		counter_label.text = "0"  
		
func set_mode_timed() -> void:
	if counter_label:
		counter_label.text = "0" 
		
func _ready() -> void:
	set_score(0)       
	set_mode_moves()    
	set_moves(15)       
