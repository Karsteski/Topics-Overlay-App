@tool
extends Control

@onready var text_edit: TextEdit = $PanelContainer/TextEdit

var topic_number: int = 0
var text_content: String = ""
var topics: PackedStringArray = []

enum Select {
	PREVIOUS,
	NEXT
}

func _ready() -> void:
	var exe_path: String = OS.get_executable_path()

	var topics_file_path: String = exe_path + "/topics.md"
	
	# For testing
	if Engine.is_editor_hint() or OS.has_feature("debug"):
		topics_file_path = "res://topics.md"	

	text_content = get_topics_file(topics_file_path)
	topics = separate_topics(text_content)

func _process(delta: float) -> void:
	text_edit.text = topics[topic_number]

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("next_topic"):
			iterate_topic(Select.NEXT)
		if event.is_action_pressed("previous_topic"):
			iterate_topic(Select.PREVIOUS)
		if event.is_action_pressed("toggle_always_on_top"):
			var always_on_top: bool = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP)
			
			# Toggle whether the main window is always on top
			var new_flag: bool = false if always_on_top else true
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, new_flag)
			print("Window: Always On Top: ", new_flag)


func get_topics_file(path: String) -> String:
	var topics_file: FileAccess = FileAccess.open(path, FileAccess.READ)

	var topics_file_content: String = ""

	if topics_file == null:
		const error: String = "- Topics file either does not exist or could not be accessed..."
		topics_file_content = error
		printerr(error)
	else:
		topics_file_content = topics_file.get_as_text()

	return topics_file_content

func separate_topics(content: String) -> PackedStringArray:
	const allow_empty := false
	var separated_topics: PackedStringArray = content.split("-", allow_empty)

	return separated_topics

func iterate_topic(select: Select) -> void:
	match select:
		Select.PREVIOUS:
			topic_number -= 1
			if topic_number < 0:
				topic_number = topics.size() - 1
			print("Topic: ", topic_number)
		Select.NEXT:
			topic_number += 1
			if topic_number >= topics.size():
				topic_number = 0
			print("Topic: ", topic_number)
		_:
			pass
