shader_type canvas_item;
// Shader to round corners of a canvas. The 'radius_scale' is multiplied by
// minimum(width, height)/2.0 to calculate the radius of the corners.
//
// Instructions:
// 1) The node that uses this shader must have signals 'tree_entered' and
// 'item_rect_changed' connected to a callable with the next code:
// material.set_shader_parameter("width", size.x)
// material.set_shader_parameter("height", size.y)
//
// Known issues:
// 1) If used on 'TextureRect', take care of 'expand_mode' and 'stretch_mode',
// because image corners might be outside node rectangle and therefore clipped.
// Corners are rounded, but they are outside node's rectangle.


uniform float radius_scale: hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float shadow_radius: hint_range(0.0, 1.0, 0.01) = 0.3;
uniform float shadow_feather: hint_range(0.0, 0.1, 0.001) = 0.05;

uniform bool rounded_corner_top_left = true;
uniform bool rounded_corner_top_right = true;
uniform bool rounded_corner_bottom_left = true;
uniform bool rounded_corner_bottom_right = true;
uniform float width = 1.0;
uniform float height = 1.0;
uniform float edge = 1.0;


uniform vec4 drop_shadow_color : source_color = vec4(vec3(0), float(0.5));
uniform vec2 shadow_offset = vec2(float(0), float(0.1));



void vertex() {
	float max_offset = abs(shadow_offset.x);
	if (abs(shadow_offset.y) > abs(shadow_offset.x)) {
		max_offset = abs(shadow_offset.y);
	}
	VERTEX *= float(1) + float(2) * max_offset;
	}

vec4 sample_texture(sampler2D texture, vec2 uv)  {
	if ((uv.x < 0.0 || uv.x > 1.0) || (uv.y < 0.0 || uv.y > 1.0))  {
		return vec4(0.0);
	} else {
		return texture(texture, uv);
	}
}

vec4 mixcolor(vec4 colA, vec4 colB)  {
	return vec4((colA.rgb + colB.a * (colB.rgb - colA.rgb)), colA.a + colB.a);
}

void fragment() {
vec2 pos = vec2(UV.x * width, UV.y * height);
	float radius = min(width, height) * radius_scale / 2.0;

	// === Corrected corner positions (account for edge)
	vec2 top_left_center = vec2(edge + radius, edge + radius);
	vec2 top_right_center = vec2(width - edge - radius, edge + radius);
	vec2 bottom_left_center = vec2(edge + radius, height - edge - radius);
	vec2 bottom_right_center = vec2(width - edge - radius, height - edge - radius);

	// === Shape mask (sharp)
	float shape_alpha = 1.0;

	if (rounded_corner_top_left && pos.x < top_left_center.x && pos.y < top_left_center.y) {
		float dist = length(pos - top_left_center);
		shape_alpha *= step(dist, radius);
	}
	if (rounded_corner_top_right && pos.x > top_right_center.x && pos.y < top_right_center.y) {
		float dist = length(pos - top_right_center);
		shape_alpha *= step(dist, radius);
	}
	if (rounded_corner_bottom_left && pos.x < bottom_left_center.x && pos.y > bottom_left_center.y) {
		float dist = length(pos - bottom_left_center);
		shape_alpha *= step(dist, radius);
	}
	if (rounded_corner_bottom_right && pos.x > bottom_right_center.x && pos.y > bottom_right_center.y) {
		float dist = length(pos - bottom_right_center);
		shape_alpha *= step(dist, radius);
	}

	// Edge clipping
	if (pos.x < edge || pos.x > width - edge || pos.y < edge || pos.y > height - edge) {
		shape_alpha = 0.0;
	}

	// === Main texture (masked)
	vec4 tex_color = texture(TEXTURE, UV);
	tex_color.a *= shape_alpha;

	// === Shadow (blurred mask, expanded with shadow_radius) ===
	const int samples = 16;
	float shadow_sum = 0.0;
	float total_weight = 0.0;

	float blur_radius = shadow_feather;
	float shadow_expand = shadow_radius;

	for (int i = 0; i < samples; i++) {
		float angle = float(i) / float(samples) * 6.28318;
		vec2 offset = vec2(cos(angle), sin(angle)) * blur_radius;
		vec2 sample_uv = UV - shadow_offset + offset;
		vec2 sample_pos = sample_uv * vec2(width, height);

		float sample_alpha = 1.0;

		// Edge clip
		if (sample_pos.x < edge || sample_pos.x > width - edge || sample_pos.y < edge || sample_pos.y > height - edge) {
			sample_alpha = 0.0;
		}

		// Apply expanded corner masking for shadow
		if (rounded_corner_top_left && sample_pos.x < top_left_center.x + shadow_expand && sample_pos.y < top_left_center.y + shadow_expand) {
			float dist = length(sample_pos - top_left_center);
			sample_alpha *= step(dist, radius + shadow_expand);
		}
		if (rounded_corner_top_right && sample_pos.x > top_right_center.x - shadow_expand && sample_pos.y < top_right_center.y + shadow_expand) {
			float dist = length(sample_pos - top_right_center);
			sample_alpha *= step(dist, radius + shadow_expand);
		}
		if (rounded_corner_bottom_left && sample_pos.x < bottom_left_center.x + shadow_expand && sample_pos.y > bottom_left_center.y - shadow_expand) {
			float dist = length(sample_pos - bottom_left_center);
			sample_alpha *= step(dist, radius + shadow_expand);
		}
		if (rounded_corner_bottom_right && sample_pos.x > bottom_right_center.x - shadow_expand && sample_pos.y > bottom_right_center.y - shadow_expand) {
			float dist = length(sample_pos - bottom_right_center);
			sample_alpha *= step(dist, radius + shadow_expand);
		}

		shadow_sum += sample_alpha;
		total_weight += 1.0;
	}

	float blurred_shadow_alpha = (shadow_sum / total_weight) * drop_shadow_color.a;
	vec4 shadow = vec4(drop_shadow_color.rgb, blurred_shadow_alpha);

	// === Composite: shadow behind texture
	COLOR = mix(shadow, tex_color, tex_color.a);}
