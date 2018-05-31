// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:32719,y:32712,varname:node_3138,prsc:2|emission-3008-OUT,alpha-4001-OUT;n:type:ShaderForge.SFN_Tex2dAsset,id:1681,x:30577,y:32666,ptovrint:False,ptlb:wenli,ptin:_wenli,varname:node_1681,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:539,x:30857,y:32532,varname:node_539,prsc:2,ntxv:0,isnm:False|UVIN-6181-OUT,TEX-1681-TEX;n:type:ShaderForge.SFN_Tex2d,id:6172,x:30857,y:32754,varname:node_6172,prsc:2,ntxv:0,isnm:False|UVIN-8830-OUT,TEX-1681-TEX;n:type:ShaderForge.SFN_Multiply,id:4441,x:31310,y:32717,varname:node_4441,prsc:2|A-539-R,B-6172-R;n:type:ShaderForge.SFN_Add,id:2639,x:31434,y:32337,varname:node_2639,prsc:2|A-2631-UVOUT,B-4441-OUT;n:type:ShaderForge.SFN_TexCoord,id:2631,x:31182,y:32337,varname:node_2631,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Tex2d,id:2361,x:31625,y:32337,ptovrint:False,ptlb:1,ptin:_1,varname:node_2361,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-2639-OUT;n:type:ShaderForge.SFN_Multiply,id:2328,x:32266,y:32381,varname:node_2328,prsc:2|A-2271-RGB,B-4051-OUT;n:type:ShaderForge.SFN_Color,id:2271,x:31926,y:32381,ptovrint:False,ptlb:node_2271,ptin:_node_2271,varname:node_2271,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:3008,x:32469,y:32317,varname:node_3008,prsc:2|A-3649-OUT,B-2328-OUT;n:type:ShaderForge.SFN_ValueProperty,id:3649,x:32266,y:32317,ptovrint:False,ptlb:node_3649,ptin:_node_3649,varname:node_3649,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_SwitchProperty,id:4814,x:31850,y:32575,ptovrint:False,ptlb:1_rgb/a,ptin:_1_rgba,varname:node_4814,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-2361-R,B-2361-A;n:type:ShaderForge.SFN_TexCoord,id:1078,x:30063,y:32671,varname:node_1078,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Time,id:5336,x:29537,y:32879,varname:node_5336,prsc:2;n:type:ShaderForge.SFN_Multiply,id:3489,x:29938,y:32928,varname:node_3489,prsc:2|A-551-OUT,B-5336-T;n:type:ShaderForge.SFN_Multiply,id:6113,x:29962,y:32287,varname:node_6113,prsc:2|A-681-OUT,B-5336-T;n:type:ShaderForge.SFN_ValueProperty,id:681,x:29585,y:32277,ptovrint:False,ptlb:wenli_1_u,ptin:_wenli_1_u,varname:node_681,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:551,x:29537,y:33091,ptovrint:False,ptlb:wenli_2_u,ptin:_wenli_2_u,varname:node_551,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:874,x:32360,y:32932,varname:node_874,prsc:2|A-4051-OUT,B-4323-OUT,C-2271-A,D-8962-A;n:type:ShaderForge.SFN_ValueProperty,id:3887,x:29604,y:32420,ptovrint:False,ptlb:wenli_1_v,ptin:_wenli_1_v,varname:node_3887,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:5897,x:29937,y:32540,varname:node_5897,prsc:2|A-3887-OUT,B-5336-T;n:type:ShaderForge.SFN_Append,id:5479,x:30209,y:32392,varname:node_5479,prsc:2|A-6113-OUT,B-5897-OUT;n:type:ShaderForge.SFN_Add,id:6181,x:30538,y:32391,varname:node_6181,prsc:2|A-5479-OUT,B-1078-UVOUT;n:type:ShaderForge.SFN_ValueProperty,id:5420,x:29547,y:33270,ptovrint:False,ptlb:wenli_2_v,ptin:_wenli_2_v,varname:node_5420,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:933,x:29975,y:33261,varname:node_933,prsc:2|A-5336-T,B-5420-OUT;n:type:ShaderForge.SFN_Append,id:1601,x:30329,y:33038,varname:node_1601,prsc:2|A-3489-OUT,B-933-OUT;n:type:ShaderForge.SFN_Add,id:8830,x:30579,y:33050,varname:node_8830,prsc:2|A-1078-UVOUT,B-1601-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:4051,x:32056,y:32761,ptovrint:False,ptlb:TEX1_ON/OFF,ptin:_TEX1_ONOFF,varname:node_4051,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-4814-OUT,B-4441-OUT;n:type:ShaderForge.SFN_Tex2d,id:3328,x:31824,y:32969,varname:node_3328,prsc:2,ntxv:0,isnm:False|TEX-3374-TEX;n:type:ShaderForge.SFN_Tex2dAsset,id:3374,x:31486,y:33057,ptovrint:False,ptlb:zhezhao,ptin:_zhezhao,varname:node_3374,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:294,x:31824,y:33150,varname:node_294,prsc:2,ntxv:0,isnm:False|UVIN-4794-OUT,TEX-3374-TEX;n:type:ShaderForge.SFN_ValueProperty,id:9206,x:31161,y:33477,ptovrint:False,ptlb:zhezhao_2_u,ptin:_zhezhao_2_u,varname:node_9206,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:2839,x:31161,y:33608,ptovrint:False,ptlb:zhezhao_2_v,ptin:_zhezhao_2_v,varname:node_2839,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Append,id:8364,x:31610,y:33470,varname:node_8364,prsc:2|A-9206-OUT,B-2839-OUT;n:type:ShaderForge.SFN_Add,id:4794,x:31610,y:33297,varname:node_4794,prsc:2|A-1078-UVOUT,B-8364-OUT;n:type:ShaderForge.SFN_Multiply,id:4323,x:32057,y:33040,varname:node_4323,prsc:2|A-3328-R,B-294-R;n:type:ShaderForge.SFN_VertexColor,id:8962,x:32057,y:33220,varname:node_8962,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:4978,x:32360,y:33184,ptovrint:False,ptlb:touming,ptin:_touming,varname:node_4978,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:4001,x:32544,y:33031,varname:node_4001,prsc:2|A-874-OUT,B-4978-OUT;proporder:1681-2361-2271-3649-4814-681-551-3887-5420-4051-3374-9206-2839-4978;pass:END;sub:END;*/

