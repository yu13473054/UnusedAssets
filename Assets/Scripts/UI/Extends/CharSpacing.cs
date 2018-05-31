using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System;
using System.Collections.Generic;

///  暂不支持自动换行
[AddComponentMenu("UI/Effects/CharSpacing")]
public class CharSpacing : BaseMeshEffect
{
    public float spacing = 1f;
    int _charVertex = 6;
    Text _text;
    enum Alignment
    {
        Center,
        Left,
        Right
    };
    Alignment textAlignment;
    Dictionary<int, List<int>> dic = new Dictionary<int, List<int>>();
    public override void ModifyMesh(VertexHelper vh)
    {
        if (!this.IsActive() || vh.currentVertCount <= 0)
            return;
        if (_text == null)
        {
            _text = this.GetComponent<Text>();
        }
        switch (_text.alignment)
        {
            case TextAnchor.LowerLeft:
            case TextAnchor.MiddleLeft:
            case TextAnchor.UpperLeft:
                textAlignment = Alignment.Left;
                break;

            case TextAnchor.LowerCenter:
            case TextAnchor.MiddleCenter:
            case TextAnchor.UpperCenter:
                textAlignment = Alignment.Center;
                break;

            case TextAnchor.LowerRight:
            case TextAnchor.MiddleRight:
            case TextAnchor.UpperRight:
                textAlignment = Alignment.Right;
                break;
        }
        dic.Clear();
        List<UIVertex> vertexList = new List<UIVertex>();
        vh.GetUIVertexStream(vertexList);
        ModifyVertices(vertexList);

        vh.Clear();
        vh.AddUIVertexTriangleStream(vertexList);
    }

    void ModifyVertices(List<UIVertex> vertexList)
    {
        // 将顶点按行分类
        float topY = 0f, bottomY = 0f, curTopY = 0f, curBottomY = 0f;
        int lineIndex = 0;
        for (int i = 0; i < vertexList.Count;)
        {
            List<UIVertex> temp = new List<UIVertex>();
            for (int k = 0; k < _charVertex; k++)
            {
                temp.Add(vertexList[k + i]);
            }
            if (CheckIfCanInsert(temp))
            {
                FindMostValue(temp, ref curTopY, ref curBottomY);

                if (curTopY < bottomY)
                {
                    lineIndex += 1;

                    topY = curTopY;
                    bottomY = curBottomY;
                }

                if (topY == 0f && bottomY == 0f)
                {
                    topY = curTopY;
                    bottomY = curBottomY;
                }
                List<int> t;
                if (!dic.TryGetValue(lineIndex, out t))
                {
                    dic.Add(lineIndex, new List<int>());
                    dic.TryGetValue(lineIndex, out t);
                }
                for (int k = 0; k < _charVertex; k++)
                {
                    t.Add(k + i);
                }
            }
            i += _charVertex;
        }

        //修改顶点
        foreach (var t in dic)
        {
            List<int> value = t.Value;
            float dis = 0f;
            for (int i = 0; i < value.Count; i++)
            {
                int index = value[i];
                UIVertex uivertex = vertexList[index];
                Vector3 pos = uivertex.position;
                if (textAlignment == Alignment.Right)
                {
                    pos.x -= spacing * ((value.Count - 1 - i) / _charVertex);
                }
                else
                {
                    if (textAlignment == Alignment.Center)
                    {
                        dis = spacing * (value.Count / _charVertex - 1) * 0.5f;
                    }

                    pos.x += spacing * (i / _charVertex) - dis;
                }
                uivertex.position = pos;
                vertexList[index] = uivertex;
            }
        }

    }

    /// 判断当前坐标点是否有效（在text渲染的时候\n的渲染有点不一样）
    bool CheckIfCanInsert(List<UIVertex> vertexList)
    {
        bool isCan = true;
        Vector3 pos = vertexList[0].position;
        int num = 0;
        for (int i = 1; i < vertexList.Count; i++)
        {
            Vector3 p = vertexList[i].position;
            if (p.x == pos.x && p.y == pos.y)
            {
                num++;
            }
        }
        isCan = (num != (vertexList.Count - 1));
        return isCan;
    }

    /// 查找最值
    void FindMostValue(List<UIVertex> vertexList, ref float topY, ref float bottomY, int startIndex = 0)
    {
        topY = vertexList[startIndex].position.y;
        bottomY = topY;

        for (int i = startIndex; i < vertexList.Count; i++)
        {
            float y = vertexList[i].position.y;
            if (y > topY)
            {
                topY = y;
            }
            else if (y < bottomY)
            {
                bottomY = y;
            }

        }
    }
}