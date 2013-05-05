varying vec3 normal;
varying vec4 pos;
varying vec4 rawpos;
varying vec4 vertexColor;

uniform vec4 custom_uv;
uniform vec2 custom_size;

void main() {
	normal = gl_NormalMatrix * gl_Normal;
	gl_Position = ftransform();
	pos = gl_ModelViewMatrix * gl_Vertex;
	rawpos = gl_Vertex;
    vertexColor = gl_Color;
  
    gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;

    vec4 texCoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    if(texCoord.x == 0.0)
    {
    	texCoord.x = custom_uv.x;
    }
    else //if(texCoord.x = 0.0)
    {
        texCoord.x = custom_uv.z;
    }
   	
   	if(texCoord.y == 0.0)
    {
    	texCoord.y = custom_uv.y;
    }
    else 
    {
    	texCoord.y = custom_uv.w;
    }

	gl_TexCoord[0] = texCoord;
}
