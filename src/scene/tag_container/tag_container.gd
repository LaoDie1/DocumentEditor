#============================================================
#    Control
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-28 16:42:34
# - version: 4.3.0.dev5
#============================================================
class_name TagContainer
extends Control


const TAG_ITEM = preload("tag_item.tscn")
const TAG_GROUP_LIST = preload("tag_group_list.tscn")


@onready var template : ItemList = %Template
@onready var current_tags_container: HFlowContainer = %CurrentTagsContainer
@onready var tag_group_list_container: VBoxContainer = %TagGroupListContainer


var current_tags : Dictionary = {} # 当前显示的标签


#============================================================
#  自定义
#============================================================
func get_data() -> Dictionary:
	var data : Dictionary = {}
	for tag_group_list:TagGroupList in tag_group_list_container.get_children():
		var list : Array = tag_group_list.get_tags()
		var group_name : String = tag_group_list.get_group_name()
		data[group_name] = list
	return data


func set_data(data: Dictionary):
	if data.is_empty():
		add_tag_group([], "")
	else:
		for group_name in data:
			var list = data[group_name]
			add_tag_group(list, group_name)


func add_tag_group(list: Array, group_name: String = ""):
	var tag_group_list : TagGroupList = TAG_GROUP_LIST.instantiate()
	tag_group_list_container.add_child(tag_group_list)
	tag_group_list.add_tags(list)
	tag_group_list.active_tag.connect(add_tag)
	if group_name:
		tag_group_list.set_group_name(group_name)

func get_current_tags():
	return current_tags

func show_current_tags(dict: Dictionary):
	clear_tags()
	for tag in dict:
		add_tag(tag)

func clear_tags():
	current_tags = {}
	for child in current_tags_container.get_children():
		child.queue_free()

func add_tag(tag: String):
	if current_tags.has(tag):
		return
	current_tags[tag] = null
	var label : Control = TAG_ITEM.instantiate()
	current_tags_container.add_child(label)
	label.tree_exited.connect( DataUtil.erase.bind(tag, current_tags) )
	label.text = tag


#============================================================
#  连接信号
#============================================================
func _on_add_group_button_pressed() -> void:
	add_tag_group([])