Shader "Shader Forge/liudongwenli" {
    Properties {
        _wenli ("wenli", 2D) = "white" {}
        _1 ("1", 2D) = "white" {}
        _node_2271 ("node_2271", Color) = (0.5,0.5,0.5,1)
        _node_3649 ("node_3649", Float ) = 0
        [MaterialToggle] _1_rgba ("1_rgb/a", Float ) = 0
        _wenli_1_u ("wenli_1_u", Float ) = 0
        _wenli_2_u ("wenli_2_u", Float ) = 0
        _wenli_1_v ("wenli_1_v", Float ) = 0
        _wenli_2_v ("wenli_2_v", Float ) = 0
        [MaterialToggle] _TEX1_ONOFF ("TEX1_ON/OFF", Float ) = 0
        _zhezhao ("zhezhao", 2D) = "white" {}
        _zhezhao_2_u ("zhezhao_2_u", Float ) = 0
        _zhezhao_2_v ("zhezhao_2_v", Float ) = 0
        _touming ("touming", Float ) = 1
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
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _wenli; uniform float4 _wenli_ST;
            uniform sampler2D _1; uniform float4 _1_ST;
            uniform float4 _node_2271;
            uniform float _node_3649;
            uniform fixed _1_rgba;
            uniform float _wenli_1_u;
            uniform float _wenli_2_u;
            uniform float _wenli_1_v;
            uniform float _wenli_2_v;
            uniform fixed _TEX1_ONOFF;
            uniform sampler2D _zhezhao; uniform float4 _zhezhao_ST;
            uniform float _zhezhao_2_u;
            uniform float _zhezhao_2_v;
            uniform float _touming;
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
////// Lighting:
////// Emissive:
                float4 node_5336 = _Time;
                float2 node_6181 = (float2((_wenli_1_u*node_5336.g),(_wenli_1_v*node_5336.g))+i.uv0);
                float4 node_539 = tex2D(_wenli,TRANSFORM_TEX(node_6181, _wenli));
                float2 node_8830 = (i.uv0+float2((_wenli_2_u*node_5336.g),(node_5336.g*_wenli_2_v)));
                float4 node_6172 = tex2D(_wenli,TRANSFORM_TEX(node_8830, _wenli));
                float node_4441 = (node_539.r*node_6172.r);
                float2 node_2639 = (i.uv0+node_4441);
                float4 _1_var = tex2D(_1,TRANSFORM_TEX(node_2639, _1));
                float _TEX1_ONOFF_var = lerp( lerp( _1_var.r, _1_var.a, _1_rgba ), node_4441, _TEX1_ONOFF );
                float3 emissive = (_node_3649*(_node_2271.rgb*_TEX1_ONOFF_var));
                float3 finalColor = emissive;
                float4 node_3328 = tex2D(_zhezhao,TRANSFORM_TEX(i.uv0, _zhezhao));
                float2 node_4794 = (i.uv0+float2(_zhezhao_2_u,_zhezhao_2_v));
                float4 node_294 = tex2D(_zhezhao,TRANSFORM_TEX(node_4794, _zhezhao));
                return fixed4(finalColor,((_TEX1_ONOFF_var*(node_3328.r*node_294.r)*_node_2271.a*i.vertexColor.a)*_touming));
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
            struct VertexInput {
                float4 vertex : POSITION;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
