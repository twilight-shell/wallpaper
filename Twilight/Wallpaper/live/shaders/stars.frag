#version 440

// Live wallpaper: glowing stars made of round LED dots on a dark sky, in
// the style of Y2K LED walls. Stars are scattered over a jittered grid,
// drift slowly, twinkle and come filled, outlined or as a star inside a
// star. The LEDs are lit by the star under them; a soft glow spreads
// between the dots.

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    float dotSize;
    float cellSize;
    float glow;
    vec2 resolution;
    vec4 background;
    vec4 colorA;
    vec4 colorB;
    vec4 colorC;
};

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

vec2 rotate(vec2 p, float a) {
    float c = cos(a);
    float s = sin(a);
    return vec2(c * p.x - s * p.y, s * p.x + c * p.y);
}

// Signed distance to a five-pointed star of outer radius r; rf sets how
// deep the points are cut (Inigo Quilez).
float sdStar5(vec2 p, float r, float rf) {
    const vec2 k1 = vec2(0.809016994375, -0.587785252292);
    const vec2 k2 = vec2(-k1.x, k1.y);
    p.x = abs(p.x);
    p -= 2.0 * max(dot(k1, p), 0.0) * k1;
    p -= 2.0 * max(dot(k2, p), 0.0) * k2;
    p.x = abs(p.x);
    p.y -= r;
    vec2 ba = rf * vec2(-k1.y, k1.x) - vec2(0.0, 1.0);
    float h = clamp(dot(p, ba) / dot(ba, ba), 0.0, r);
    return length(p - ba * h) * sign(p.y * ba.x - p.x * ba.y);
}

// How lit a point is by the stars around it, and which color lights it.
// Returns (light, glow) and writes the star color.
vec2 stars(vec2 pos, out vec3 color) {
    vec2 cell = floor(pos / cellSize);
    float bestLight = 0.0;
    float glow = 0.0;
    color = colorA.rgb;

    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 c = cell + vec2(x, y);
            float h1 = hash(c);
            float h2 = hash(c + 17.1);
            float h3 = hash(c + 41.7);
            float h4 = hash(c + 83.3);

            // Some cells stay empty, the rest hold one star of varying size.
            if (h4 < 0.12)
                continue;

            vec2 center = (c + 0.2 + 0.6 * vec2(h1, h2)) * cellSize;
            float radius = cellSize * mix(0.22, 0.62, h3 * h3);
            float angle = (h1 - 0.5) * 0.9 + sin(time * 0.15 + h2 * 6.28) * 0.08;
            vec2 p = rotate(pos - center, angle);
            p.y = -p.y;

            float d = sdStar5(p, radius, 0.48);
            float edge = dotSize * 0.6;
            float width = dotSize * mix(1.2, 2.2, h2);

            float shape;
            if (h4 < 0.45) {
                // Filled, brightest at the heart.
                shape = smoothstep(edge, -edge, d) * mix(0.75, 1.0, smoothstep(0.0, -radius * 0.5, d));
            } else if (h4 < 0.75) {
                // Outline.
                shape = smoothstep(width, width - edge, abs(d + width));
            } else {
                // Outline with a smaller star inside.
                float outer = smoothstep(width, width - edge, abs(d + width));
                float inner = smoothstep(width, width - edge, abs(d + radius * 0.42));
                shape = max(outer, inner);
            }

            float twinkle = 0.7 + 0.3 * sin(time * mix(0.6, 1.8, h3) + h1 * 6.28);
            float light = shape * twinkle;

            glow += exp(-max(d, 0.0) / (radius * 0.35)) * 0.35 * twinkle * smoothstep(-edge, edge, d)
                  + smoothstep(edge, -edge, d) * 0.15;

            if (light > bestLight) {
                bestLight = light;
                color = h2 < 0.45 ? colorA.rgb : (h2 < 0.8 ? colorC.rgb : colorB.rgb);
            }
        }
    }
    return vec2(bestLight, clamp(glow, 0.0, 1.0));
}

void main() {
    vec2 frag = qt_TexCoord0 * resolution;
    // The whole sky drifts slowly up and to the left.
    vec2 pos = frag + vec2(time * 6.0, time * 3.5);

    // Each LED takes the light at its own center, so it lights up evenly.
    vec2 ledCenter = (floor(pos / dotSize) + 0.5) * dotSize;
    vec3 starColor;
    vec2 lit = stars(ledCenter, starColor);

    vec3 glowColor;
    vec2 haze = stars(pos, glowColor);

    // Round LED dots.
    vec2 g = fract(pos / dotSize) - 0.5;
    float led = smoothstep(0.42, 0.28, length(g));

    vec3 sky = background.rgb;
    // Vignette towards the corners.
    vec2 uv = qt_TexCoord0 - 0.5;
    sky *= 1.0 - dot(uv, uv) * 0.9;

    vec3 col = sky + glowColor * haze.y * glow;
    // Lit LEDs run hot towards white at full light.
    vec3 ledColor = mix(starColor, vec3(1.0), lit.x * 0.55) * lit.x;
    col += ledColor * led * 1.15;
    // Faint unlit LEDs everywhere, the bare wall.
    col += starColor * led * 0.035;

    fragColor = vec4(col, 1.0) * qt_Opacity;
}
