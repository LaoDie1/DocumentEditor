#============================================================
#    Main
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-27 22:43:53
# - version: 4.3.0.dev5
#============================================================
extends Control


@onready var open_file_dialog: FileDialog = %OpenFileDialog
@onready var save_file_dialog: FileDialog = %SaveFileDialog
@onready var directory_dialog: FileDialog = %DirectoryDialog
@onready var left_split_container: HSplitContainer = %LeftSplitContainer
@onready var middle_split_container: HSplitContainer = %MiddleSplitContainer
@onready var current_file_label: Label = %CurrentFileLabel
@onready var font_size_spin_box: SpinBox = %FontSizeSpinBox
@onready var config_dialog: AcceptDialog = %ConfigDialog

@onready var menu: SimpleMenu = %SimpleMenu
@onready var file_tree: SimpleFileTree = %FileTree
@onready var text_edit: TextEdit = %TextEdit
@onready var multi_split_container: MultiSplitContainer = %MultiSplitContainer
@onready var scan_directory_tree: ScanDirectoryTree = %ScanDirectoryTree
@onready var tag_container: TagContainer = %TagContainer
@onready var config_tree: ConfigTree = %ConfigTree
@onready var highlight_text_line_edit: LineEdit = %HighlightTextLineEdit


var origin_text : String

## 当前打开的文件路径
var current_path : String:
	set(v):
		if current_path != v:
			
			# 上一个
			var previous = current_path
			current_path = v
			
			Config.set_tag(previous, tag_container.get_current_tags())
			tag_container.clear_tags()
			
			current_file_label.text = current_path
			origin_text = ( "" if current_path == "" else FileUtil.read_as_string(current_path) )
			text_edit.text = origin_text
			if current_path:
				var tags = Config.get_tags(current_path)
				if not tags.is_empty():
					tag_container.show_current_tags( tags )


#============================================================
#  内置
#============================================================
func _ready() -> void:
	menu.init_menu({
		"文件": ["新建", "打开", "保存", "另存为", "-", "添加目录文件到树", "扫描文件", "设置"],
		"编辑": ["新的编辑列"],
	})
	menu.init_icon({
		"/文件/新建": Icons.get_icon("File"),
		"/文件/打开": Icons.get_icon("Load"),
		"/文件/保存": Icons.get_icon("Save"),
		"/文件/设置": Icons.get_icon("GDScript"),
		"/文件/添加目录文件到树": Icons.get_icon("Override"),
	})
	menu.init_shortcut({
		"/文件/新建": SimpleMenu.parse_shortcut("Ctrl+N"),
		"/文件/打开": SimpleMenu.parse_shortcut("Ctrl+O"),
		"/文件/保存": SimpleMenu.parse_shortcut("Ctrl+S"),
		"/文件/另存为": SimpleMenu.parse_shortcut("Ctrl+shift+S"),
		"/文件/设置": SimpleMenu.parse_shortcut("Ctrl+P"),
		"/编辑/新的编辑列": SimpleMenu.parse_shortcut("Ctrl+Insert"),
	})
	
	Engine.get_main_loop().root.files_dropped.connect(file_tree.add_files)
	if Config.left_split_width > 0:
		left_split_container.split_offset = Config.left_split_width
	if Config.middle_split_width > 0:
		middle_split_container.split_offset = Config.middle_split_width
	FuncUtil.execute_deferred(
		func():
			for data in Config.multi_split_data_list:
				var item = multi_split_container.create_item()
				item.set_data(data)
	)
	font_size_spin_box.value = Config.font_size
	
	if Config.window_size != Vector2.ZERO:
		Engine.get_main_loop().root.size = Config.window_size
		Engine.get_main_loop().root.position = Config.window_position
		Engine.get_main_loop().root.mode = Config.window_mode
	
	Engine.get_main_loop().root.size_changed.connect(
		func():
			if Engine.get_main_loop().root.mode == Window.MODE_WINDOWED:
				Config.window_size = Engine.get_main_loop().root.size
				Config.window_position = Engine.get_main_loop().root.position
			Config.window_mode = Engine.get_main_loop().root.mode
	)
	
	
	# 上次文件
	file_tree.add_files( Config.files )
	if FileAccess.file_exists(current_path):
		open_file(current_path)
	open_file_dialog.current_dir = Config.open_dir
	save_file_dialog.current_dir = Config.saved_dir
	config_tree.set_data(Config.data_file.get_data())
	
	if Config.highlight_text:
		highlight_text_line_edit.text = Config.highlight_text
		_on_highlight_text_line_edit_text_submitted(highlight_text_line_edit.text)
	
	tag_container.set_data(Config.tag_data)


