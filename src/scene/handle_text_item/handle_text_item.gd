#============================================================
#    Handle Text Item
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-28 00:58:22
# - version: 4.3.0.dev5
#============================================================
class_name HandleTextItem
extends Control


@onready var title_edit: LineEdit = %TitleEdit
@onready var text_edit: TextEdit = %TextEdit

# 处理拖拽
var status : bool = false
var last_size : Vector2
var last_pos : Vector2


#============================================================
#  内置
#============================================================
func _ready() -> void:
	update_font_size(Config.font_size)


func update_font_size(font_size: float):
	title_edit.add_theme_font_size_override("font_size", font_size)
	text_edit.add_theme_font_size_override("font_size", font_size)


#============================================================
#  自定义
#============================================================
func get_data():
	return {
		"title": title_edit.text,
		"text": text_edit.text,
		"size": size,
	}

func set_data(data: Dictionary):
	if data.has("size"):
		self.size.x = data["size"].x
	if not is_inside_tree():
		await ready
	title_edit.text = data.get("title", "")
	text_edit.text = data.get("text", "")


#============================================================
#  连接信号
#============================================================
# 右侧拖拽修改大小
func _on_control_gui_input(event: InputEvent) -> void:
	if status and InputUtil.is_motion(event):
		var diff = get_local_mouse_position() - last_pos
		size.x = last_size.x + diff.x
	
	elif InputUtil.is_click_left(event, true):
		last_pos = get_local_mouse_position()
		last_size = size
		status = true
	
	elif InputUtil.is_click_left(event, false):
		status = false
