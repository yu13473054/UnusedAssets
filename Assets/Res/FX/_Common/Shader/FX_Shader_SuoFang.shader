// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:32719,y:32712,varname:node_3138,prsc:2|emission-3915-OUT,alpha-283-OUT;n:type:ShaderForge.SFN_TexCoord,id:5212,x:30517,y:32590,varname:node_5212,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Tex2d,id:3288,x:31593,y:32711,ptovrint:False,ptlb:1,ptin:_1,varname:node_3288,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-1927-OUT;n:type:ShaderForge.SFN_ArcTan2,id:9835,x:31064,y:32614,varname:node_9835,prsc:2,attp:3|A-2329-R,B-2329-G;n:type:ShaderForge.SFN_RemapRange,id:7057,x:30705,y:32590,varname:node_7057,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:1|IN-5212-UVOUT;n:type:ShaderForge.SFN_ComponentMask,id:2329,x:30872,y:32590,varname:node_2329,prsc:2,cc1:0,cc2:1,cc3:-1,cc4:-1|IN-7057-OUT;n:type:ShaderForge.SFN_Length,id:4413,x:31064,y:32492,varname:node_4413,prsc:2|IN-2329-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2814,x:30872,y:32397,ptovrint:False,ptlb:node_2814,ptin:_node_2814,varname:node_2814,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Append,id:1927,x:31446,y:32521,varname:node_1927,prsc:2|A-9821-OUT,B-4011-OUT;n:type:ShaderForge.SFN_Add,id:9821,x:31337,y:32379,varname:node_9821,prsc:2|A-2838-OUT,B-4413-OUT;n:type:ShaderForge.SFN_Time,id:6514,x:30872,y:32446,varname:node_6514,prsc:2;n:type:ShaderForge.SFN_Multiply,id:2838,x:31064,y:32378,varname:node_2838,prsc:2|A-2814-OUT,B-6514-T;n:type:ShaderForge.SFN_SwitchProperty,id:4676,x:31869,y:32868,ptovrint:False,ptlb:1_RGB/A,ptin:_1_RGBA,varname:node_4676,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-3288-R,B-3288-A;n:type:ShaderForge.SFN_Add,id:4011,x:31272,y:32614,varname:node_4011,prsc:2|A-9835-OUT,B-7038-OUT;n:type:ShaderForge.SFN_ValueProperty,id:4769,x:30872,y:32835,ptovrint:False,ptlb:node_4769,ptin:_node_4769,varname:node_4769,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:7038,x:31175,y:32787,varname:node_7038,prsc:2|A-6514-T,B-4769-OUT;n:type:ShaderForge.SFN_Multiply,id:8286,x:32143,y:33035,varname:node_8286,prsc:2|A-4676-OUT,B-6713-OUT;n:type:ShaderForge.SFN_Tex2d,id:4996,x:31194,y:33082,ptovrint:False,ptlb:2_RGB/A,ptin:_2_RGBA,varname:node_4996,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_SwitchProperty,id:6713,x:31509,y:33125,ptovrint:False,ptlb:2_rgb/a,ptin:_2_rgba,varname:node_6713,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-4996-R,B-4996-A;n:type:ShaderForge.SFN_Color,id:7299,x:31735,y:32244,ptovrint:False,ptlb:node_7299,ptin:_node_7299,varname:node_7299,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:5380,x:32035,y:32358,varname:node_5380,prsc:2|A-7299-RGB,B-3288-R,C-7299-A;n:type:ShaderForge.SFN_ValueProperty,id:7726,x:31898,y:32612,ptovrint:False,ptlb:liangdu,ptin:_liangdu,varname:node_7726,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:4520,x:32147,y:32533,varname:node_4520,prsc:2|A-5380-OUT,B-7726-OUT;n:type:ShaderForge.SFN_Tex2d,id:6873,x:31598,y:31797,ptovrint:False,ptlb:3,ptin:_3,varname:node_6873,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-9385-UVOUT;n:type:ShaderForge.SFN_Add,id:3915,x:32254,y:32295,varname:node_3915,prsc:2|A-7283-OUT,B-4520-OUT;n:type:ShaderForge.SFN_Rotator,id:9385,x:31404,y:31797,varname:node_9385,prsc:2|UVIN-8817-UVOUT,SPD-66-OUT;n:type:ShaderForge.SFN_TexCoord,id:8817,x:31170,y:31730,varname:node_8817,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Vector1,id:66,x:31170,y:31919,varname:node_66,prsc:2,v1:5;n:type:ShaderForge.SFN_Color,id:3205,x:31598,y:31617,ptovrint:False,ptlb:3_col,ptin:_3_col,varname:node_3205,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:1104,x:31913,y:31723,varname:node_1104,prsc:2|A-3205-RGB,B-6873-RGB,C-3205-A;n:type:ShaderForge.SFN_Multiply,id:7283,x:32181,y:31929,varname:node_7283,prsc:2|A-6187-OUT,B-1104-OUT;n:type:ShaderForge.SFN_ValueProperty,id:6187,x:31909,y:31461,ptovrint:False,ptlb:3_liangdu,ptin:_3_liangdu,varname:node_6187,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:1896,x:32137,y:33263,ptovrint:False,ptlb:toumingdu,ptin:_toumingdu,varname:node_1896,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:283,x:32451,y:33140,varname:node_283,prsc:2|A-8286-OUT,B-1896-OUT;proporder:3288-2814-4676-4769-4996-6713-7299-7726-6873-3205-6187-1896;pass:END;sub:END;*/

