shader_type sky;
render_mode disable_fog;

float card(vec3 d, vec3 n, vec3 right, float w, float h) {
	float forward = max(dot(d,n),0.0001);
	vec3 up = normalize(cross(n,right));
	vec2 uv = vec2(dot(d,right),dot(d,up))/forward;
	vec2 edge = (1.0-smoothstep(vec2(w*0.85,h*0.85),vec2(w,h),abs(uv)));
	return edge.x*edge.y*step(0.0,dot(d,n));
}

void sky() {
	vec3 d = normalize(EYEDIR);
	float horizon = exp(-abs(d.y)*3.5);
	vec3 base = mix(vec3(0.025,0.03,0.037),vec3(0.21,0.23,0.25),horizon);
	float key = card(d,normalize(vec3(-0.7,0.8,-0.4)),normalize(vec3(0.50,0.0,-0.86)),0.75,0.18);
	float strip = card(d,normalize(vec3(0.8,0.6,0.2)),normalize(vec3(0.24,0.0,-0.97)),0.85,0.10);
	float rear = card(d,normalize(vec3(-0.1,0.55,0.9)),vec3(1.0,0.0,0.0),0.55,0.26);
	COLOR = base + vec3(1.8,1.75,1.65)*key + vec3(1.3,1.4,1.5)*strip + vec3(0.8)*rear;
}
