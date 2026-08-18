class_name ComponentDatabase
extends RefCounted
static func all()->Array:
 var parsed=JSON.parse_string(FileAccess.get_file_as_string("res://data/components.json"));return parsed.components if parsed is Dictionary else []
