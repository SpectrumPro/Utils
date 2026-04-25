# Copyright (c) 2026 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name CoreClassListDB extends CoreGlobal
## Contains a list of all the classes for a given base class


## Stores the GBCIndexConfig for all classes in any CoreClassListDB
static var _class_gbc_relations: Dictionary[String, GBCIndexConfig]


## Contains all the classes sorted by the class hierarchy tree
var _global_class_tree: Dictionary

## Contains all classes keyed by clasname, value is an array containing all classes that exten the keyed class
var _inheritance_map: Dictionary[String, Array]

## Contains the class inheritance list for each class
var _inheritance_trees: Dictionary[String, Array]

## Contains all the class scripts keyed by the classname
var _script_map: Dictionary[String, Script]

## Contains all the hidden classes that should not be shown to the user
var _hidden_classes: Array[String]

## Classes that should always seralize
var _always_searlize_classes: Array[String]

## True if rebuild_maps has been called
var _has_built_maps: bool = false

## The GBCIndex theese classes are from
var _gbc_index: GBCIndexConfig


## init
func _init(p_uuid: String = "", ...p_args: Array[Variant]) -> void:
	super._init(p_uuid, p_args)
	_set_class_name("CoreClassListDB")


## ready
func _ready() -> void:
	rebuild_maps(_global_class_tree)


## Merges in another class tree, rebuilds maps if needed
func merge_class_tree(p_tree: Dictionary) -> void:
	if not p_tree:
		return
	
	Utils.merge_deep(_global_class_tree, p_tree)
	
	if _has_built_maps:
		rebuild_maps(_global_class_tree)


## Builds both the inheritance map and the class script map from the class_tree.
func rebuild_maps(p_tree: Dictionary) -> void:
	_has_built_maps = false
	
	for key: String in p_tree.keys():
		_process_node(key, p_tree[key], [key])
	
	_has_built_maps = true


## Returns the class script from the script map, or null if not found
func get_class_script(p_classname: String) -> Script:
	return _script_map.get(p_classname, null)


## Returns a copy of the global class tree
func get_global_class_tree() -> Dictionary:
	return _global_class_tree.duplicate(true)


## Returns a copy of the class inheritance map
func get_inheritance_map() -> Dictionary:
	return _inheritance_map.duplicate(true)


## Returns a copy of the script map
func get_script_map() -> Dictionary:
	return _script_map.duplicate()


## Returns the parent classname of the given class, or "" if the class is top level
func get_class_parent(p_classname: String) -> String:
	var inhr_tree: Array = _inheritance_trees.get(p_classname, [])
	
	if not inhr_tree.size() >= 2:
		return ""
	else:
		return inhr_tree[-2]


## Gets all the classes that extend the given parent class
func get_classes_from_parent(parent_class: String) -> Dictionary:
	return _inheritance_map.get(parent_class, {}).duplicate()


## Returns a copy of a class's inheritance
func get_class_inheritance_tree(classname: String) -> Array:
	return _inheritance_trees.get(classname, []).duplicate()


## Returns the GBCIndexConfig for a given classname
static func get_class_gbc_index(p_classname: String) -> GBCIndexConfig:
	return _class_gbc_relations.get(p_classname, null)


## Checks if the given class is marked as hidden
func is_class_hidden(classname: String) -> bool:
	return _hidden_classes.has(classname)


## Checks if a class exists in the map, also allows for checking the classname of the parent
func has_class(p_classname: String, p_match_parent: String = "") -> bool:
	if p_match_parent:
		return _script_map.has(p_classname) and _inheritance_map.get(p_match_parent, {}).has(p_classname)
	else:
		return _script_map.has(p_classname)


## Checks if a class inherits from another class
func does_class_inherit(p_base_class: String, p_inheritance: String) -> bool:
	return _inheritance_trees.get(p_base_class, []).has(p_inheritance)


## Returns true if the parent class is an ansestor of the child class
func does_parent_have(p_parent_class: String, p_child_class: String) -> bool:
	return _inheritance_map.get(p_parent_class, []).has(p_child_class)


## Checks if a class should seralize
func should_class_searlize(p_classname: String) -> bool:
	return _always_searlize_classes.has(p_classname)


## Processes a node in the class_tree.
func _process_node(p_class: String, p_value: Variant, p_current_position: Array) -> void:
	match typeof(p_value):
		TYPE_DICTIONARY:
			for classname: String in p_value:
				var remove: bool = true
				
				if p_current_position[-1] != classname:
					p_current_position.append(classname)
				else:
					remove = false
				
				_process_node(classname, p_value[classname], p_current_position)
				
				if remove:
					p_current_position.pop_back()
		
		TYPE_OBJECT when p_value is Script:
			_inheritance_trees[p_class] = p_current_position.duplicate()
			_class_gbc_relations[p_class] = _gbc_index
			_script_map[p_class] = p_value
			
			for position: String in p_current_position:
				_inheritance_map.get_or_add(position, []).append(p_class)
