extends Control

func _ready() -> void:
	# initialize the music and discord rpc status
	MusicPlayer.play_music("title")
	Fade.fade_in()
	Globals.can_exit = true

func _on_exit_button_pressed() -> void:
	Globals.exit_game()

func _on_set_button_pressed() -> void:
	$TitleUI/TitleMenu.visible = false
	$TitleUI/SettingsMenu.visible = true
	$TitleUI/SettingsMenu/BuildLabel.text = ProjectSettings.get_setting("application/config/version")

func _on_set_back_button_pressed() -> void:
	$TitleUI/SettingsMenu.visible = false
	$TitleUI/TitleMenu.visible = true

func _on_set_vid_back_button_pressed() -> void:
	$TitleUI/SettingsVideoMenu.visible = false
	$TitleUI/SettingsMenu.visible = true


func _on_vid_button_pressed() -> void:
	$TitleUI/SettingsMenu.visible = false
	$TitleUI/SettingsVideoMenu.visible = true
	$TitleUI/SettingsVideoMenu/SetVidOptions/SetVidDispButton.selected = Globals.current_settings["video"]["display"]
	$TitleUI/SettingsVideoMenu/SetVidOptions/SetVidResButton.clear()
	if $TitleUI/SettingsVideoMenu/SetVidOptions/FpsSlider.value < 1:
		$TitleUI/SettingsVideoMenu/SetVidOptions/FpsLabel.text = tr("set_video_fpslimit") % [tr("set_video_fpslimit_nolimit")]
	else:
		$TitleUI/SettingsVideoMenu/SetVidOptions/FpsLabel.text = tr("set_video_fpslimit") % [str(int($TitleUI/SettingsVideoMenu/SetVidOptions/FpsSlider.value * 10))]
	if Globals.current_settings["video"]["display"] == 0:
		$TitleUI/SettingsVideoMenu/SetVidOptions/SetVidResButton.disabled = false
		for i in Globals.RESOLUTIONS:
			$TitleUI/SettingsVideoMenu/SetVidOptions/SetVidResButton.add_item(i)
		$TitleUI/SettingsVideoMenu/SetVidOptions/SetVidResButton.selected = Globals.current_settings["video"]["resolution"]
	else:
		$TitleUI/SettingsVideoMenu/SetVidOptions/SetVidResButton.disabled = true
	$TitleUI/SettingsVideoMenu/SetVidOptions/VsyncButton.button_pressed = Globals.current_settings["video"]["vsync"]
	$TitleUI/SettingsVideoMenu/SetVidOptions/FpsButton.button_pressed = Globals.current_settings["video"]["show_fps"]
	if RenderingServer.get_video_adapter_name() != "":
		$TitleUI/SettingsVideoMenu/GpuLabel.text = tr("set_video_gpu") % [RenderingServer.get_video_adapter_name()]
	else:
		$TitleUI/SettingsVideoMenu/GpuLabel.text = tr("set_video_gpu") % [tr("set_video_gpu_noid")]

func _on_set_vid_apply_button_pressed() -> void:
	if !$TitleUI/SettingsVideoMenu/SetVidOptions/SetVidResButton.disabled:
		Globals.current_settings["video"]["resolution"] = $TitleUI/SettingsVideoMenu/SetVidOptions/SetVidResButton.selected
	Globals.current_settings["video"]["vsync"] = $TitleUI/SettingsVideoMenu/SetVidOptions/VsyncButton.button_pressed
	Globals.current_settings["video"]["fps_limit"] = $TitleUI/SettingsVideoMenu/SetVidOptions/FpsSlider.value
	Globals.current_settings["video"]["show_fps"] = $TitleUI/SettingsVideoMenu/SetVidOptions/FpsButton.button_pressed
	Globals.current_settings["video"]["display"] = $TitleUI/SettingsVideoMenu/SetVidOptions/SetVidDispButton.selected
	$TitleUI/SettingsVideoMenu.visible = false
	$TitleUI/SettingsMenu.visible = true
	Globals.apply_settings()
	Globals.save_settings()
	if Globals.current_settings["video"]["display"] in [0, 1]:
		Globals.center_window()

func _on_aud_button_pressed() -> void:
	$TitleUI/SettingsMenu.visible = false
	$TitleUI/SettingsAudioMenu.visible = true
	$TitleUI/SettingsAudioMenu/SetAudOptions/VolSlider.value = Globals.current_settings["audio"]["master_volume"] * 100
	$TitleUI/SettingsAudioMenu/SetAudOptions/BgmVolSlider.value = Globals.current_settings["audio"]["bgm_volume"] * 100
	$TitleUI/SettingsAudioMenu/SetAudOptions/SfxVolSlider.value = Globals.current_settings["audio"]["sfx_volume"] * 100
	$TitleUI/SettingsAudioMenu/SetAudOptions/VolLabel.text = tr("set_audio_volume") % [Globals.current_settings["audio"]["master_volume"] * 100]
	$TitleUI/SettingsAudioMenu/SetAudOptions/BgmVolLabel.text = tr("set_audio_bgm_volume") % [Globals.current_settings["audio"]["bgm_volume"] * 100]
	$TitleUI/SettingsAudioMenu/SetAudOptions/SfxVolLabel.text = tr("set_audio_sfx_volume") % [Globals.current_settings["audio"]["sfx_volume"] * 100]

func _on_set_aud_back_button_pressed() -> void:
	$TitleUI/SettingsAudioMenu.visible = false
	$TitleUI/SettingsMenu.visible = true

