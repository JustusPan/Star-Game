#need to fix
extends Node2D

var name
var race
var ships = []
var current_ship
var current_ship_instance = {'hull': null, 'status': null, 'cargo': null}
var controls
var scale = Vector2(1, 1)
var speed = 0
var rotate

func _ready():
	name = 'player'
	race = 'terran'
	controls = preload('res://player/player_control.gd').new()
	add_child(controls)
	set_process(true)
	

func _process(delta):
	
	if current_ship_instance.hull != null:
		if get_node("Camera2D").get_zoom() != scale:
			get_node("Camera2D").set_zoom(scale)