extends Node
var can_exit: bool = false
# decide what os the player is running
static var iswin = OS.has_feature("windows")
static var ismac = OS.has_feature("macos")
static var islin = OS.has_feature("linux") or OS.has_feature("bsd")


# define languages for indexing purposes
const LANGUAGES = ["sys", "en", "pl"]
const LANGUAGES_FULL = ["System", "English", "Polski"]
const RESOLUTIONS = ["854x480", "1280x720", "1920x1080"]
const KEYBIND_ACTIONS = [
	"menu_left",
	"menu_right",
	"menu_up",
	"menu_down",
	"menu_accept",
	"menu_back",
	"game_pause",
	"game_jump",
	"game_action",
	"game_alt_action",
	"game_run",
	"game_crouch",
	"game_left",
	"game_right",
	"game_up",
	"game_down",
    "game_lands"
]

func _notification(what: int) -> void:
	# Check if the notification is a window close/quit request
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		exit_game()
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if get_tree().current_scene.name == "TitleScreen":
			exit_game()

const DEFAULT_SETTINGS = {
	# template for a new settings file
	"general": {
		"language": 0, # 0 - system, 1 - english, 2 - polish, 3 - german (future), 4 - spanish (future), 5 - french (future)
	},
	"video": {
		"display": 0,  # 0 - windowed, 1 - borderless, 2 - fullscreen
		"vsync": true,
		"fps_limit": 0.0, # will be internally multiplied by 10, 0.0 - unlimited
		"resolution": 1,  # 0 - 854x480, 1 - 1280x720, 2 - 1920x1080, 3 - 3840x2160
		"show_fps": false,
	},
	"audio": {
		"master_volume": 1.0,
		"sfx_volume": 1.0,
		"bgm_volume": 1.0,
		# "title_bgm": true
	},
	"input": {
		"rumble": 2,  # 0 - none, 1 - weak, 2 - medium, 3 - strong
	},
	"accessibility": {
		"shake_intensity": 1.0,
		"flash_reduction": false,
		"motion_reduction": false,
		"extra_cutscenes": true
	}
}

const SETTINGS_ALLOWED = {
	# allowed values for settings, for validation purposes; if an array has exactly two floats, it will be treated as a range
	"general": {
		"language": [0, 1],
	},
	"video": {
		"display": [0, 1, 2],
		"vsync": [true, false],
		"fps_limit": [0.0, 30.0], # game will multiply by 10
		"resolution": [0, 1, 2, 3],
		"show_fps": [true, false]
	},
	"audio": {
		"master_volume": [0.0, 1.0],
		"sfx_volume": [0.0, 1.0],
		"bgm_volume": [0.0, 1.0],
		# "title_bgm": [true, false]
	},
	"input": {
		"rumble": [0, 1, 2, 3],
	},
	"accessibility": {
		"shake_intensity": [0.0, 2.0],
		"flash_reduction": [true, false],
		"motion_reduction": [true, false],
		"extra_cutscenes": [true, false]
	}
}

# initialize data path and sources of truth
var datapath = "" # path for game data directory
var current_settings = {} # settings loaded into memory
var current_save_data = {} # save data loaded into memory

func load_dirs() -> void:
	print("[INFO] Loading directories...")
	var basepath: String = ""
	if iswin:
		basepath = OS.get_environment("APPDATA").path_join("odsoft")
	elif ismac:
		basepath = OS.get_environment("HOME").path_join("Library").path_join("Application Support").path_join("odsoft")
	elif islin:
		basepath = OS.get_environment("XDG_CONFIG_HOME").path_join("odsoft")
		if OS.get_environment("XDG_CONFIG_HOME") == "":
			var home = OS.get_environment("HOME")
			if home != "":
				basepath = home.path_join(".config").path_join("odsoft")
	else:
		basepath = OS.get_user_data_dir()
	datapath = basepath.path_join("ASV")
	if not DirAccess.dir_exists_absolute(datapath):
		DirAccess.make_dir_recursive_absolute(datapath)
	if not DirAccess.dir_exists_absolute(datapath.path_join("saves")):
		DirAccess.make_dir_absolute(datapath.path_join("saves"))

func exit_game() -> void:
	if can_exit:
		can_exit = false
		print("[INFO] Stopping BGM and SFX...")
		MusicPlayer.stop()
		SfxPlayer.stop()
		print("[INFO] Flushing settings from memory to disk immediately...")
		save_settings()
		print("[INFO] Exiting...")
		await Fade.fade_out()
		print("Exiting with exit code 0.")
		get_tree().quit(0)

