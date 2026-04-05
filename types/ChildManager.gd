# Copyright (c) 2026 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name ChildManager extends Object
## Class for managing children of another object


## Emitted when either children are added and or removed from the parent
signal modification_callback(added: Array, removed: Array)


## The parent Object
var _parent: Object

## The Callable to create a new child
var _create_child_method: Callable

## The Callable to add a single child
var _add_child_method: Callable

## The Callable to add mutiple children
var _add_children_method: Callable

## The Callable to remove a single child
var _remove_child_method: Callable

## The Callable to remove mutiple children
var _remove_children_method: Callable

## The Callable to duplicate a child
var _duplicate_child_method: Callable

## The Callable to duplicate mutiple children
var _duplicate_children_method: Callable

## The Callable to get all children
var _get_children_method: Callable

## The Signal emitted when children are added
var _children_added: Signal

## The Signal emitted when children are removed
var _children_removed: Signal

## The base class Script asigned to the classes GBCIndexConfig
var _index_class: Script

## The parent class all child classes must inherent
var _child_class: Script

## The queue of children that have just been added
var _addition_queue: Array

## The queue of children that have just been removed
var _removal_queue: Array

## True if the emission of modification_callback has already been queued
var _emission_queued: bool 

## The SettingsManager that manages this ChildManager
var _manager: SettingsManager

## The String ID asigned to this ChildManager when its managed by a SettingsManager
var _id: String

## The String category asigned to this ChildManager when its managed by a SettingsManager
var _category: String


## init
func _init(
	p_parent: Object,
	p_create_child: Callable,
	p_add_child: Callable, 
	p_add_children: Callable, 
	p_remove_child: Callable, 
	p_remove_children: Callable,
	p_duplicate_child: Callable,
	p_duplicate_children: Callable,
	p_get_children: Callable,
	p_children_added: Signal,
	p_children_removed: Signal,
	p_index_class: Script,
	p_child_class: Script
	) -> void:
	set_parent(p_parent)
	set_create_child(p_create_child)
	set_add_child_method(p_add_child)
	set_add_children_method(p_add_children)
	set_remove_child_method(p_remove_child)
	set_remove_children_method(p_remove_children)
	set_duplicate_child_method(p_duplicate_child)
	set_duplicate_childred_method(p_duplicate_children)
	set_get_children_method(p_get_children)
	set_children_removed(p_children_removed)
	set_children_added(p_children_added)
	set_index_class(p_index_class)
	set_child_class(p_child_class)


## Creates a new child with the given class name. Resolves with the new child Object.
func create_child(p_class_name: String) -> Promise:
	return _call_if_valid_promise(_create_child_method, [p_class_name])


## Adds a single child to the parent. Resolves with true if the child was added, false if it already existed.
func add_child(p_child: Object) -> Promise:
	return _call_if_valid_promise(_add_child_method, [p_child])


## Adds multiple children to the parent. Resolves with no value.
func add_children(p_children: Array) -> Promise:
	return _call_if_valid_promise(_add_children_method, [p_children])


## Removes a single child from the parent. Resolves with true if the child was removed, false if it did not exist.
func remove_child(p_child: Object) -> Promise:
	return _call_if_valid_promise(_remove_child_method, [p_child])


## Removes multiple children from the parent. Resolves with no value.
func remove_children(p_children: Array) -> Promise:
	return _call_if_valid_promise(_remove_children_method, [p_children])


## Duplicates a single child. Resolves with the new child Object
func duplicate_child(p_child: Object) -> Promise:
	return _call_if_valid_promise(_duplicate_child_method, [p_child])


## Duplicates mutiple children. Resolves with the new child Objects
func duplicate_children(p_children: Array) -> Promise:
	return _call_if_valid_promise(_duplicate_children_method, [p_children])


## Returns all the children in the parent
func get_children() -> Array:
	if _get_children_method.is_null():
		return []
	
	return _get_children_method.call()


## Get the parent Object
func get_parent() -> Object:
	return _parent


## Gets the Callable used to create a child
func get_create_child_method() -> Callable:
	return _create_child_method


## Get the Callable used to add a single child
func get_add_child_method() -> Callable:
	return _add_child_method


## Get the Callable used to add multiple children
func get_add_children_method() -> Callable:
	return _add_children_method


## Get the Callable used to remove a single child
func get_remove_child_method() -> Callable:
	return _remove_child_method


## Get the Callable used to remove multiple children
func get_remove_children_method() -> Callable:
	return _remove_children_method


## Gets the Callable used to duplicate a child
func get_duplicate_child_method() -> Callable:
	return _duplicate_child_method


## Gets the Callable used to duplicate mutiple children
func get_duplicate_children_method() -> Callable:
	return _duplicate_child_method


## Get the Callable used to get all children
func get_get_children_method() -> Callable:
	return _get_children_method


