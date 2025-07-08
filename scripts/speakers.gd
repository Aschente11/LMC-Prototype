# Speaker.gd
extends Node3D

@onready var pickable: XRToolsPickable = $XRToolsPickable
@onready var audio_player: AudioStreamPlayer3D = $XRToolsPickable/AudioStreamPlayer3D

var is_playing: bool = false

func _ready():
	# Connect to the pickable's action signals
	pickable.action_pressed.connect(_on_action_pressed)
	
	# Optional: Connect to pickup/drop signals for additional functionality
	pickable.picked_up.connect(_on_picked_up)
	pickable.dropped.connect(_on_dropped)

func _on_action_pressed(pickable_object):
	# This is called when the action button (B/Y) is pressed while holding the speaker
	toggle_music()

func _on_picked_up(pickable_object):
	print("Speaker picked up!")
	# Optional: You could show some UI or highlight the speaker

func _on_dropped(pickable_object):
	print("Speaker dropped!")
	# Optional: Pause music when dropped or keep it playing - your choice
	# pause_music()

func toggle_music():
	if is_playing:
		pause_music()
	else:
		resume_or_play_music()

func resume_or_play_music():
	if audio_player.stream_paused:
		# Resume from paused position
		audio_player.stream_paused = false
		is_playing = true
		print("Music resumed from paused position")
	elif not audio_player.playing:
		# Start playing from beginning
		audio_player.play()
		is_playing = true
		print("Music started playing")
	else:
		# Already playing, set our state correctly
		is_playing = true

func pause_music():
	if audio_player.playing and not audio_player.stream_paused:
		var current_time = audio_player.get_playback_position()
		audio_player.stream_paused = true
		is_playing = false
		print("Music paused at: ", current_time, " seconds")
