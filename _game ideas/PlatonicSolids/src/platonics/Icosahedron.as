package platonics 
{
	import away3d.core.base.CompactSubGeometry;
	import away3d.primitives.PrimitiveBase;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class Icosahedron extends Platonic
	{
	
		internal var icosahedronCorners:Vector.<Vector3D>;
		
		public function Icosahedron(cubeSize:Number, textureSize:int = 0) 
		{
			
			var hs:Number = cubeSize * 0.5;
			var fi:Number = (1 + Math.sqrt(5)) * 0.5;
			var ht:Number = hs / fi;
			
			// x positive -> right
			// y positive -> down
			// z positive -> front
			var left:Number = -hs, tLeft:Number = -ht;
			var right:Number = hs, tRight:Number = ht;
			var top:Number = -hs, tTop:Number = -ht;
			var bottom:Number = hs, tBottom:Number = ht;
			var front:Number = hs, tFront:Number = ht;
			var back:Number = -hs, tBack:Number = -ht;
			
			// all corners
			
			// bottom:
			var I:Vector3D = new Vector3D(0, bottom, tFront);
			var J:Vector3D = new Vector3D(0, bottom, tBack);
			// left:
			var K:Vector3D = new Vector3D(left, tTop, 0);
			var L:Vector3D = new Vector3D(left, tBottom, 0);
			// back:
			var M:Vector3D = new Vector3D(tRight, 0, back);
			var N:Vector3D = new Vector3D(tLeft, 0, back);
			// right:
			var O:Vector3D = new Vector3D(right, tTop, 0);
			var P:Vector3D = new Vector3D(right, tBottom, 0);
			// front:
			var Q:Vector3D = new Vector3D(tRight, 0, front);
			var R:Vector3D = new Vector3D(tLeft, 0, front);
			// top:
			var S:Vector3D = new Vector3D(0, top, tFront);
			var T:Vector3D = new Vector3D(0, top, tBack);
			icosahedronCorners = new Vector.<Vector3D>();
			icosahedronCorners.push(I);
			icosahedronCorners.push(J);
			icosahedronCorners.push(K);
			icosahedronCorners.push(L);
			icosahedronCorners.push(M);
			icosahedronCorners.push(N);
			icosahedronCorners.push(O);
			icosahedronCorners.push(P);
			icosahedronCorners.push(Q);
			icosahedronCorners.push(R);
			icosahedronCorners.push(S);
			icosahedronCorners.push(T);
			
			
			// uv
			var corner0:Point = new Point(0, 0);
			var corner1:Point = new Point(0.8660234375, 0.5);//	0 / 1);
			var corner2:Point = new Point(0, 1);
			// point one pixel inward
			var cornerAv:Point = new Point((corner0.x + corner1.x + corner2.x) / 3, (corner0.y + corner1.y + corner2.y) / 3);
			var all:Vector.<Point> = Vector.<Point>([corner0, corner1, corner2]);
			if (textureSize>0) {
				var scl:Number = ((textureSize / 2)-1) / (textureSize / 2);
				for (var i:int = 0; i < 3; i++) {
					all[i] = all[i].subtract(cornerAv);
					all[i].x *= scl;
					all[i].y *= scl;
					all[i] = all[i].add(cornerAv);
				}
				corner0 = all[0];
				corner1 = all[1];
				corner2 = all[2];
			}
			
			// all triangles by reference
			triangles = new Vector.<Triangle>(20);// 12 "roofs" + 8 "corners" = 20 triangles
			var index:int = 0;
			
			//roofs:
			/*
			IJL
			JIP
			STO
			TSK
			
			OPQ
			POM
			LKR
			KLN
			
			RQI
			QRS
			MNJ
			NMT*/
			triangles[index++] = new Triangle( I, J, L, corner0, corner1, corner2);
			triangles[index++] = new Triangle( J, I, P, corner0, corner1, corner2);
			triangles[index++] = new Triangle( S, T, O, corner0, corner1, corner2);
			triangles[index++] = new Triangle( T, S, K, corner0, corner1, corner2);
			
			triangles[index++] = new Triangle( O, P, Q, corner0, corner1, corner2);
			triangles[index++] = new Triangle( P, O, M, corner0, corner1, corner2);
			triangles[index++] = new Triangle( L, K, R, corner0, corner1, corner2);
			triangles[index++] = new Triangle( K, L, N, corner0, corner1, corner2);
			
			triangles[index++] = new Triangle( R, Q, I, corner0, corner1, corner2);
			triangles[index++] = new Triangle( Q, R, S, corner0, corner1, corner2);
			triangles[index++] = new Triangle( M, N, J, corner0, corner1, corner2);
			triangles[index++] = new Triangle( N, M, T, corner0, corner1, corner2);
			
			// Corners:
			/*
			SOQ
			SRK
			TMO
			TKN
			IQP
			ILR
			JPM
			JLN*/
			triangles[index++] = new Triangle( S, O, Q, corner0, corner1, corner2);
			triangles[index++] = new Triangle( S, R, K, corner0, corner1, corner2);
			triangles[index++] = new Triangle( T, M, O, corner0, corner1, corner2);
			triangles[index++] = new Triangle( T, K, N, corner0, corner1, corner2);
			
			triangles[index++] = new Triangle( I, Q, P, corner0, corner1, corner2);
			triangles[index++] = new Triangle( I, L, R, corner0, corner1, corner2);
			triangles[index++] = new Triangle( J, P, M, corner0, corner1, corner2);
			triangles[index++] = new Triangle( J, N, L, corner0, corner1, corner2);
			

			/*for (var i:int = 0; i < triangles.length; i++) {
				var a:Vector3D = triangles[i].a.clone();
				var b:Vector3D = triangles[i].b.clone();
				var c:Vector3D = triangles[i].c.clone();
				var lab:Number = Vector3D.distance(a, b);
				var lbc:Number = Vector3D.distance(b, c);
				var lca:Number = Vector3D.distance(c, a);
				trace(i, "distances", lab, lbc, lca);
			}*/
		}
		
		
		
	}

}