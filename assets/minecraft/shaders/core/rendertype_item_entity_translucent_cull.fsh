#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:globals.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;

out vec4 fragColor;

void main() {

    // Declarar valores
        vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator; // Normal
        vec4 emissiveColor = texture(Sampler0, texCoord0); // Emisividad

    // Descartar si tiene menos de 10%
        if (color.a < 0.1) {
            discard;
        }

    // Aplicar el fog
        fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);

    // Obtener la opacidad en 255
        float opacity = ceil(color.a * 255);

    // Efectos

        // Shiny Effect
        if(opacity == 254) {
                fragColor = apply_fog(emissiveColor, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
            }

        // Pulso
        if (opacity == 253) {
            float animationTime = GameTime * 1000.0;
            float pulse = 0.5 + 0.5 * sin(animationTime *8.0); // Aumentamos la frecuencia a 5.0
            vec4 animatedFade = mix(fragColor, emissiveColor, pow(pulse, 2));
            fragColor = animatedFade;
        }

}
