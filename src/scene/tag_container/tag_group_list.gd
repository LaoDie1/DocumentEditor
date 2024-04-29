#============================================================
#    Tag Group List
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-29 10:30:14
# - version: 4.3.0.dev5
#============================================================
class_name TagGroupList
extends MarginContainer


signal active_tag(tag_text: String)


const TAG_ITEM = preload("tag_item.tscn")


@onready var groups: HFlowContainer = %Groups
@onready var line_edit: LineEdit = %LineEdit
@onready var delete_group_button: Button = %DeleteGroupButton
@onready var delete_confirm_timer: Timer = %DeleteConfirmTimer
@onready var group_name_line_edit: LineEdit = %GroupNameLineEdit


var list : Array = []


#============================================================
#  内置
#============================================================
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is Dictionary:
		var type = data.get("type")
		return typeof(type) == TYPE_STRING and type == "tag"
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	add_tag(data["text"])
	data["source"].queue_free()


#============================================================
#  自定义
#============================================================
func get_group_name() -> String:
	return group_name_line_edit.text

func get_tags() -> Array:
	return groups.get_children().map(
		func(item): return item.text
	)

func set_group_name(group_name: String):
	if not is_inside_tree():
		await ready
	group_name_line_edit.text = group_name

func earse_tag(tag: String):
	list.erase(tag)

func add_tag(text: String):
	if text and not list.has(text):
		list.append(text)
		var tag_item : TagItem = TAG_ITEM.instantiate() as TagItem
		tag_item.close_confirm = true
		tag_item.gui_input.connect(_on_tag_gui_input.bind(tag_item))
		tag_item.tree_exited.connect(earse_tag.bind(text))
		groups.add_child(tag_item)
		tag_item.text = text
		line_edit.clear()

func add_tags(list: Array):
	for tag in list:
		add_tag(tag)

## 隐藏删除组按钮
func hide_delete_group_button():
	delete_group_button.hide()


#============================================================
#  连接信号
#============================================================
func _on_tag_gui_input(event, item: TagItem):
	if event is InputEventMouseButton:
		if (
			event.pressed 
			and event.double_click
			and event.button_index == MOUSE_BUTTON_LEFT
		):
			active_tag.emit(item.text)


func _on_delete_group_button_pressed() -> void:
	if delete_group_button.text == "":
		delete_group_button.text = "确认删除"
		delete_confirm_timer.start()
	else:
		self.queue_free()


func _on_delete_confirm_timer_timeout() -> void:
	delete_group_button.text = ""
