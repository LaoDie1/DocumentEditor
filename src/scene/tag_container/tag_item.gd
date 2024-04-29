#============================================================
#    Tag Item
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-28 19:11:37
# - version: 4.3.0.dev5
#============================================================
class_name TagItem
extends MarginContainer


## 标签文字
@export var text: String:
	set(v): label.text = v
	get:    return label.text
## 删除关闭（点击关闭按钮时要经过再次确认才能删除）
@export var close_confirm : bool = false


@onready var label: Label = %Label
@onready var close_confirm_timer: Timer = %CloseConfirmTimer
@onready var close_button: Button = %CloseButton


#============================================================
#  内置
#============================================================
func _ready() -> void:
	label.text = text

func _get_drag_data(at_position: Vector2) -> Variant:
	var drag_label = Label.new()
	drag_label.text = text
	drag_label.add_theme_font_size_override("font_size", 24)
	set_drag_preview(drag_label)
	return {
		"type": "tag",
		"text": text,
		"source": self,
	}


#============================================================
#  连接信号
#============================================================
func _on_close_button_pressed() -> void:
	if close_confirm and close_button.text == "":
		close_button.text = "(确定)"
		close_button.icon = null
		close_confirm_timer.start()
	else:
		self.queue_free()


func _on_delete_confirm_timer_timeout() -> void:
	close_button.text = ""
	close_button.icon = Icons.get_icon("Close")
