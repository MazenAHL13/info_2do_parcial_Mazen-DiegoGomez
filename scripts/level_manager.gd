extends Node
# scripts/level_manager.gd

enum LevelType { MOVES, TIMED }

var level_type: int = LevelType.MOVES
var running: bool = false

var current_score: int = 0
var target_score: int = 0
var remaining_moves: int = 0
var remaining_time: int = 0

@onready var hud  = $"../top_ui"
@onready var timer := Timer.new()

func _ready() -> void:
	add_child(timer)
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(_on_timer_tick)
	start_timed_level(1500, 30)

func start_moves_level(target: int, moves: int) -> void:
	level_type = LevelType.MOVES
	running = true
	current_score = 0
	target_score = target
	remaining_moves = moves
	remaining_time = 0

	if hud:
		hud.set_mode_moves()
		hud.set_score(current_score)
		hud.set_moves(remaining_moves)

	timer.stop() 

func start_timed_level(target: int, seconds: int) -> void:
	level_type = LevelType.TIMED
	running = true
	current_score = 0
	target_score = target
	remaining_moves = 0
	remaining_time = max(0, seconds)

	if hud:
		hud.set_mode_timed()
		hud.set_score(current_score)
		hud.set_time(remaining_time)

	timer.start()  

func _on_timer_tick() -> void:
	if not running: return
	if level_type != LevelType.TIMED: return

	remaining_time -= 1
	if hud:
		hud.set_time(remaining_time)

	if remaining_time <= 0:
		timer.stop()
		running = false
		
