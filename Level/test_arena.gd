extends Node2D

@export var spawners : Array[ZoneSpawner]

func _ready() -> void:
	for n in spawners:
		n.spawn_enemies(20,"res://Scenes/Enemy.tscn")
	
