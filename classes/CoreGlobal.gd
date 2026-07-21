# Copyright (c) 2026 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name CoreGlobal extends Node
## base class for all autoload globals

@warning_ignore_start("unused_signal", "unused_private_class_variable", "unused_parameter")

## NOP, required for compliance
signal name_changed(new_name: String)

## NOP, required for compliance
signal delete_requested(from: Object)


## The UUID of this object. The variable name can be arbitrary.
var _uuid: String

## The class name of this object. Must be set by any class that extends this base class.
var _class_name: String

## The inheritance tree of this object. Defaults to include this class.
var _class_tree: Array[String]

## The SettingsManager instance associated with this object. Variable name can be arbitrary.
var _settings: SettingsManager = SettingsManager.new()


## init
func _init(p_uuid: String = "", ...p_args: Array[Variant]) -> void:
	_set_class_name("CoreGlobal")
	
	_settings.set_owner(self)
	_settings.set_inheritance_array(_class_tree)
	
	_settings.register_control("Name", Data.Type.STRING, set_uname, get_uname, [name_changed])
	_settings.register_status("Class", Data.Type.STRING, get_class_name)
	
	_settings.add_primary_module("Name")


## Returns the user-defined name of this object.
func get_uname() -> String:
	return name


## Returns the UUID of this object.
func get_uuid() -> String:
	return _uuid


## Returns the class name of this object.
func get_class_name() -> String:
	return _class_name


## Returns the base class of this object
func get_base_class() -> String:
	return _class_tree[-1]


## Returns a copy of the inheritance tree for this object.
func get_class_tree() -> Array[String]:
	return _class_tree.duplicate()


## Returns the SettingsManager for this object.
func get_settings() -> SettingsManager:
	return _settings


## NOP, required for compliance
func set_uname(p_name: String, p_no_signal: bool = false) -> void:
	return


## NOP, required for compliance
func delete() -> void:
	delete_requested.emit()


## Returns a JSON-compliant dictionary containing a serialized version of this object.
func serialize(p_flags: Data.SerializationFlags) -> Dictionary[String, Variant]:
	return {}


## Deserializes data either read from disk or returned by serialize().
func deserialize(p_serialized_data: Dictionary, p_flags: Data.SerializationFlags) -> void:
	return


## Sets the class name for this object and appends it to the inheritance tree.
func _set_class_name(p_class_name: String) -> void:
	_uuid = p_class_name
	_class_name = p_class_name
	_class_tree.append(p_class_name)
