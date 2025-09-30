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
	

	
	vec4 image = texture(TEXTURE, UV);
	vec2 pos = vec2(UV.x*width, UV.y*height);
	float radius = min(width, height)*radius_scale/2.0+edge;
	float dist;
	// Top left corner
	if (rounded_corner_top_left) {
		dist = length(pos - vec2(radius))+edge;
		if (dist > radius && pos.x < radius && pos.y < radius) {
			image.a = 0.0;
		}
		// debugging only
//		if (dist < radius){image.r = 1.0;}
	}
	// Top right corner
	if (rounded_corner_top_right) {
		dist = length(pos - vec2(width-radius, radius))+edge;
		if (dist > radius && pos.x > width-radius && pos.y < radius) {
			image.a = 0.0;
		}
		// debugging only
//		if (dist < radius){image.r = 1.0;}
	}
	// Bottom left corner
	if (rounded_corner_bottom_left) {
		dist = length(pos - vec2(radius, height-radius))+edge;
		if (dist > radius && pos.x < radius && pos.y > height-radius) {
			image.a = 0.0;
		}
		// debugging only
//		if (dist < radius){image.r = 1.0;}
	}
	// Bottom right corner
	if (rounded_corner_bottom_right) {
		dist = length(pos - vec2(width-radius, height-radius))+edge;
		if (dist > radius && pos.x > width-radius && pos.y > height-radius) {
			image.a = 0.0;
		}
		// debugging only
//		if (dist < radius){image.r = 1.0;}
	}
	if (pos.x <edge || pos.x > width-edge || pos.y < edge || pos.y > height-edge){
		image.a = 0.0;
	}
	COLOR = image;
	
		float max_offset = abs(shadow_offset.x);
	if (abs(shadow_offset.y) > abs(shadow_offset.x)) {
		max_offset = abs(shadow_offset.y);
	}
	vec2 uv = UV * float(float(1) + float(2) * max_offset) - vec2(max_offset);
	vec4 original_color = sample_texture(TEXTURE, uv);
	vec4 shadow_color = vec4(drop_shadow_color.rgb, sample_texture(TEXTURE, uv - shadow_offset).a * drop_shadow_color.a);
	if (shadow_color.a > float(0)) {
		COLOR = mixcolor(shadow_color, image);
	} else {
		COLOR = image;
	}
}
