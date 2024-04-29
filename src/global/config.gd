#============================================================
#    Config
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-22 11:53:36
# - version: 4.3.0.dev5
#============================================================
## 配置
extends Node


const SCAN_FILES_SUFFIX = ["txt", "md"]


#============================================================
#  项目数据
#============================================================
var double_show_text : bool = false ## 双击显示内容
var font_size: int = 16 ## 字体大小
var multi_split_data_list : Array ## 多列文本
var left_split_width: float = 0 ## 左分隔宽度
var middle_split_width: float = 0 ## 中间分隔宽度
var highlight_text : String ## 高亮文字
var tag_data : Dictionary ## 标签数据
var window_mode : int = Window.MODE_WINDOWED
var window_size: Vector2
var window_position: Vector2


var files: Array ## 打开过的文件列表
var file_tag_dict : Dictionary: ## 文件标签
	set(v):
		file_tag_dict = v
		for key in file_tag_dict.keys():
			if file_tag_dict[key].is_empty():
				file_tag_dict.erase(key)
var scan_dir: String  ## 上次扫描的目录
var open_dir : String  ## 上次打开过的目录
var saved_dir : String  ## 上次保存到的目录


#============================================================
#  自定义
#============================================================
func set_tag(path: String, tags: Dictionary):
	if path:
		if tags.is_empty():
			file_tag_dict.erase(path.get_file())
		else:
			file_tag_dict[path.get_file()] = tags.duplicate()

func get_tags(path: String) -> Dictionary:
	return file_tag_dict.get(path.get_file(), {})



#============================================================
#  配置
#============================================================
var data_file : DataFile = DataFile.instance(OS.get_config_dir().path_join("Godot/DocumentEditor/.config.data"))
## 排除设置的配置属性
var exclude_config_propertys : Array[String] = [
	"exclude_config_propertys", "data_file"
]

func _init():
	# 加载配置数据
	data_file.update_object_property(self, exclude_config_propertys)
	JsonUtil.print_stringify(data_file.get_data())

func _exit_tree() -> void:
	# 保存当前节点上的配置数据
	data_file.get_data().clear()
	data_file.set_value_by_object(self, exclude_config_propertys)
	data_file.save()

