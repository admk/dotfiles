// Original shader collected from: https://www.shadertoy.com/view/WsVSzV
// Licensed under Shadertoy's default since the original creator didn't provide any license. (CC BY NC SA 3.0)
// Slight modifications were made to give a green-ish effect.

float warp = 0.25; // simulate curvature of CRT monitor
float scan = 0.50; // simulate darkness between scanlines
float vignette = 0.2; // strength of vignette effect (0.0 to 1.0)

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // squared distance from center
    vec2 uv = fragCoord / iResolution.xy;
    vec2 dc = abs(0.5 - uv);
    dc *= dc;

    // warp the fragment coordinates
    uv.x -= 0.5; uv.x *= 1.0 + (dc.y * (0.3 * warp)); uv.x += 0.5;
    uv.y -= 0.5; uv.y *= 1.0 + (dc.x * (0.4 * warp)); uv.y += 0.5;

    // sample inside boundaries, otherwise set to black
    if (uv.y > 1.0 || uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0)
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    else
    {
        // determine if we are drawing in a scanline
        float apply = abs(sin(fragCoord.y) * 0.5 * scan);

        // sample the texture and apply a teal tint
        vec3 color = texture(iChannel0, uv).rgb;
        vec3 tealTint = vec3(0.85, 1.0, 0.95); // teal color (slightly more green than blue)

        // mix the sampled color with the teal tint based on scanline intensity
        vec3 finalColor = mix(color * tealTint, vec3(0.0), apply);

        // apply vignette effect (darken edges)
        vec2 centeredUv = uv * 2.0 - 1.0; // convert to -1 to 1 range
        float distFromCenter = length(centeredUv);
        float vignetteFactor = 1.0 - vignette * distFromCenter * distFromCenter;
        vignetteFactor = clamp(vignetteFactor, 0.0, 1.0);

        fragColor = vec4(finalColor * vignetteFactor, 1.0);
    }
}
