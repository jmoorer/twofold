extends Node
var cache: Dictionary={}
var voices: Array[AudioStreamPlayer]=[]
var next_voice:=0
var last_fusion:=-999
func _ready() -> void:
	for i in 10:
		var p:=AudioStreamPlayer.new()
		add_child(p)
		voices.append(p)
	var rng:=RandomNumberGenerator.new()
	rng.seed=246
	for key in ["cast","heavy","dash","fusion","hurt","clear","select","buy","fall"]:
		var config: Array={
			"cast":[360,80,0.16],"heavy":[260,45,0.32],"dash":[640,110,0.22],
			"fusion":[430,90,0.38],"hurt":[145,50,0.19],"clear":[330,880,0.55],
			"select":[380,690,0.09],"buy":[530,1050,0.23],"fall":[175,65,0.15]}[key]
		var samples:=int(22050*float(config[2]))
		var data:=PackedByteArray()
		data.resize(samples*2)
		var phase:=0.0
		for i in samples:
			var t:=float(i)/samples
			var freq:=lerpf(config[0],config[1],sqrt(t))
			phase+=TAU*freq/22050.0
			var val:=sin(phase)+sin(phase*2.01)*0.22
			if key in ["dash","hurt","heavy","fusion","cast"]:
				val+=rng.randf_range(-1,1)*0.5*(1-t)
			if key=="clear" or key=="buy": val+=sin(phase*1.5)*0.55
			var env:=minf(1,t*40)*pow(1.0-t,2.2)
			data.encode_s16(i*2,int(clampf(val*env*0.56,-1,1)*32767))
		var wav:=AudioStreamWAV.new()
		wav.format=AudioStreamWAV.FORMAT_16_BITS
		wav.mix_rate=22050
		wav.data=data
		cache[key]=wav

func play_note(key: String, pitch:=1.0) -> void:
	if key=="fusion":
		if Time.get_ticks_msec()-last_fusion<75: return
		last_fusion=Time.get_ticks_msec()
	var p:=voices[next_voice]
	next_voice=(next_voice+1)%voices.size()
	p.stream=cache[key]
	p.volume_db=-10 if key=="fall" else -5
	p.pitch_scale=pitch*randf_range(0.97,1.03)
	p.play()
