extends Control

var dialogs = [
"""Good morning! My name is Mr. Monigote. Your job is to spin this wheel to generate electricity for our company!""",
"""Here at Serious Corp we apreciate efficency and seriousness! Don't fool around and don't dissapoint!""",
"""I will leave now to let you work in peace, don't break the equipment and DON'T make a mess out of the office space!"""
]
var dialog_idx = 0
var showing_start_dialog: bool = true
var char_time = 0.0
var CHAR_TIME = 0.05
func _ready() -> void:
	if Global.won:
		dialog_idx = 3
		showing_start_dialog = false
		$Dialog.hide()
		Global.dialog_ended.emit()
	Global.trapped.connect(func(): $GUI.hide())
	Global.explode.connect(func():
		$Explosion.speed_scale = 4.0 if Global.won else 1.0
		$Explosion.play("flash")
		await $Explosion.animation_finished
		Global.won = true
		get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
		)
	Global.set_free.connect(func(): $GUI.show())
	$Dialog/Text.visible_characters = 0

var dialog_delay = 0.0
func _process(delta: float) -> void:
	if dialog_delay > 0.0:
		dialog_delay -= delta
		
		if dialog_delay <= 0.0:
			if dialog_idx >= 3:
				$Dialog.hide()
				Global.dialog_ended.emit()
				return
			$Dialog/Text.visible_characters = 0
			$Dialog/Text.text = dialogs[dialog_idx]
		return
	if showing_start_dialog:
		if char_time <= 0.0:
			if $Dialog/Text.text[$Dialog/Text.visible_characters] != ' ':
				char_time = CHAR_TIME
				$Dialog/Chirp.play()
			$Dialog/Text.visible_characters += 1
		if $Dialog/Text.visible_ratio >= 1.0:
			dialog_idx += 1
			if dialog_idx >= 3:
				showing_start_dialog = false
				dialog_delay = 2.0
				return
			dialog_delay = 1.5
			return
			
		char_time -= delta
	%Boxes/Label.text = "Boxes: " + str(Global.boxes)
	%Melons/Label.text = "Melons: " + str(Global.melon)
