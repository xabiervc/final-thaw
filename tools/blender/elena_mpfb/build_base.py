"""Elena base body (MPFB 2.0.18) -> rigged, helper-free mesh, 1.70 m, A-pose.

Run inside Blender with the MPFB extension enabled (bpy.ops.preferences.addon_enable(module='bl_ext.blender_org.mpfb')):
    exec(open(path).read())
Rig weights are indexed on the full base mesh, so helper geometry is deleted only AFTER the rig is added.
"""
import math

import bpy
from bl_ext.blender_org.mpfb.services.humanservice import HumanService
from bl_ext.blender_org.mpfb.services.targetservice import TargetService

TARGET_HEIGHT = 1.70
MPFB_ROOT = bpy.utils.user_resource('EXTENSIONS') + '/blender_org/mpfb/data/targets'
MACRO = {'gender': 0.0, 'age': 0.52, 'muscle': 0.4, 'weight': 0.42, 'height': 0.573, 'proportions': 0.5,
	'cupsize': 0.4, 'firmness': 0.5, 'race': {'asian': 0.1, 'caucasian': 0.75, 'african': 0.15}}
# Tired, tense face from elena_vast_concept.png (target path -> weight)
FACE = {
	'head/head-oval': 0.5, 'head/head-age-incr': 0.15,
	'eyes/l-eye-bag-incr': 0.5, 'eyes/r-eye-bag-incr': 0.5, 'eyes/l-eye-eyefold-down': 0.3, 'eyes/r-eye-eyefold-down': 0.3,
	'eyes/l-eye-scale-incr': 0.15, 'eyes/r-eye-scale-incr': 0.15, 'eyebrows/eyebrows-trans-down': 0.3,
	'cheek/l-cheek-bones-incr': 0.3, 'cheek/r-cheek-bones-incr': 0.3, 'cheek/l-cheek-volume-decr': 0.25, 'cheek/r-cheek-volume-decr': 0.25,
	'mouth/mouth-angles-down': 0.35, 'mouth/mouth-lowerlip-volume-incr': 0.15, 'mouth/mouth-scale-horiz-decr': 0.15,
	'nose/nose-compression-compress': 0.2, 'nose/nose-point-width-decr': 0.2,
	'chin/chin-width-decr': 0.25, 'chin/chin-prominent-decr': 0.1, 'forehead/forehead-scale-vert-incr': 0.15,
}


def build():
	for o in list(bpy.data.objects):
		if o.type != 'CAMERA':
			bpy.data.objects.remove(o)
	macro = TargetService.get_default_macro_info_dict()
	macro.update(MACRO)
	body = HumanService.create_human(mask_helpers=False, detailed_helpers=False, extra_vertex_groups=True,
		feet_on_ground=True, scale=0.1, macro_detail_dict=macro)
	body.name = 'Elena_Base'
	bpy.context.view_layer.objects.active = body
	for key, weight in FACE.items():
		folder, name = key.split('/')
		TargetService.load_target(body, f'{MPFB_ROOT}/{folder}/{name}.target.gz', weight=weight)
	rig = HumanService.add_builtin_rig(body, 'game_engine', import_weights=True)
	_snap_rig_to_body(body, rig)
	bpy.context.view_layer.objects.active = body
	body.select_set(True)
	bpy.ops.object.shape_key_remove(all=True, apply_mix=True)  # bake macro + face targets so garments copy the final shape
	return body, rig


def _snap_rig_to_body(body, rig):
	"""MPFB fits the rig before the feet-on-ground lift, leaving bones ~0.85 m low. Shift them by the head-top difference."""
	bpy.context.view_layer.update()
	depsgraph = bpy.context.evaluated_depsgraph_get()
	top = max(v.co.z for v in body.evaluated_get(depsgraph).data.vertices)
	dz = top - (rig.matrix_world @ rig.data.bones['head'].tail_local).z
	bpy.ops.object.select_all(action='DESELECT')
	bpy.context.view_layer.objects.active = rig
	rig.select_set(True)
	bpy.ops.object.mode_set(mode='EDIT')
	for bone in rig.data.edit_bones:
		bone.head.z += dz
		bone.tail.z += dz
	bpy.ops.object.mode_set(mode='OBJECT')
	print('rig shifted by', dz)


def strip_helpers(body):
	bpy.ops.object.select_all(action='DESELECT')
	bpy.context.view_layer.objects.active = body
	body.select_set(True)
	bpy.ops.object.mode_set(mode='EDIT')
	bpy.ops.mesh.select_all(action='DESELECT')
	for name in ('HelperGeometry', 'JointCubes'):
		body.vertex_groups.active_index = body.vertex_groups[name].index
		bpy.ops.object.vertex_group_select()
	bpy.ops.mesh.delete(type='VERT')
	bpy.ops.object.mode_set(mode='OBJECT')


if __name__ == '__main__' or True:
	body, rig = build()
	strip_helpers(body)
	print('body', body.name, len(body.data.vertices), 'rig', rig.name if rig else None, len(rig.data.bones) if rig else 0)
