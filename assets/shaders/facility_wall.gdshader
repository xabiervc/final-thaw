shader_type spatial;
// Facility architecture surface WITHOUT the cutaway: no discard, so early depth rejection stays on (Intel GPUs).
#include "res://assets/shaders/facility_wall.gdshaderinc"
#include "res://assets/shaders/illustrated_light.gdshaderinc"
