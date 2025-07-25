extends Node

var music: AudioStreamPlayer = null
var paused_pos: float = 0.0


func play_sound(sound_name: String) -> AudioStreamPlayer:
	var new_player: AudioStreamPlayer = AudioStreamPlayer.new()
	new_player.stream = Imports.SFX[sound_name]
	new_player.finished.connect(_cleanup_player.bind(new_player))
	add_child(new_player)

	new_player.play()

	return new_player


func play_random_sound(sound_names: Array[String]) -> AudioStreamPlayer:
	if sound_names.size() == 0:
		return null

	var sfx: String = sound_names[randi() % sound_names.size()]
	return play_sound(sfx)


func play_random_indexed_sound(sound_name: String) -> AudioStreamPlayer:
	var sound_effects: Array[String] = []
	for sound_effect: String in Imports.SFX:
		if not sound_effect.begins_with(sound_name):
			continue
		sound_effects.append(sound_effect)

	if sound_effects.size() == 0:
		return null

	var sfx: String = sound_effects[randi() % sound_effects.size()]
	return play_sound(sfx)


func stop_all_sounds() -> void:
	for player: AudioStreamPlayer in get_children():
		player.stop()
		player.stream = null


func _cleanup_player(player: AudioStreamPlayer) -> void:
	player.queue_free()


func play_music(music_name: String) -> AudioStreamPlayer:
	if music and music.stream == Imports.MUSIC[music_name]:
		return music

	if music:
		music.stop()
		music.queue_free()

	var new_player: AudioStreamPlayer = AudioStreamPlayer.new()
	new_player.stream = Imports.MUSIC[music_name]
	new_player.bus = "Music"
	new_player.volume_db = -5.0
	new_player.autoplay = true

	add_child(new_player)
	music = new_player

	return new_player


func pause_music() -> void:
	if music:
		music.stream_paused = true


func resume_music() -> void:
	if music:
		music.stream_paused = false