func _on_vol_slider_drag_ended(value_changed: bool) -> void:
	# change master volume
	if value_changed:
		Globals.current_settings["audio"]["master_volume"] = $TitleUI/SettingsAudioMenu/SetAudOptions/VolSlider.value / 100.0
		Globals.apply_settings()
		$TitleUI/SettingsAudioMenu/SetAudOptions/VolLabel.text = tr("set_audio_volume") % [Globals.current_settings["audio"]["master_volume"] * 100]
		Globals.save_settings()

func _on_bgm_vol_slider_drag_ended(value_changed: bool) -> void:
	# change music volume
	if value_changed:
		Globals.current_settings["audio"]["bgm_volume"] = $TitleUI/SettingsAudioMenu/SetAudOptions/BgmVolSlider.value / 100.0
		Globals.apply_settings()
		$TitleUI/SettingsAudioMenu/SetAudOptions/BgmVolLabel.text = tr("set_audio_bgm_volume") % [Globals.current_settings["audio"]["bgm_volume"] * 100]
		Globals.save_settings()

func _on_sfx_vol_slider_drag_ended(value_changed: bool) -> void:
	# change sfx volume
	if value_changed:
		Globals.current_settings["audio"]["sfx_volume"] = $TitleUI/SettingsAudioMenu/SetAudOptions/SfxVolSlider.value / 100.0
		Globals.apply_settings()
		$TitleUI/SettingsAudioMenu/SetAudOptions/SfxVolLabel.text = tr("set_audio_sfx_volume") % [Globals.current_settings["audio"]["sfx_volume"] * 100]
		Globals.save_settings()
	SfxPlayer.test_sound()

func _on_set_gen_back_button_pressed() -> void:
	$TitleUI/SettingsGeneralMenu.visible = false
	$TitleUI/SettingsMenu.visible = true

func _on_gen_button_pressed() -> void:
	$TitleUI/SettingsMenu.visible = false
	$TitleUI/SettingsGeneralMenu.visible = true
	$TitleUI/SettingsGeneralMenu/SetGenOptions/LangButton.clear()
	for i in Globals.LANGUAGES:
		$TitleUI/SettingsGeneralMenu/SetGenOptions/LangButton.add_item("%s (%s)" % [tr("lang_"+i), Globals.LANGUAGES_FULL[Globals.LANGUAGES.find(i)]])
	$TitleUI/SettingsGeneralMenu/SetGenOptions/LangButton.selected = Globals.current_settings["general"]["language"]

func _on_game_dir_button_pressed() -> void:
	OS.shell_show_in_file_manager(Globals.datapath)

func _on_lang_button_item_selected(index: int) -> void:
	Globals.current_settings["general"]["language"] = index
	Globals.apply_settings()
	$TitleUI/SettingsGeneralMenu/SetGenOptions/LangButton.clear()
	for i in Globals.LANGUAGES:
		$TitleUI/SettingsGeneralMenu/SetGenOptions/LangButton.add_item("%s (%s)" % [tr("lang_"+i), Globals.LANGUAGES_FULL[Globals.LANGUAGES.find(i)]])
	$TitleUI/SettingsGeneralMenu/SetGenOptions/LangButton.selected = Globals.current_settings["general"]["language"]
	Globals.save_settings()

func _on_discord_button_toggled(toggled_on: bool) -> void:
	Globals.current_settings["general"]["discord_rpc"] = toggled_on
	Globals.apply_settings()
	Globals.discord_status("Title screen")
	Globals.save_settings()

func _on_fps_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		if $TitleUI/SettingsVideoMenu/SetVidOptions/FpsSlider.value < 1:
			$TitleUI/SettingsVideoMenu/SetVidOptions/FpsLabel.text = tr("set_video_fpslimit") % [tr("set_video_fpslimit_nolimit")]
		else:
			$TitleUI/SettingsVideoMenu/SetVidOptions/FpsLabel.text = tr("set_video_fpslimit") % [str(int($TitleUI/SettingsVideoMenu/SetVidOptions/FpsSlider.value * 10))]


func _on_set_inp_back_button_pressed() -> void:
	$TitleUI/SettingsInputMenu.visible = false
	$TitleUI/SettingsMenu.visible = true


func _on_inp_button_pressed() -> void:
	$TitleUI/SettingsMenu.visible = false
	$TitleUI/SettingsInputMenu.visible = true
	$TitleUI/SettingsInputMenu/SetInpOptions/RumbButton.selected = Globals.current_settings["input"]["rumble"]


func _on_rumb_button_item_selected(index: int) -> void:
	Globals.current_settings["input"]["rumble"] = index
	Globals.apply_settings()
	Globals.save_settings()


func _on_feed_button_pressed() -> void:
	OS.shell_open("https://docs.google.com/forms/d/e/1FAIpQLSfTzPiaOzqyHTfrtsuuuVle08zlEVb0v1vwC6KB1LbQ0bfUhw/viewform?usp=publish-editor")

# unused
# func _on_title_bgm_button_toggled(toggled_on: bool) -> void:
	# Globals.current_settings["audio"]["title_bgm"] = toggled_on
	# Globals.apply_settings()
	# Globals.save_settings()


func _on_erase_no_button_pressed() -> void:
	$TitleUI/SettingsGeneralMenu/EraseConfirm.visible = false


func _on_erase_yes_button_pressed() -> void:
	$TitleUI/SettingsGeneralMenu/EraseConfirm.visible = false
	Globals.initialize_settings()
	Globals.save_settings()
	$TitleUI/SettingsGeneralMenu.visible = false
	$TitleUI/TitleMenu.visible = true
	$TitleUI/TitleMenu/EraseSuccess.visible = true


func _on_erase_set_button_pressed() -> void:
	$TitleUI/SettingsGeneralMenu/EraseConfirm.visible = true


func _on_erase_success_ok_button_pressed() -> void:
	$TitleUI/TitleMenu/EraseSuccess.visible = false
