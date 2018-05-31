using UnityEngine;
using System.Collections;

namespace UnityEngine.UI
{
	public class UIRaycast : MaskableGraphic
    {
		protected override void OnPopulateMesh(VertexHelper toFill)
		{
			toFill.Clear();
		}
	}
}