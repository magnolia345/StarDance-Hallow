# interactable.gd — base class for all interactables
extends StaticBody3D
class_name Interactable

var is_highlighted = false
var original_materials = {}

func highlight():
	if is_highlighted:
		return
	is_highlighted = true
	_apply_highlight(get_parent())

func unhighlight():
	if not is_highlighted:
		return
	is_highlighted = false
	_remove_highlight()

func _apply_highlight(node):
	# find all MeshInstance3D children and add emission
	for child in _get_all_meshes(node):
		var mat = child.get_active_material(0)
		if mat:
			var new_mat = mat.duplicate()
			new_mat.emission_enabled = true
			new_mat.emission = Color(0.457, 0.406, 0.316, 1.0)
			new_mat.emission_energy_multiplier = 0.4
			original_materials[child] = child.material_override
			child.material_override = new_mat

func _remove_highlight():
	for child in original_materials:
		child.material_override = original_materials[child]
	original_materials.clear()

func _get_all_meshes(node):
	var meshes = []
	if node is MeshInstance3D:
		meshes.append(node)
	for c in node.get_children():
		meshes += _get_all_meshes(c)
	return meshes

func interact():
	pass  # each object overrides this
