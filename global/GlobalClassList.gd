# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name CoreGlobalClassList extends CoreClassListDB
## Contains all CoreGlobal classes


## Init
func _init(p_uuid: String = "", ...p_args: Array[Variant]) -> void:
	super._init(p_uuid, p_args)
	_set_class_name("CoreGlobalClassList")
