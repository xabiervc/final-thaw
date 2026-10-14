extends RefCounted
## Walkable route graph of the Phase 1 building, used by the recovery unit to move physically through it.
## Nodes sit on real walking surfaces; edges are straight lines that are clear for a 0.45 m radius body.
## Edge kind "walk" is walked; kind "lift" means riding the service lift between its two landings.
## This replaces an omniscient chase: the unit only ever plans towards a position it has perceived.

const NODES := {
	"gantry_far": Vector3(-10.8, 6.0, -7.5),
	"gantry_mid": Vector3(-5.0, 6.0, -7.5),
	"g_out": Vector3(-0.9, 6.0, -7.5),
	"g_in": Vector3(1.5, 6.0, -7.4),
	"f_door_w": Vector3(4.0, 6.0, -7.3),
	"f_mid": Vector3(6.0, 6.0, -6.6),
	"f_door_e": Vector3(9.6, 6.0, -6.6),
	"e_west": Vector3(11.5, 6.0, -6.2),
	"e_mid": Vector3(16.0, 6.0, -6.2),
	"e_east": Vector3(21.5, 6.0, -6.2),
	"walk_e": Vector3(21.5, 6.0, -3.6),
	"walk_w": Vector3(16.0, 6.0, -4.0),
	"s2_top": Vector3(13.0, 5.7, -3.4),
	"s2_bot": Vector3(8.3, 3.0, -3.2),
	"m_s2": Vector3(8.3, 3.0, -5.4),
	"m_a": Vector3(12.0, 3.0, -5.4),
	"m_b": Vector3(18.5, 3.0, -5.4),
	"m_c": Vector3(23.0, 3.0, -5.4),
	"m_n_w": Vector3(14.0, 3.0, -8.6),
	"m_n_e": Vector3(23.5, 3.0, -8.6),
	"lift_m": Vector3(26.0, 3.0, -5.6),
	"lift_p0": Vector3(26.0, 0.0, -0.9),
	"gal_w": Vector3(22.0, 0.0, -0.5),
	"gal_e": Vector3(29.1, 0.0, -1.0),
	"r1": Vector3(29.2, 0.0, 1.0),
	"ret_n": Vector3(29.0, 0.0, 2.7),
	"bridge": Vector3(29.0, 0.35, 6.0),
	"ret_s": Vector3(29.0, 0.0, 9.6),
	"south_e": Vector3(28.0, 0.0, 12.3),
	"s1_top": Vector3(25.0, 0.0, 12.3),
	"s1_mid": Vector3(25.0, -1.0, 9.5),
	"s1_bot": Vector3(25.0, -2.0, 7.2),
	"pit_e": Vector3(27.0, -2.0, 6.0),
	"pit_w": Vector3(15.0, -2.0, 6.0),
	"evac_w": Vector3(29.5, -2.0, 6.0),
	"evac_e": Vector3(33.2, -2.0, 6.0),
	"apron": Vector3(36.0, -2.0, 6.0),
}

const EDGES := [
	["gantry_far", "gantry_mid"], ["gantry_mid", "g_out"], ["g_out", "g_in"], ["g_in", "f_door_w"],
	["f_door_w", "f_mid"], ["f_mid", "f_door_e"], ["f_door_e", "e_west"], ["e_west", "e_mid"], ["e_mid", "e_east"],
	["e_mid", "walk_w"], ["e_east", "walk_e"], ["walk_w", "walk_e"], ["walk_w", "s2_top"], ["s2_top", "s2_bot"],
	["s2_bot", "m_s2"], ["m_s2", "m_a"], ["m_a", "m_b"], ["m_b", "m_c"], ["m_c", "lift_m"], ["m_a", "m_n_w"],
	["m_n_w", "m_n_e"], ["m_n_e", "m_c"], ["m_n_e", "lift_m"],
	["lift_m", "lift_p0", "lift"],
	["lift_p0", "gal_w"], ["lift_p0", "gal_e"], ["gal_e", "r1"], ["r1", "ret_n"], ["ret_n", "bridge"],
	["bridge", "ret_s"], ["ret_s", "south_e"], ["south_e", "s1_top"], ["s1_top", "s1_mid"], ["s1_mid", "s1_bot"],
	["s1_bot", "pit_e"], ["pit_e", "pit_w"], ["pit_e", "evac_w"], ["evac_w", "evac_e"], ["evac_e", "apron"],
]

## The Containment sweep: the order in which the protocol searches the building after G opens.
const SWEEP := ["gantry_far", "gantry_mid", "g_out", "g_in", "f_mid", "f_door_e", "e_west", "e_mid", "walk_w",
	"s2_top", "s2_bot", "m_s2", "m_a", "m_b", "m_c", "lift_m", "lift_p0", "gal_e", "r1", "ret_n", "bridge",
	"ret_s", "south_e", "s1_top", "s1_mid", "s1_bot", "pit_e", "evac_w", "evac_e"]

const LIFT_COST := 20.0

var _adj: Dictionary = {}


func _init() -> void:
	for n in NODES:
		_adj[n] = []
	for e in EDGES:
		var kind: String = e[2] if e.size() > 2 else "walk"
		(_adj[e[0]] as Array).append([e[1], kind])
		(_adj[e[1]] as Array).append([e[0], kind])


func pos(node: String) -> Vector3:
	return NODES[node]


func edge_kind(a: String, b: String) -> String:
	for link in _adj.get(a, []):
		if link[0] == b:
			return link[1]
	return ""


func neighbours(node: String) -> Array:
	var out: Array = []
	for link in _adj.get(node, []):
		out.append(link[0])
	return out


## Nearest node on the same level (|dy| < 1.3); `visible` (optional Callable(Vector3)->bool) filters candidates.
func nearest(p: Vector3, visible: Callable = Callable()) -> String:
	var best := ""
	var best_d := INF
	for n in NODES:
		var q: Vector3 = NODES[n]
		if absf(q.y - p.y) > 1.3:
			continue
		var d := Vector2(q.x - p.x, q.z - p.z).length()
		if d < best_d and (not visible.is_valid() or bool(visible.call(q))):
			best_d = d
			best = n
	if best == "":
		for n in NODES:
			var d := (NODES[n] as Vector3).distance_to(p)
			if d < best_d:
				best_d = d
				best = n
	return best


## Shortest path (Dijkstra over straight-line lengths). A lift ride costs 20 m: call, dwell and travel take ~5 s.
func path(from: String, to: String) -> Array:
	if from == to:
		return [from]
	var dist := {from: 0.0}
	var prev := {}
	var open: Array = [from]
	while not open.is_empty():
		var cur: String = open[0]
		for c in open:
			if float(dist[c]) < float(dist[cur]):
				cur = c
		open.erase(cur)
		if cur == to:
			break
		for link in _adj[cur]:
			var nb: String = link[0]
			var cost: float = LIFT_COST if link[1] == "lift" else (NODES[cur] as Vector3).distance_to(NODES[nb])
			var nd: float = float(dist[cur]) + cost
			if not dist.has(nb) or nd < float(dist[nb]):
				dist[nb] = nd
				prev[nb] = cur
				if not open.has(nb):
					open.append(nb)
	if not prev.has(to):
		return []
	var out: Array = [to]
	var c2: String = to
	while prev.has(c2):
		c2 = prev[c2]
		out.push_front(c2)
	return out


func route_length(nodes: Array) -> float:
	var total := 0.0
	for i in range(1, nodes.size()):
		total += LIFT_COST if edge_kind(nodes[i - 1], nodes[i]) == "lift" else (NODES[nodes[i - 1]] as Vector3).distance_to(NODES[nodes[i]])
	return total
