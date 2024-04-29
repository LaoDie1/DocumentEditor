#============================================================
#    Scan Directory Tree
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-28 15:24:27
# - version: 4.3.0.dev5
#============================================================
class_name ScanDirectoryTree
extends Tree


func _ready() -> void:
	if Config.scan_dir:
		await visibility_changed
		scan_dir(Config.scan_dir)


func scan_dir(dir: String):
	Config.scan_dir = dir
	clear()
	var root : TreeItem = create_item()
	if DirAccess.dir_exists_absolute(dir):
		var files = FileUtil.scan_file(dir)
		var item: TreeItem
		for file in files:
			if file.get_extension() in Config.SCAN_FILES_SUFFIX:
				item = create_item(root)
				item.set_text(0, file.get_file())
				item.set_metadata(0, file)
				item.set_icon(0, Icons.get_icon("File"))


func get_select_file() -> String:
	var item = get_selected()
	if item:
		return item.get_metadata(0)
	return ""
