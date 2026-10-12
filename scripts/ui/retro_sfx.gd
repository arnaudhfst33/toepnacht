class_name RetroSfx
extends RefCounted

## Tiny generated chip sounds. No external audio files or copyrighted samples.

const MIX_RATE := 22050


static func play(parent: Node, cue: String, volume: float = 1.0) -> void:
	if parent == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = make_stream(cue)
	player.volume_db = linear_to_db(clampf(volume, 0.01, 1.0))
	parent.add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


static func make_stream(cue: String) -> AudioStreamWAV:
	var frequency := 420.0
	var end_frequency := 520.0
	var duration := 0.075
	match cue:
		"knock":
			frequency = 105.0
			end_frequency = 78.0
			duration = 0.14
		"decision":
			frequency = 260.0
			end_frequency = 210.0
			duration = 0.09
		"win":
			frequency = 520.0
			end_frequency = 880.0
			duration = 0.2
		_:
			pass
	var frames := maxi(1, roundi(MIX_RATE * duration))
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)
	for frame in frames:
		var progress := float(frame) / float(frames)
		var frequency_now := lerpf(frequency, end_frequency, progress)
		var wave := sin(TAU * frequency_now * float(frame) / float(MIX_RATE))
		var chip_wave := 1.0 if wave >= 0.0 else -1.0
		var envelope := pow(1.0 - progress, 1.8)
		var sample := clampi(roundi(chip_wave * envelope * 7600.0), -32768, 32767)
		bytes[frame * 2] = sample & 0xff
		bytes[frame * 2 + 1] = (sample >> 8) & 0xff
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = bytes
	return stream
