class_name SaveManager
extends Mono

static var Instance: SaveManager
var defaultFileName := "drawing"

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance):
		Instance = self
	else:
		U.Destroy(gameObject)

func SavePNG(filename := "") -> String:
	var flat := LayerManager.Instance.Flatten()
	var dt := Time.get_datetime_dict_from_system()
	var stamp := "%04d-%02d-%02d_%02d-%02d-%02d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second]
	var nm := "%s_%s" % [defaultFileName, stamp] if filename.is_empty() else filename
	var dir := OS.get_system_dir(OS.SYSTEM_DIR_PICTURES).path_join("Whispers of the Night")
	var path := dir.path_join(nm + ".png")
	var ok := DirAccess.make_dir_recursive_absolute(dir) == OK and flat.save_png(path) == OK
	if not ok:
		path = ProjectSettings.globalize_path("user://" + nm + ".png")
		flat.save_png(path)
	if ForegroundNotifier.Instance != null:
		ForegroundNotifier.Instance.ShowMessage(Loc.T("Drawing saved to\n%s" % path, "Çizim kaydedildi:\n%s" % path), 4.0)
	return path

func SaveNative(filename := "") -> void:
	var layers: Array = LayerManager.Instance.Layers
	var nm := defaultFileName if filename.is_empty() else filename
	var dir := "user://" + nm
	DirAccess.make_dir_recursive_absolute(dir)
	for i in layers.size():
		layers[i].image.save_png(dir.path_join("layer_%d_%s.png" % [i, layers[i].name]))
	var f := FileAccess.open(dir.path_join("meta.json"), FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify({"layerCount": layers.size()}))

func LoadNative(filename: String) -> void:
	var dir := "user://" + filename
	if not DirAccess.dir_exists_absolute(dir):
		push_warning("Kayıt bulunamadı.")
		return
	var meta = JSON.parse_string(FileAccess.get_file_as_string(dir.path_join("meta.json")))
	if not (meta is Dictionary):
		return
	var lm = LayerManager.Instance
	while lm.Layers.size() > 1:
		lm.RemoveLayer(lm.Layers.size() - 1)
	var files := DirAccess.get_files_at(dir)
	for i in int(meta.get("layerCount", 0)):
		var found := ""
		for fn in files:
			if fn.begins_with("layer_%d_" % i) and fn.ends_with(".png"):
				found = fn
				break
		if found.is_empty():
			continue
		var img := Image.load_from_file(dir.path_join(found))
		if img == null:
			continue
		img.convert(Image.FORMAT_RGBA8)
		var layer = lm.Layers[0] if i == 0 else lm.AddLayer()
		layer.image.blit_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i.ZERO)
		layer.dirty = true
	if DrawingCanvas.Instance != null:
		DrawingCanvas.Instance.RefreshDisplay()
