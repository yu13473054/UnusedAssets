// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:False,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:33135,y:32707,varname:node_3138,prsc:2|emission-3792-OUT,alpha-1801-OUT,clip-2456-OUT;n:type:ShaderForge.SFN_Tex2d,id:428,x:31818,y:32687,ptovrint:False,ptlb:TEX1,ptin:_TEX1,varname:node_428,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:4580,x:31822,y:33121,ptovrint:False,ptlb:zhezhao,ptin:_zhezhao,varname:node_4580,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_SwitchProperty,id:3217,x:32009,y:33138,ptovrint:False,ptlb:zhezhao_R/A,ptin:_zhezhao_RA,varname:node_3217,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-4580-R,B-4580-A;n:type:ShaderForge.SFN_Multiply,id:6611,x:32295,y:32616,varname:node_6611,prsc:2|A-3090-RGB,B-2386-OUT;n:type:ShaderForge.SFN_Color,id:3090,x:31818,y:32494,ptovrint:False,ptlb:TEX1_Color,ptin:_TEX1_Color,varname:node_3090,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:958,x:32224,y:33084,varname:node_958,prsc:2|A-3090-A,B-3217-OUT,C-2815-A,D-2386-OUT;n:type:ShaderForge.SFN_VertexColor,id:2815,x:32009,y:33280,varname:node_2815,prsc:2;n:type:ShaderForge.SFN_Multiply,id:3792,x:32541,y:32564,varname:node_3792,prsc:2|A-194-OUT,B-6611-OUT;n:type:ShaderForge.SFN_ValueProperty,id:194,x:32295,y:32542,ptovrint:False,ptlb:Tex1_liangdu,ptin:_Tex1_liangdu,varname:node_194,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_SwitchProperty,id:2386,x:32090,y:32755,ptovrint:False,ptlb:Tex1_R/A,ptin:_Tex1_RA,varname:node_2386,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-428-R,B-428-A;n:type:ShaderForge.SFN_ValueProperty,id:7605,x:32224,y:33019,ptovrint:False,ptlb:node_7605,ptin:_node_7605,varname:node_7605,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:1801,x:32444,y:33045,varname:node_1801,prsc:2|A-7605-OUT,B-958-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:2456,x:32824,y:33110,ptovrint:False,ptlb:clip/1,ptin:_clip1,varname:node_2456,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-4724-OUT,B-1801-OUT;n:type:ShaderForge.SFN_Vector1,id:4724,x:32589,y:32846,varname:node_4724,prsc:2,v1:1;proporder:4580-3217-428-3090-194-2386-7605-2456;pass:END;sub:END;*/

Shader "Shader Forge/FX_Shader_zhezhao" {
    Properties {
        _zhezhao ("zhezhao", 2D) = "white" {}
        [MaterialToggle] _zhezhao_RA ("zhezhao_R/A", Float ) = 0
        _TEX1 ("TEX1", 2D) = "white" {}
        _TEX1_Color ("TEX1_Color", Color) = (0.5,0.5,0.5,1)
        _Tex1_liangdu ("Tex1_liangdu", Float ) = 1
        [MaterialToggle] _Tex1_RA ("Tex1_R/A", Float ) = 0
        _node_7605 ("node_7605", Float ) = 0
        [MaterialToggle] _clip1 ("clip/1", Float ) = 1
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
            Cull Off
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _TEX1; uniform float4 _TEX1_ST;
            uniform sampler2D _zhezhao; uniform float4 _zhezhao_ST;
            uniform fixed _zhezhao_RA;
            uniform float4 _TEX1_Color;
            uniform float _Tex1_liangdu;
            uniform fixed _Tex1_RA;
            uniform float _node_7605;
            uniform fixed _clip1;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                float4 _zhezhao_var = tex2D(_zhezhao,TRANSFORM_TEX(i.uv0, _zhezhao));
                float4 _TEX1_var = tex2D(_TEX1,TRANSFORM_TEX(i.uv0, _TEX1));
                float _Tex1_RA_var = lerp( _TEX1_var.r, _TEX1_var.a, _Tex1_RA );
                float node_1801 = (_node_7605*(_TEX1_Color.a*lerp( _zhezhao_var.r, _zhezhao_var.a, _zhezhao_RA )*i.vertexColor.a*_Tex1_RA_var));
                clip(lerp( 1.0, node_1801, _clip1 ) - 0.5);
////// Lighting:
////// Emissive:
                float3 emissive = (_Tex1_liangdu*(_TEX1_Color.rgb*_Tex1_RA_var));
                float3 finalColor = emissive;
                return fixed4(finalColor,node_1801);
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _TEX1; uniform float4 _TEX1_ST;
            uniform sampler2D _zhezhao; uniform float4 _zhezhao_ST;
            uniform fixed _zhezhao_RA;
            uniform float4 _TEX1_Color;
            uniform fixed _Tex1_RA;
            uniform float _node_7605;
            uniform fixed _clip1;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                float4 _zhezhao_var = tex2D(_zhezhao,TRANSFORM_TEX(i.uv0, _zhezhao));
                float4 _TEX1_var = tex2D(_TEX1,TRANSFORM_TEX(i.uv0, _TEX1));
                float _Tex1_RA_var = lerp( _TEX1_var.r, _TEX1_var.a, _Tex1_RA );
                float node_1801 = (_node_7605*(_TEX1_Color.a*lerp( _zhezhao_var.r, _zhezhao_var.a, _zhezhao_RA )*i.vertexColor.a*_Tex1_RA_var));
                clip(lerp( 1.0, node_1801, _clip1 ) - 0.5);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
