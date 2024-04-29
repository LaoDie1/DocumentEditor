#============================================================
#    Config Tree
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-28 20:45:31
# - version: 4.3.0.dev5
#============================================================
class_name ConfigTree
extends Tree


var root : TreeItem


func _init() -> void:
	column_titles_visible = true
	hide_folding = true
	hide_root = true
	columns = 2
	set_column_title(0, "属性")
	set_column_title(1, "值")
	set_column_expand_ratio(0, 0.1)


func set_data(data: Dictionary, layer: int = 0):
	clear()
	root = create_item()
	for key in data:
		set_items_by_data(key, data[key], root, layer)


func set_items_by_data(key, value, parent: TreeItem, layer: int):
	if value is Dictionary and layer > 0:
		var item = create_item(parent)
		item.set_selectable(0, false)
		item.set_custom_bg_color(0, Color.BLACK)
		item.set_custom_bg_color(1, Color.BLACK)
		for k in value:
			item.set_text(0, key)
			set_items_by_data(k, value[k], item, layer - 1)
	else:
		var item = create_item(parent)
		item.set_text(0, key)
		item.set_text(1, var_to_str(value))
		#item.set_editable(1, true)
		item.set_text_overrun_behavior(1, TextServer.OVERRUN_TRIM_ELLIPSIS)

