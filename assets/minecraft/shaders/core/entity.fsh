#version 330
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:globals.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
#ifdef PER_FACE_LIGHTING
in vec4 vertexPerFaceColorBack;
in vec4 vertexPerFaceColorFront;
#else
in vec4 vertexColor;
#endif
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;

out vec4 fragColor;

void main() {
    // --- 1) Exact, unfiltered alpha for classification (mip 0, no bilinear) ---
    ivec2 sz    = textureSize(Sampler0, 0);
    ivec2 texel = ivec2(clamp(floor(texCoord0 * vec2(sz)),
                              vec2(0.0), vec2(sz) - vec2(1.0)));
    vec4 baseTexExact = texelFetch(Sampler0, texel, 0);
    int opacity = int(floor(baseTexExact.a * 255.0 + 0.5));  // 0..255

    // --- 2) If NOT 253/254, render normal immediately and return ---
    if (opacity != 253 && opacity != 254) {
        // normal pipeline (use filtered sample for regular look)
        vec4 color = texture(Sampler0, texCoord0);

        #ifdef ALPHA_CUTOUT
            if (color.a < ALPHA_CUTOUT) discard;
        #endif

        #ifdef PER_FACE_LIGHTING
            color *= (gl_FrontFacing ? vertexPerFaceColorFront : vertexPerFaceColorBack) * ColorModulator;
        #else
            color *= vertexColor * ColorModulator;
        #endif

        #ifndef NO_OVERLAY
            color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
        #endif

        #ifndef EMISSIVE
            color *= lightMapColor;
        #endif

        fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance,
                              FogEnvironmentalStart, FogEnvironmentalEnd,
                              FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
        return;
    }

    // --- 3) Glow paths (only for 253/254) ---
    // Precompute both fogged variants once
    vec4 filtered = texture(Sampler0, texCoord0);
    #ifdef ALPHA_CUTOUT
        if (filtered.a < ALPHA_CUTOUT) discard;
    #endif

    #ifdef PER_FACE_LIGHTING
        filtered *= (gl_FrontFacing ? vertexPerFaceColorFront : vertexPerFaceColorBack) * ColorModulator;
    #else
        filtered *= vertexColor * ColorModulator;
    #endif

    #ifndef NO_OVERLAY
        filtered.rgb = mix(overlayColor.rgb, filtered.rgb, overlayColor.a);
    #endif

    #ifndef EMISSIVE
        filtered *= lightMapColor;
    #endif

    vec4 normalOut  = apply_fog(filtered,       sphericalVertexDistance, cylindricalVertexDistance,
                                FogEnvironmentalStart, FogEnvironmentalEnd,
                                FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
    vec4 rawUnderFog = apply_fog(baseTexExact,  sphericalVertexDistance, cylindricalVertexDistance,
                                 FogEnvironmentalStart, FogEnvironmentalEnd,
                                 FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);

    if (opacity == 254) {
        // steady glow
        fragColor = rawUnderFog;
        return;
    } else { // opacity == 253
        // pulsing glow
        float t = GameTime * 1000.0;
        float pulse = 0.5 + 0.5 * sin(t * 2.0);
        fragColor = mix(normalOut, rawUnderFog, pulse);
        return;
    }
}
