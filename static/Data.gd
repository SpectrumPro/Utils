# Copyright (c) 2026 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name Data extends Object
## Class to manage custom data types


## Enum for Type
enum Type {
	NULL,				## Represents no value (null / None)
	STRING,				## A standard text string
	BOOL,				## A true/false boolean value
	INT,				## A 64-bit integer number
	FLOAT,				## A floating-point number
	ARRAY,				## A dynamic array of values
	DICTIONARY,			## A key/value map (hash table)
	VECTOR2,			## A 2D vector (x, y) with floats
	VECTOR2I,			## A 2D vector (x, y) with integers
	RECT2,				## A 2D rectangle defined by position and size (floats)
	RECT2I,				## A 2D rectangle defined by position and size (integers)
	VECTOR3,			## A 3D vector (x, y, z) with floats
	VECTOR3I,			## A 3D vector (x, y, z) with integers
	VECTOR4,			## A 4D vector (x, y, z, w) with floats
	VECTOR4I,			## A 4D vector (x, y, z, w) with integers
	COLOR,				## A color with red, green, blue, and alpha channels
	OBJECT,				## A reference to any Godot Object (Node, Resource, etc.)
	CALLABLE,			## A callable function reference
	SIGNAL,				## A signal reference (connectable event)
	ENUM,				## An enumerator
	BITFLAGS,			## Bit Flags
	NAME,				## A symbolic name or identifier 
	IP,					## An IP address
	INPUTEVENT,			## An InputEvent
	SETTINGSMANAGER,	## A SettingsManager
	PACKEDSCENE,		## A PackedScene object
	ACTION,				## An Action that can be triggred
}


## Map custom Type to Godot Variant.Type
static var custom_type_map: Dictionary[Type, Variant.Type] = {
	Type.NULL: 				TYPE_NIL,
	Type.STRING:			TYPE_STRING,
	Type.BOOL: 				TYPE_BOOL,
	Type.INT: 				TYPE_INT,
	Type.FLOAT:				TYPE_FLOAT,
	Type.ARRAY: 			TYPE_ARRAY,
	Type.DICTIONARY: 		TYPE_DICTIONARY,
	Type.VECTOR2: 			TYPE_VECTOR2,
	Type.VECTOR2I: 			TYPE_VECTOR2,
	Type.RECT2: 			TYPE_RECT2,
	Type.RECT2I: 			TYPE_RECT2,
	Type.VECTOR3: 			TYPE_VECTOR3,
	Type.VECTOR3I: 			TYPE_VECTOR3,
	Type.VECTOR4: 			TYPE_VECTOR4,
	Type.VECTOR4I: 			TYPE_VECTOR4,
	Type.COLOR:				TYPE_COLOR,
	Type.OBJECT: 			TYPE_OBJECT,
	Type.CALLABLE: 			TYPE_CALLABLE,
	Type.SIGNAL: 			TYPE_SIGNAL,
	Type.ENUM: 				TYPE_INT,
	Type.BITFLAGS: 			TYPE_INT,
	Type.NAME: 				TYPE_STRING,
	Type.IP:				TYPE_STRING,
	Type.INPUTEVENT:		TYPE_OBJECT,
	Type.SETTINGSMANAGER:	TYPE_OBJECT,
	Type.PACKEDSCENE:		TYPE_OBJECT,
	Type.ACTION:			TYPE_NIL,
}


## User config
static var _config: Dictionary[String, Variant]

## User config method to convert a custom type into a string
static var _custom_type_to_string_method: Callable

## User config method to get a name changed signal from an object
static var _get_object_name_signal_method: Callable


## static init
static func _static_init() -> void:
	var script: Variant = load("res://DataConfig.gd")
	
	if script is GDScript and script.get("config") is Dictionary:
		_config = script.get("config")
		
		_custom_type_to_string_method = type_convert(_config.get("custom_type_to_string_method"), TYPE_CALLABLE)
		_get_object_name_signal_method = type_convert(_config.get("get_object_name_signal_method"), TYPE_CALLABLE)


## Returns true if the 2 given types have a matching Variant.Type base
static func do_types_match_base(p_type_one: Type, p_type_two: Type) -> bool:
	var type_one_base: Variant.Type = custom_type_map[p_type_one]
	var type_two_base: Variant.Type = custom_type_map[p_type_two]
	
	return type_one_base == type_two_base


## Converts a custom data type to a string, with a human readable name
static func custom_type_to_string(p_variant: String, p_orignal_type: Type) -> String:
	if _custom_type_to_string_method.is_valid():
		var result: Variant = _custom_type_to_string_method.call(p_variant, p_orignal_type)
		
		if typeof(result) == TYPE_STRING:
			return result
			
	return type_convert(p_variant, TYPE_STRING)


## Returns the signal emitted when the name of an object is changed
static func get_object_name_changed_signal(p_module: SettingsModule) -> Signal:
	if _get_object_name_signal_method.is_valid():
		var result: Variant = _get_object_name_signal_method.call(p_module)
		
		if typeof(result) == TYPE_SIGNAL:
			return result
	
	var object: Variant = p_module.get_getter().call()
	if typeof(object) != TYPE_OBJECT or not is_instance_valid(object):
		return Signal()
	
	if object is Node:
		return (object as Node).renamed
	
	return Signal()
