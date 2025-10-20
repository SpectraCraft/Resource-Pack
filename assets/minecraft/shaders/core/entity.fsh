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
    vec4 color = texture(Sampler0, texCoord0);

    #ifdef ALPHA_CUTOUT
        if (color.a < ALPHA_CUTOUT) {
            discard;
        }
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

    // Aplicar niebla al color base
        fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);

    // Obtener opacidad 255
        float opacity = ceil(color.a * 255.0);

    // Efectos

        // Hacer que los píxeles con opacidad de 254 sean brillantes
            if (opacity == 254) {
                fragColor = apply_fog(texture(Sampler0, texCoord0), sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
            }

        // Si es 253 entonces aplicar pulso
            if (opacity == 253) {

            // Aplicar el pulso con desfase
            float animationTime = GameTime * 1000.0;
            float pulse = 0.5 + 0.5 * sin(animationTime * 2.0);

            // Aplicar el efecto de brillo pulsante
            vec4 animatedFade = mix(fragColor, texture(Sampler0, texCoord0), pow(pulse, 1));
            fragColor = animatedFade;

            }
}
