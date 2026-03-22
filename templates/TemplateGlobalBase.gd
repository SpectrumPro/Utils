# Copyright (c) 2026 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name GlobalBaseClass extends Object
## The GlobalBaseClass (GBC) defines the required member variables, signals, constructors, and methods
## that a class must implement to be compatible with the global ClassList and ObjectDB.
##
## Any class can extend any built-in Godot class (e.g., Node, RefCounted) as long as it implements
## the following structure and methods.

@warning_ignore_start("unused_signal", "unused_private_class_variable", "unused_parameter")

## Emitted when the user-defined name of this object changes.
signal name_changed()

## Emitted when this object is to be deleted (freed from memory). 
## Required to notify any other scripts referencing this object to de-reference it.
signal delete_requested()


## The user-defined name of this object. The variable name can be arbitrary.
var _name: String

## The UUID of this object. The variable name can be arbitrary.
var _uuid: String

## The class name of this object. Must be set by any class that extends this base class.
var _class_name: String

## The inheritance tree of this object. Defaults to include this class.
var _class_tree: Array[String]

## The SettingsManager instance associated with this object. Variable name can be arbitrary.
var _settings: SettingsManager


## Constructor. Must support defining the object's UUID.
## p_uuid is optional and defaults to a new UUID, useful when using PackedScene.instantiate.
func _init(p_uuid: String = UUID.v4(), ...p_args: Array[Variant]) -> void:
	_uuid = p_uuid
	_set_class_name("GlobalBaseClass")
	
	_settings.set_owner(self)
	_settings.set_inheritance_array(_class_tree)


## Returns the user-defined name of this object.
func get_uname() -> String:
	return _name


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


## Sets the name of this object. If p_no_signal is true, the name_changed signal is not emitted.
func set_uname(p_name: String, p_no_signal: bool = false) -> void:
	_name = p_name
	
	if not p_no_signal:
		name_changed.emit(_name)


## Emits the delete_requested signal to notify that this object should be deleted.
func delete() -> void:
	delete_requested.emit()


## Returns a JSON-compliant dictionary containing a serialized version of this object.
func serialize(p_flags: Data.SerializationFlags) -> Dictionary[String, Variant]:
	return {
		"name": _name,
		"class_name": _class_name,
	}.merged({} if p_flags & Data.SerializationFlags.NO_UUID else {
		"uuid": _uuid,
	})


## Deserializes data either read from disk or returned by serialize().
func deserialize(p_serialized_data: Dictionary, p_flags: Data.SerializationFlags) -> void:
	set_uname(type_convert(p_serialized_data.get("name", _name), TYPE_STRING), true)
	
	if not p_flags & Data.SerializationFlags.NO_UUID:
		_uuid = type_convert(p_serialized_data.get("uuid", _uuid), TYPE_STRING)


## Sets the class name for this object and appends it to the inheritance tree.
## This should be called by each child class during initialization.
func _set_class_name(p_class_name: String) -> void:
	_class_name = p_class_name
	_class_tree.append(p_class_name)