Shader "Shader Forge/suofangzhezhao" {
    Properties {
        _1 ("1", 2D) = "white" {}
        _node_2814 ("node_2814", Float ) = 0
        [MaterialToggle] _1_RGBA ("1_RGB/A", Float ) = 0
        _node_4769 ("node_4769", Float ) = 0
        _2_RGBA ("2_RGB/A", 2D) = "white" {}
        [MaterialToggle] _2_rgba ("2_rgb/a", Float ) = 0
        _node_7299 ("node_7299", Color) = (0.5,0.5,0.5,1)
        _liangdu ("liangdu", Float ) = 0
        _3 ("3", 2D) = "white" {}
        _3_col ("3_col", Color) = (0.5,0.5,0.5,1)
        _3_liangdu ("3_liangdu", Float ) = 0
        _toumingdu ("toumingdu", Float ) = 1
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _1; uniform float4 _1_ST;
            uniform float _node_2814;
            uniform fixed _1_RGBA;
            uniform float _node_4769;
            uniform sampler2D _2_RGBA; uniform float4 _2_RGBA_ST;
            uniform fixed _2_rgba;
            uniform float4 _node_7299;
            uniform float _liangdu;
            uniform sampler2D _3; uniform float4 _3_ST;
            uniform float4 _3_col;
            uniform float _3_liangdu;
            uniform float _toumingdu;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
                float4 node_3933 = _Time;
                float node_9385_ang = node_3933.g;
                float node_9385_spd = 5.0;
                float node_9385_cos = cos(node_9385_spd*node_9385_ang);
                float node_9385_sin = sin(node_9385_spd*node_9385_ang);
                float2 node_9385_piv = float2(0.5,0.5);
                float2 node_9385 = (mul(i.uv0-node_9385_piv,float2x2( node_9385_cos, -node_9385_sin, node_9385_sin, node_9385_cos))+node_9385_piv);
                float4 _3_var = tex2D(_3,TRANSFORM_TEX(node_9385, _3));
                float4 node_6514 = _Time;
                float2 node_2329 = (i.uv0*2.0+-1.0).rg;
                float2 node_1927 = float2(((_node_2814*node_6514.g)+length(node_2329)),((1-abs(atan2(node_2329.r,node_2329.g)/3.14159265359))+(node_6514.g*_node_4769)));
                float4 _1_var = tex2D(_1,TRANSFORM_TEX(node_1927, _1));
                float3 emissive = ((_3_liangdu*(_3_col.rgb*_3_var.rgb*_3_col.a))+((_node_7299.rgb*_1_var.r*_node_7299.a)*_liangdu));
                float3 finalColor = emissive;
                float4 _2_RGBA_var = tex2D(_2_RGBA,TRANSFORM_TEX(i.uv0, _2_RGBA));
                return fixed4(finalColor,((lerp( _1_var.r, _1_var.a, _1_RGBA )*lerp( _2_RGBA_var.r, _2_RGBA_var.a, _2_rgba ))*_toumingdu));
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
