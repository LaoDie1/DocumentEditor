#============================================================
#    Expand Button
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-28 17:14:35
# - version: 4.3.0.dev5
#============================================================
extends Button


@export var value : Vector2 = Vector2()
@export var time : float = 0.05


func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		create_tween().tween_property(get_parent(), "position", value, time)
	else:
		create_tween().tween_property(get_parent(), "position", Vector2(), time)