func apply_settings() -> void:
	print("[INFO] Applying settings...")
	var video = current_settings["video"]
	var resolution: Vector2i
	match int(video["resolution"]):
		0: resolution = Vector2i(854, 480)
		1: resolution = Vector2i(1280, 720)
		2: resolution = Vector2i(1920, 1080)
		3: resolution = Vector2i(3840, 2160)
	match int(video["display"]):
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_size(resolution)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_size(DisplayServer.screen_get_size())
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_size(DisplayServer.screen_get_size())
	
	var vsync_val = DisplayServer.VSYNC_ENABLED if video["vsync"] else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(vsync_val)
	Engine.max_fps = int(video["fps_limit"] * 10)
	FpsOverlay.visible = video["show_fps"]
	# general settings
	var general = current_settings["general"]
	if general["language"] == 0:
		TranslationServer.set_locale(OS.get_locale())
	else:
		TranslationServer.set_locale(LANGUAGES[general["language"]])

func initialize_settings() -> void:
	print("[INFO] Initializing settings...")
	current_settings = DEFAULT_SETTINGS.duplicate(true)
	apply_settings()
	if current_settings["video"]["display"] != 2:
		center_window()

func center_window() -> void:
	var screen_id = DisplayServer.window_get_current_screen()
	var screen_size = DisplayServer.screen_get_size(screen_id)
	var window_size = DisplayServer.window_get_size()
	DisplayServer.window_set_position(Vector2i(0,0))
	var center_pos = (screen_size / 2.0) - (window_size / 2.0)
	DisplayServer.window_set_position(center_pos)

func save_settings() -> void:
	var config = ConfigFile.new()
	for section in current_settings.keys():
		var section_data = current_settings[section]
		if typeof(section_data) == TYPE_DICTIONARY:
			for key in section_data.keys():
				var value = section_data[key]
				if DEFAULT_SETTINGS.has(section) and DEFAULT_SETTINGS[section].has(key):
					var default_val = DEFAULT_SETTINGS[section][key]
					if typeof(default_val) == TYPE_INT and typeof(value) == TYPE_FLOAT:
						value = int(value)
						current_settings[section][key] = value
				config.set_value(section, key, value)
	var file_path = datapath.path_join("settings.ini")
	var error = config.save(file_path)
	if error == OK:
		print("[INFO] Settings saved successfully to: ", datapath.path_join("settings.ini"))
	else:
		print("[ERROR] Save failed:", error)


func load_settings() -> void:
	var file_path = datapath.path_join("settings.ini") 
	var config = ConfigFile.new() 
	var error = config.load(file_path) 
	if error != OK: 
		print("[WARN] Settings file couldn't be read, continuing with defaults.") 
		current_settings = DEFAULT_SETTINGS.duplicate(true) 
		return 
	var loaded_settings = {} 
	for section in DEFAULT_SETTINGS.keys(): 
		loaded_settings[section] = {} 
		var section_data = DEFAULT_SETTINGS[section] 
		if typeof(section_data) == TYPE_DICTIONARY: 
			for key in section_data.keys(): 
				var default_val = section_data[key] 
				var value = config.get_value(section, key, default_val) 
				if typeof(value) != typeof(default_val): 
					print("[WARN] Invalid type for [", section, "] -> ", key, ". Falling back to default value.") 
					value = default_val
				elif not is_value_allowed(section, key, value): 
					print("[WARN] Value ", value, " not allowed for [", section, "] -> ", key, ". Falling back to default value.")
					value = default_val
					
				loaded_settings[section][key] = value 
	current_settings = loaded_settings
	print("[INFO] Settings loaded and validated successfully from: ", datapath.path_join("settings.ini"))

func is_value_allowed(section: String, key: String, value) -> bool:
	if not SETTINGS_ALLOWED.has(section) or not SETTINGS_ALLOWED[section].has(key):
		return true
	var allowed_rule = SETTINGS_ALLOWED[section][key]
	if typeof(value) == TYPE_FLOAT and allowed_rule.size() == 2 and typeof(allowed_rule[0]) == TYPE_FLOAT and typeof(allowed_rule[1]) == TYPE_FLOAT:
		var min_val = allowed_rule[0]
		var max_val = allowed_rule[1]
		return value >= min_val and value <= max_val
	else:
		return value in allowed_rule
