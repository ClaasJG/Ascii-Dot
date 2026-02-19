@tool
extends EditorPlugin

const _ASCII_TERMINAL_NAME := "AsciiTerminal"

func _enter_tree() -> void:
	var icon := preload("./ascii_terminal.svg")
	var script := preload("./ascii_terminal.gd")
	add_custom_type(_ASCII_TERMINAL_NAME, "ColorRect", script, icon)


func _exit_tree() -> void:
	remove_custom_type(_ASCII_TERMINAL_NAME)