## Get the Signal emitted when children are added
func get_children_added() -> Signal:
	return _children_added


## Get the Signal emitted when children are removed
func get_children_removed() -> Signal:
	return _children_removed


## Get the Script assigned to GBCIndexConfig
func get_index_class() -> Script:
	return _index_class


## Get the parent class that all child classes must inherit
func get_child_class() -> Script:
	return _child_class


## Returns the SettingsManager that manages this ChildManager
func get_settings_manager() -> SettingsManager:
	return _manager


## Returns the ID of this ChildManager
func get_id() -> String:
	return _id


## Returns the category of this ChildManager
func get_category() -> String:
	return _category


## Set the parent Object
func set_parent(p_parent: Object) -> void:
	_parent = p_parent


## Sets the Callable used to create a child
func set_create_child(p_method: Callable) -> void:
	_create_child_method = p_method


## Set the Callable used to add a single child
func set_add_child_method(p_method: Callable) -> void:
	_add_child_method = p_method


## Set the Callable used to add multiple children
func set_add_children_method(p_method: Callable) -> void:
	_add_children_method = p_method


## Set the Callable used to remove a single child
func set_remove_child_method(p_method: Callable) -> void:
	_remove_child_method = p_method


## Set the Callable used to remove multiple children
func set_remove_children_method(p_method: Callable) -> void:
	_remove_children_method = p_method


## Sets the Callable used to duplicate a child
func set_duplicate_child_method(p_method: Callable) -> void:
	_duplicate_child_method = p_method


## Sets the Callable used to duplicate mutiple children
func set_duplicate_childred_method(p_method: Callable) -> void:
	_duplicate_children_method = p_method


## Set the Callable used to get all children
func set_get_children_method(p_method: Callable) -> void:
	_get_children_method = p_method


## Set the Signal emitted when children are added
func set_children_added(p_signal: Signal) -> void:
	if not _children_added.is_null():
		_children_added.disconnect(_on_children_added)
	
	_children_added = p_signal
	
	if not _children_added.is_null():
		_children_added.connect(_on_children_added)


## Set the Signal emitted when children are removed
func set_children_removed(p_signal: Signal) -> void:
	if not _children_removed.is_null():
		_children_removed.disconnect(_on_children_removed)
	
	_children_removed = p_signal
	
	if not _children_removed.is_null():
		_children_removed.connect(_on_children_removed)


## Set the Script assigned to GBCIndexConfig
func set_index_class(p_script: Script) -> void:
	_index_class = p_script


## Set the parent class that all child classes must inherit
func set_child_class(p_script: Script) -> void:
	_child_class = p_script


## Returns true if this ChildManager is read only, ie all add and remove methods are null
func is_read_only() -> bool:
	if is_addition_allowed() and is_deletion_allowed() and is_duplication_allowed():
		return true
	else:
		return false


## Returns true if adding child objects is allowed. IE all add method are valid
func is_addition_allowed() -> bool:
	if _create_child_method.is_null() and _add_child_method.is_null() and _add_children_method.is_null():
		return false
	else:
		return true


## Returns true if deleting child objects is allowed. IE all delete method are valid
func is_deletion_allowed() -> bool:
	if _remove_child_method.is_null() and _remove_children_method.is_null():
		return false
	else:
		return true


## Returns true if duplicating child objects is allowed. IE all duplicate method are valid
func is_duplication_allowed() -> bool:
	if _duplicate_child_method.is_null() and _duplicate_children_method.is_null():
		return false
	else:
		return true


## Sets the SettingsManager
func _set_settings_manager(p_manager: SettingsManager) -> void:
	_manager = p_manager


## Sets the ID
func _set_id(p_id: String) -> void:
	_id = p_id


## Sets the category
func _set_category(p_category: String) -> void:
	_category = p_category


## Queues (if not already) the emission of modification_callback
func _queue_emission() -> void:
	if _emission_queued:
		return
	
	(func () -> void:
		modification_callback.emit(_addition_queue.duplicate(), _removal_queue.duplicate())
		_addition_queue.clear()
		_removal_queue.clear()
		_emission_queued = false
	).call_deferred()


## Calls the given method with the given args, returning a promise
func _call_if_valid_promise(p_method: Callable, ...p_args: Array) -> Promise:
	if p_method.is_null():
		return Promise.new().auto_reject()
	
	var result: Variant = p_method.callv(p_args)
	if result is Promise:
		return result
	else:
		return Promise.new().auto_resolve([result])


## Called when children are added to the parent
func _on_children_added(p_children: Array) -> void:
	_addition_queue.append_array(p_children)
	_queue_emission()


## Called when children are removed from the parent
func _on_children_removed(p_children: Array) -> void:
	_removal_queue.append_array(p_children)
	_queue_emission()
