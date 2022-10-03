extends Label

var running = false;
var elapsed = 0;

func _process(delta):
	elapsed += delta;
	text = "%0.3f" % elapsed
