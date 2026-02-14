// Original shader collected from: https://www.shadertoy.com/view/WsVSzV
// Licensed under Shadertoy's default since the original creator didn't provide any license. (CC BY NC SA 3.0)
// Slight modifications were made to give a green-ish effect.

float warp = 0.20; // simulate curvature of CRT monitor
float scan = 0.50; // simulate darkness between scanlines
float vignette = 1.0; // strength of vignette effect (0.0 to 1.0)
float vignetteInner = 0.85; // fraction of center-to-corner radius with no vignette (0.0 to 1.0)
float vignetteSoftness = 0.30; // fraction of center-to-corner radius for transition (smaller = sharper)
float edgeSoftness = 0.015; // border fade width in UV units (smaller = sharper)
float edgeCornerRadius = 0.04; // rounded corner radius (fraction of screen half-min)

vec2 warpUv(vec2 uv, vec2 dc)
{
    uv.x -= 0.5; uv.x *= 1.0 + (dc.y * (0.3 * warp)); uv.x += 0.5;
    uv.y -= 0.5; uv.y *= 1.0 + (dc.x * (0.4 * warp)); uv.y += 0.5;
    return uv;
}

float scanlineMask(float y)
{
    return abs(sin(y) * 0.1 * scan);
}

vec3 applyTint(vec3 color, float apply)
{
    // teal color (slightly more green than blue)
    vec3 tealTint = vec3(0.96, 1.0, 0.99);
    return mix(color * tealTint, vec3(0.0), apply);
}

float vignetteMask(vec2 uv)
{
    vec2 centeredUv = uv * 2.0 - 1.0; // convert to -1 to 1 range
    float aspect = iResolution.x / iResolution.y;
    centeredUv.x *= aspect; // aspect-correct so vignette is round in screen space
    float distFromCenter = length(centeredUv);
    float maxDist = length(vec2(aspect, 1.0)); // center to corner distance
    float innerRadius = vignetteInner * maxDist;
    float softRadius = vignetteSoftness * maxDist;
    return smoothstep(innerRadius, innerRadius + softRadius, distFromCenter);
}

float edgeMask(vec2 uv)
{
    vec2 p = uv * 2.0 - 1.0;
    float aspect = iResolution.x / iResolution.y;
    p.x *= aspect;
    vec2 halfSize = vec2(aspect, 1.0);
    float r = edgeCornerRadius * min(halfSize.x, halfSize.y);
    vec2 q = abs(p) - (halfSize - vec2(r));
    float dist = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
    float soften = max(edgeSoftness * min(halfSize.x, halfSize.y), 0.0001);
    return 1.0 - smoothstep(-soften, 0.0, dist);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // squared distance from center
    vec2 uv = fragCoord / iResolution.xy;
    vec2 dc = abs(0.5 - uv);
    dc *= dc;

    // warp the fragment coordinates
    uv = warpUv(uv, dc);

    // sample inside boundaries, otherwise set to black
    if (uv.y > 1.0 || uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0)
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    else
    {
        // determine if we are drawing in a scanline
        float apply = scanlineMask(fragCoord.y);

        // sample the texture and apply a teal tint
        vec3 color = texture(iChannel0, uv).rgb;
        vec3 finalColor = applyTint(color, apply);

        // apply vignette effect (darken edges)
        float vignetteFactor = 1.0 - vignette * vignetteMask(uv);
        vignetteFactor = clamp(vignetteFactor, 0.0, 1.0);

        float borderMask = edgeMask(uv);

        fragColor = vec4(finalColor * vignetteFactor * borderMask, 1.0);
    }
}
