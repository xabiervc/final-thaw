"""Regenera toda la escena de referencia (Blender headless, en orden).

    python tools/blender/reference/build_all.py [--samples 12] [--only floor,wall,terminal,elena]

Cada paso hornea sus texturas con Cycles (CPU) y escribe GLB, PNG y .tres en el repositorio; los
.blend van a --blend-dir (fuera del repo). Requiere Blender 5.2 en la ruta por defecto o --blender.
"""

import argparse
import os
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
STEPS = {
	"floor": [("build_ref_floor.py", ["--variant", "drain"]), ("build_ref_floor.py", ["--variant", "plain"])],
	"wall": [("build_ref_wall.py", [])],
	"terminal": [("build_ref_terminal.py", [])],
	"elena": [("build_ref_elena.py", [])],
}


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("--blender", default=r"C:\Program Files\Blender Foundation\Blender 5.2\blender.exe")
	parser.add_argument("--blend-dir", default=r"D:\Projects\evidence\final-thaw\lab-ref-source")
	parser.add_argument("--samples", default="12")
	parser.add_argument("--only", default="floor,wall,terminal,elena")
	args = parser.parse_args()
	for name in args.only.split(","):
		for script, extra in STEPS[name]:
			started = time.time()
			command = [args.blender, "--background", "--factory-startup", "--python", os.path.join(HERE, script), "--",
				"--repo", REPO, "--blend-dir", args.blend_dir, "--samples", args.samples] + extra
			print("[build_all] %s %s" % (script, " ".join(extra)), flush=True)
			result = subprocess.run(command, capture_output=True, text=True)
			for line in result.stdout.splitlines():
				if line.startswith("[") or "Error" in line or "Traceback" in line:
					print("  " + line)
			if result.returncode != 0 or "Traceback" in result.stdout or "Traceback" in result.stderr:
				print(result.stdout[-2500:] + result.stderr[-1500:])
				sys.exit(result.returncode or 1)
			print("[build_all] hecho en %.0f s" % (time.time() - started), flush=True)


main()
