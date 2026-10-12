extends SceneTree

func _initialize() -> void:
	print("=== Toepnacht core tests ===")
	var tests := CoreTests.new()
	var failures := tests.run_all()
	quit(1 if failures > 0 else 0)
