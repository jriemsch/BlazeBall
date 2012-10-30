xof 0303txt 0032
template Frame {
 <3d82ab46-62da-11cf-ab39-0020af71e433>
 [...]
}

template Matrix4x4 {
 <f6f23f45-7686-11cf-8f52-0040333594a3>
 array FLOAT matrix[16];
}

template FrameTransformMatrix {
 <f6f23f41-7686-11cf-8f52-0040333594a3>
 Matrix4x4 frameMatrix;
}

template Vector {
 <3d82ab5e-62da-11cf-ab39-0020af71e433>
 FLOAT x;
 FLOAT y;
 FLOAT z;
}

template MeshFace {
 <3d82ab5f-62da-11cf-ab39-0020af71e433>
 DWORD nFaceVertexIndices;
 array DWORD faceVertexIndices[nFaceVertexIndices];
}

template Mesh {
 <3d82ab44-62da-11cf-ab39-0020af71e433>
 DWORD nVertices;
 array Vector vertices[nVertices];
 DWORD nFaces;
 array MeshFace faces[nFaces];
 [...]
}

template MeshNormals {
 <f6f23f43-7686-11cf-8f52-0040333594a3>
 DWORD nNormals;
 array Vector normals[nNormals];
 DWORD nFaceNormals;
 array MeshFace faceNormals[nFaceNormals];
}

template Coords2d {
 <f6f23f44-7686-11cf-8f52-0040333594a3>
 FLOAT u;
 FLOAT v;
}

template MeshTextureCoords {
 <f6f23f40-7686-11cf-8f52-0040333594a3>
 DWORD nTextureCoords;
 array Coords2d textureCoords[nTextureCoords];
}

template ColorRGBA {
 <35ff44e0-6c7c-11cf-8f52-0040333594a3>
 FLOAT red;
 FLOAT green;
 FLOAT blue;
 FLOAT alpha;
}

template ColorRGB {
 <d3e16e81-7835-11cf-8f52-0040333594a3>
 FLOAT red;
 FLOAT green;
 FLOAT blue;
}

template Material {
 <3d82ab4d-62da-11cf-ab39-0020af71e433>
 ColorRGBA faceColor;
 FLOAT power;
 ColorRGB specularColor;
 ColorRGB emissiveColor;
 [...]
}

template MeshMaterialList {
 <f6f23f42-7686-11cf-8f52-0040333594a3>
 DWORD nMaterials;
 DWORD nFaceIndexes;
 array DWORD faceIndexes[nFaceIndexes];
 [Material <3d82ab4d-62da-11cf-ab39-0020af71e433>]
}

template TextureFilename {
 <a42790e1-7810-11cf-8f52-0040333594a3>
 STRING filename;
}


Frame Scene_Root {
 

 Frame lane {
  

  FrameTransformMatrix {
   1.000000,0.000000,0.000000,0.000000,0.000000,1.000000,0.000000,0.000000,0.000000,0.000000,1.000000,0.000000,0.000000,0.000000,0.000000,1.000000;;
  }

  Mesh lane_obj {
   12;
   -5.000000;0.000000;-8.000000;,
   -5.000000;0.000000;-4.000000;,
   5.000000;0.000000;-4.000000;,
   -5.000000;0.000000;-8.000000;,
   5.000000;0.000000;-4.000000;,
   5.000000;0.000000;-8.000000;,
   5.000000;0.000000;-4.000000;,
   -5.000000;0.000000;-4.000000;,
   -5.000000;0.000000;0.000000;,
   5.000000;0.000000;-4.000000;,
   -5.000000;0.000000;0.000000;,
   5.000000;0.000000;0.000000;;
   4;
   3;0,1,2;,
   3;3,4,5;,
   3;6,7,8;,
   3;9,10,11;;

   MeshNormals {
    12;
    0.000000;1.000000;0.000000;,
    0.000000;1.000000;0.000000;,
    0.000000;1.000000;0.000000;,
    0.000000;1.000000;0.000000;,
    0.000000;1.000000;0.000000;,
    0.000000;1.000000;0.000000;,
    0.000000;1.000000;0.000000;,
    0.000000;1.000000;0.000000;,
    0.000000;1.000000;0.000000;,
    0.000000;1.000000;0.000000;,
    0.000000;1.000000;0.000000;,
    0.000000;1.000000;0.000000;;
    4;
    3;0,1,2;,
    3;3,4,5;,
    3;6,7,8;,
    3;9,10,11;;
   }

   MeshTextureCoords {
    12;
    -0.528137;-0.724463;,
    -0.528137;-0.532810;,
    -0.719790;-0.532810;,
    -0.528137;-0.724463;,
    -0.719790;-0.532810;,
    -0.719790;-0.724463;,
    -0.227223;-0.712236;,
    -0.035570;-0.712236;,
    -0.035570;-0.712236;,
    -0.227223;-0.712236;,
    -0.035570;-0.712236;,
    -0.227223;-0.712236;;
   }

   MeshMaterialList {
    1;
    4;
    0,
    0,
    0,
    0;

    Material DefaultLib_Material {
     0.700000;0.700000;0.700000;1.000000;;
     50.000000;
     1.000000;1.000000;1.000000;;
     0.000000;0.000000;0.000000;;

     TextureFilename {
      "lane.png";
     }
    }
   }
  }
 }

 Frame endTransform {
  

  FrameTransformMatrix {
   1.000000,0.000000,0.000000,0.000000,0.000000,1.000000,0.000000,0.000000,0.000000,0.000000,1.000000,0.000000,0.000000,0.000000,-8.000000,1.000000;;
  }

  Mesh endTransform_obj {
   6;
   -5.000000;0.500000;0.000000;,
   -5.000000;-0.500000;0.000000;,
   5.000000;-0.500000;0.000000;,
   -5.000000;0.500000;0.000000;,
   5.000000;-0.500000;0.000000;,
   5.000000;0.500000;0.000000;;
   2;
   3;0,1,2;,
   3;3,4,5;;

   MeshNormals {
    6;
    0.000000;0.000000;1.000000;,
    0.000000;0.000000;1.000000;,
    0.000000;0.000000;1.000000;,
    0.000000;0.000000;1.000000;,
    0.000000;0.000000;1.000000;,
    0.000000;0.000000;1.000000;;
    2;
    3;0,1,2;,
    3;3,4,5;;
   }

   MeshTextureCoords {
    6;
    -0.004090;-0.099200;,
    -0.004090;-0.004315;,
    -0.952941;-0.004315;,
    -0.004090;-0.099200;,
    -0.952941;-0.004315;,
    -0.952941;-0.099200;;
   }

   MeshMaterialList {
    1;
    2;
    0,
    0;

    Material DefaultLib_Material1 {
     0.700000;0.700000;0.700000;1.000000;;
     50.000000;
     1.000000;1.000000;1.000000;;
     0.000000;0.000000;0.000000;;

     TextureFilename {
      "noIcon.pic";
     }
    }
   }
  }
 }
}