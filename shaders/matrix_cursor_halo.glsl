float ring(vec2 p, float radius, float width) {
    return smoothstep(width, 0.0, abs(length(p) - radius));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 base = texture(iChannel0, uv);

    vec2 cursorCenter = vec2(
        iCurrentCursor.x + iCurrentCursor.z * 0.5,
        iCurrentCursor.y - iCurrentCursor.w * 0.5
    );

    float sinceMove = iTime - iTimeCursorChange;
    vec2 delta = fragCoord - cursorCenter;
    vec2 halfSize = max(iCurrentCursor.zw * 0.5, vec2(4.0, 9.0));
    vec2 boxDelta = abs(delta) - halfSize;
    float boxDistance = length(max(boxDelta, 0.0));
    float halo = exp(-boxDistance * 0.18) * (0.16 + 0.10 * sin(iTime * 3.4));
    float pulse = ring(delta, sinceMove * 150.0, 5.0) * smoothstep(0.45, 0.0, sinceMove);
    vec3 pulseColor = mix(vec3(0.40, 1.0, 0.40), iCurrentCursorColor.rgb, 0.5);

    fragColor = vec4(base.rgb + pulseColor * halo * 0.22 + pulseColor * pulse * 0.30, base.a);
}
