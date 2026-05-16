extends Node

const POOL_SIZE = 5
const FADE_DURATION = 0.5
const SETTINGS_PATH = "user://settings.cfg"

var _bgm_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _pool_index: int = 0

var _music_volume: float = 1.0
var _sfx_volume: float = 1.0

func _ready() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "Music" if AudioServer.get_bus_index("Music") != -1 else "Master"
	add_child(_bgm_player)

	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX" if AudioServer.get_bus_index("SFX") != -1 else "Master"
		add_child(player)
		_sfx_pool.append(player)

	load_settings()

func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	var player := _sfx_pool[_pool_index]
	_pool_index = (_pool_index + 1) % POOL_SIZE
	player.stream = stream
	player.volume_db = volume_db
	player.play()

func play_bgm(stream: AudioStream) -> void:
	if _bgm_player.stream == stream:
		return

	if _bgm_player.playing:
		var tween := create_tween()
		tween.tween_property(_bgm_player, "volume_db", -80.0, FADE_DURATION / 2.0)
		await tween.finished
		_bgm_player.stop()

	_bgm_player.stream = stream
	_bgm_player.volume_db = -80.0
	_bgm_player.play()
	var tween := create_tween()
	tween.tween_property(_bgm_player, "volume_db", linear_to_db(_music_volume), FADE_DURATION / 2.0)

func stop_bgm() -> void:
	if not _bgm_player.playing:
		return
	var tween := create_tween()
	tween.tween_property(_bgm_player, "volume_db", -80.0, FADE_DURATION)
	await tween.finished
	_bgm_player.stop()

func set_music_volume(linear: float) -> void:
	_music_volume = clamp(linear, 0.0, 1.0)
	var db := linear_to_db(_music_volume) if _music_volume > 0.0 else -80.0
	var bus_idx := AudioServer.get_bus_index("Music")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, db)
	elif _bgm_player.playing:
		_bgm_player.volume_db = db

func set_sfx_volume(linear: float) -> void:
	_sfx_volume = clamp(linear, 0.0, 1.0)
	var db := linear_to_db(_sfx_volume) if _sfx_volume > 0.0 else -80.0
	var bus_idx := AudioServer.get_bus_index("SFX")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, db)

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "music_volume", _music_volume)
	config.set_value("audio", "sfx_volume", _sfx_volume)
	config.save(SETTINGS_PATH)

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	var music_vol: float = config.get_value("audio", "music_volume", 1.0)
	var sfx_vol: float = config.get_value("audio", "sfx_volume", 1.0)
	set_music_volume(music_vol)
	set_sfx_volume(sfx_vol)
