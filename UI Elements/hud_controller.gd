extends Control

@export_category("Player Infomation Bars")
@export var health_bar : ProgressBar
@export var special_bar : ProgressBar
@export var experience_bar : ProgressBar

@export_category("Player Stat Labels")
@export var wave_label : Label
@export var level_label : Label


func set_wave (value : int):
	wave_label.text = str(value)

func set_level (value : int):
	level_label.text = str(value)

func _on_health_changed(current_value : int, max_value : int):
	health_bar.value = current_value
	health_bar.max_value = max_value

func _on_special_changed(current_value : int, max_value : int):
	special_bar.value = current_value
	special_bar.max_value = max_value

func _on_experience_changed(current_value : int, max_value : int):
	experience_bar.value = current_value
	experience_bar.max_value = max_value

