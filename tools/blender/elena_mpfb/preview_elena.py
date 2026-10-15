"""Review renders of an Elena .blend (Cycles, CPU): face front/three-quarter/side and full body front/back.

    blender -b <file.blend> --python tools/blender/elena_mpfb/preview_elena.py -- --out <dir> [--skin <png>] [--samples 24]

Review only: the images go to the evidence folder, never into the repository. The skin texture, when given, replaces the body
material for the render so the MakeHuman UVs can be checked before the bake.
"""
import math
import os
import sys

import bpy
from mathutils import Vector

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
from lab_blender_common import parse_args  # noqa: E402

SHOTS = {  # name: (camera location, look-at, focal length mm)
	"face_front": ((0.0, -0.75, 1.60), (0.0, 0.0, 1.58), 85),
	"face_34": ((0.42, -0.62, 1.62), (0.0, 0.0, 1.57), 85),
	"face_side": ((0.75, -0.02, 1.60), (0.0, 0.0, 1.58), 85),
	"head_back": ((-0.25, 0.75, 1.62), (0.0, 0.0, 1.55), 70),
	"body_front": ((0.0, -4.2, 1.0), (0.0, 0.0, 0.88), 50),
	"body_34": ((2.6, -3.3, 1.1), (0.0, 0.0, 0.88), 50),
	"body_back": ((0.0, 4.2, 1.0), (0.0, 0.0, 0.88), 50),
}


def look(cam, loc, at):
	cam.location = loc
	d = Vector(at) - Vector(loc)
	cam.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()


def skin_material(png):
	mat = bpy.data.materials.new("preview_skin")
	mat.use_nodes = True
	nt = mat.node_tree
	bsdf = nt.nodes["Principled BSDF"]
	tex = nt.nodes.new("ShaderNodeTexImage")
	tex.image = bpy.data.images.load(png)
	nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
	bsdf.inputs["Roughness"].default_value = 0.5
	return mat


def alpha_material(name, png):
	mat = bpy.data.materials.new(name)
	mat.use_nodes = True
	nt = mat.node_tree
	bsdf = nt.nodes["Principled BSDF"]
	tex = nt.nodes.new("ShaderNodeTexImage")
	tex.image = bpy.data.images.load(png)
	nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
	nt.links.new(tex.outputs["Alpha"], bsdf.inputs["Alpha"])
	bsdf.inputs["Roughness"].default_value = 0.45
	return mat


# MakeHuman textures for the fitted head parts (preview only; the bake writes the shipped materials)
MH_TEXTURES = {"Elena_Eyebrows": "eyebrows/eyebrow001/eyebrow001.png", "Elena_Eyelashes": "eyelashes/eyelashes02/eyelashes02.png",
	"Elena_Eyes": "eyes/materials/brown_eye.png"}


def main():
	options = {"out": None, "skin": "", "samples": "24", "res": "640", "only": "", "mh": "D:/Projects/external_assets/makehuman/system"}
	parse_args(options)
	os.makedirs(options["out"], exist_ok=True)
	scene = bpy.context.scene
	scene.render.engine = "CYCLES"
	scene.cycles.device = "CPU"
	scene.cycles.samples = int(options["samples"])
	scene.cycles.use_denoising = True
	scene.render.resolution_x = int(options["res"])
	scene.render.resolution_y = int(options["res"])
	scene.render.film_transparent = False
	scene.view_settings.view_transform = "AgX"
	world = bpy.data.worlds.new("preview") if scene.world is None else scene.world
	scene.world = world
	world.use_nodes = True
	world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.32, 0.34, 0.36, 1.0)
	world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.6
	if options["skin"]:
		body = bpy.data.objects["Elena_Base"]
		body.data.materials.clear()
		body.data.materials.append(skin_material(options["skin"]))
	for obj_name, rel in MH_TEXTURES.items():
		obj = bpy.data.objects.get(obj_name)
		if obj is not None:
			obj.data.materials.clear()
			obj.data.materials.append(alpha_material(obj_name + "_prev", os.path.join(options["mh"], rel)))
	hair = bpy.data.objects.get("Elena_HairMH")
	if hair is not None and hair.get("mh_texture"):
		hair.data.materials.clear()
		hair.data.materials.append(alpha_material("hair_prev", hair["mh_texture"]))
	for name, (loc, rot, energy, size) in {"Key": ((-1.6, -2.2, 2.6), None, 260.0, 1.2), "Rim": ((1.8, 2.0, 2.2), None, 160.0, 0.8)}.items():
		light = bpy.data.lights.new(name, "AREA")
		light.energy = energy
		light.size = size
		obj = bpy.data.objects.new(name, light)
		scene.collection.objects.link(obj)
		look(obj, loc, (0.0, 0.0, 1.2))
	cam_data = bpy.data.cameras.new("PreviewCam")
	cam = bpy.data.objects.new("PreviewCam", cam_data)
	scene.collection.objects.link(cam)
	scene.camera = cam
	only = [s for s in options["only"].split(",") if s]
	for name, (loc, at, focal) in SHOTS.items():
		if only and name not in only:
			continue
		look(cam, loc, at)
		cam_data.lens = focal
		scene.render.filepath = os.path.join(options["out"], name + ".png")
		bpy.ops.render.render(write_still=True)
		print("[preview] " + scene.render.filepath)


if __name__ == "__main__":
	main()
