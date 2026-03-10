float hash11(float p) {
    return fract(sin(p * 127.1) * 43758.5453123);
}

float hash21(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float rectFill(vec2 p, vec2 halfSize) {
    vec2 d = abs(p) - halfSize;
    return 1.0 - step(0.0, max(d.x, d.y));
}

float rectStroke(vec2 p, vec2 halfSize, float thickness) {
    float outer = rectFill(p, halfSize);
    float inner = rectFill(p, halfSize - vec2(thickness));
    return max(outer - inner, 0.0);
}

float digitZero(vec2 p) {
    return rectStroke(p, vec2(0.18, 0.34), 0.06);
}

float digitOne(vec2 p) {
    float stem = rectFill(p + vec2(0.00, -0.02), vec2(0.045, 0.32));
    float cap = rectFill(p + vec2(0.00, 0.26), vec2(0.11, 0.04));
    return max(stem, cap);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 px = 1.0 / iResolution.xy;

    vec4 base = texture(iChannel0, uv);
    vec3 col = base.rgb;
    vec3 phosphor = vec3(0.36, 1.00, 0.32);
    float luma = dot(col, vec3(0.2126, 0.7152, 0.0722));

    float scan = 0.96 + 0.04 * sin(fragCoord.y * 2.2 + iTime * 9.0);
    float mask = 0.985 + 0.015 * sin(fragCoord.x * 1.8);
    float dist = distance(uv, vec2(0.5));
    float vignette = 1.0 - smoothstep(0.30, 0.82, dist) * 0.28;
    float bright = max(col.r, max(col.g, col.b));
    float sweepPos = fract(iTime * 0.07);
    float sweep = exp(-85.0 * abs(uv.y - sweepPos));
    float flicker = 0.992 + 0.008 * sin(iTime * 28.0);
    vec3 ghost = texture(iChannel0, uv + vec2(0.0, px.y * 2.0)).rgb * phosphor * 0.035;
    float darkness = 1.0 - smoothstep(0.06, 0.42, bright);

    // Faint procedural 0/1 rain that only shows up in darker background areas.
    vec2 grid = vec2(34.0, 42.0);
    vec2 cell = floor(uv * grid);
    vec2 local = fract(uv * grid) - 0.5;
    local.x *= 0.92;

    float columnSeed = hash11(cell.x + 19.0);
    float activeColumn = step(0.34, columnSeed);
    float speed = mix(0.25, 0.85, hash11(cell.x + 83.0));
    float offset = hash11(cell.x + 151.0) * grid.y;
    float stream = mod((grid.y - cell.y) + iTime * speed * grid.y + offset, grid.y);
    float trail = smoothstep(18.0, 0.0, stream) * activeColumn;
    float head = smoothstep(2.0, 0.0, stream) * activeColumn;
    float bit = step(0.5, hash21(vec2(cell.x, floor(cell.y + iTime * speed * 4.0))));
    float glyph = mix(digitZero(local), digitOne(local), bit);
    vec3 rain = phosphor * glyph * trail * darkness * 0.07;
    rain += vec3(0.82, 1.0, 0.82) * glyph * head * darkness * 0.05;

    col = mix(col, phosphor * luma, 0.30);

    vec3 tint = phosphor * smoothstep(0.08, 1.0, bright) * 0.04;
    vec3 sweepTint = phosphor * sweep * 0.08;
    vec3 bloom = phosphor * bright * 0.07;

    fragColor = vec4(col * scan * mask * vignette * flicker + tint + sweepTint + bloom + ghost + rain, base.a);
}
