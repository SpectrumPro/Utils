# Copyright (c) 2026 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name GBCIndexConfig extends Object
## Class for storing ObjectDB and ClassListDB entrys for GBC complient objects


## The base class
var _base_class: Script

## The ObjectDB for the base class
var _objectdb: ObjectDB

## The ClassListDB for the base class
var _classdb: ClassListDB

## The ChildManager to use when adding and removing objects
var _child_manager: ChildManager


## Init
func _init(p_base_class: Script, p_objectdb: ObjectDB, p_classdb: ClassListDB, p_child_manager: ChildManager) -> void:
	_base_class = p_base_class
	_objectdb = p_objectdb
	_classdb = p_classdb
	_child_manager = p_child_manager


## Returns the Script for the base class of this GBC
func get_base_class() -> Script:
	return _base_class


## Returns the ObjectDB for this GBC Class
func get_objectdb() -> ObjectDB:
	return _objectdb


## Returns the ObjectDB for this GBC Class
func get_class_listdb() -> ClassListDB:
	return _classdb


## Return ChildManager
func get_child_manager() -> ChildManager:
	return _child_manager