func _exit_tree() -> void:
	Config.files = file_tree.get_files()
	Config.left_split_width = left_split_container.split_offset
	Config.middle_split_width = middle_split_container.split_offset
	Config.set_tag(current_path, tag_container.get_current_tags())
	Config.open_dir = open_file_dialog.current_dir
	Config.saved_dir = save_file_dialog.current_dir
	Config.highlight_text = highlight_text_line_edit.text
	Config.tag_data = tag_container.get_data()
	
	# 多列文本数据
	var item_data_list : Array = []
	for item in multi_split_container.get_items():
		item_data_list.append(item.get_data())
	Config.multi_split_data_list = item_data_list



#============================================================
#  自定义
#============================================================
func open_file(path: String, add_to_tree: bool = true) -> void:
	current_path = path
	if add_to_tree:
		file_tree.add_file(path)
	file_tree.select_file(path)


func save_file(path: String) -> void:
	current_path = path
	current_file_label.text = path
	file_tree.add_file(path)
	FileUtil.write_as_string(path, text_edit.text)


## 扫描添加目录下的所有文件
func scan_directory(dir: String) -> void:
	var include_file_type = ["txt", "md", "json"]
	var files = FileUtil.scan_file(dir, true).filter(
		func(file: String):
			return file.get_extension() in include_file_type
	)
	file_tree.add_files(files)



#============================================================
#  连接信号
#============================================================
func _on_file_tree_item_activated() -> void:
	if Config.double_show_text:
		open_file(file_tree.get_selected_file(), false)

func _on_file_tree_item_selected() -> void:
	if not Config.double_show_text:
		open_file(file_tree.get_selected_file(), false)

func _on_font_size_spin_box_value_changed(value: float) -> void:
	text_edit.add_theme_font_size_override("font_size", value)
	Config.font_size = value
	for item in multi_split_container.get_items():
		item.update_font_size(value)


func _on_simple_menu_menu_pressed(idx: int, menu_path: StringName) -> void:
	match menu_path:
		"/文件/新建":
			current_path = ""
			text_edit.text = ""
			file_tree.deselect_all()
		
		"/文件/打开":
			open_file_dialog.popup_centered()
			
		"/文件/保存":
			if current_path == "":
				save_file_dialog.popup_centered()
			else:
				save_file(current_path)
			
		"/文件/另存为":
			save_file_dialog.popup_centered()
			
		"/文件/添加目录文件到树":
			directory_dialog.set_meta("callback", scan_directory)
			directory_dialog.popup_centered()
			
		"/文件/扫描文件":
			directory_dialog.current_dir = Config.scan_dir
			directory_dialog.set_meta("callback", scan_directory_tree.scan_dir)
			directory_dialog.popup_centered()
		
		"/文件/设置":
			config_dialog.popup_centered()
		
		"/编辑/新的编辑列":
			multi_split_container.create_item()
	


func _on_scan_directory_tree_item_selected() -> void:
	var file = scan_directory_tree.get_select_file()
	if file:
		open_file(file, false)

func _on_directory_dialog_dir_selected(dir: String) -> void:
	var callback = directory_dialog.get_meta("callback")
	callback.call(dir)

func _on_highlight_text_line_edit_text_submitted(new_text: String) -> void:
	text_edit.set_search_text(new_text)
	text_edit.queue_redraw()
