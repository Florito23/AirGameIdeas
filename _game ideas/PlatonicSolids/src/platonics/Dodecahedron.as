package platonics 
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class Dodecahedron extends Platonic 
	{
		
		public function Dodecahedron(cubeSize:Number, textureSize:int = 0 ) 
		{
			
			
			trace(this);
			
			
			var index:int = 0;
			triangles = new Vector.<Triangle>();
			
			// how to construct:
			/*Once you have the coordinates of the vertices of the icosahedron, the vertices of the 
			dodecahedron can be taken to be the centers of each of the icosahedron’s triangles. You 
			can get the coordinates of such a center point by averaging each of the coordinates of the 
			vertices of the triangle*/
			
			var uv0:Point = new Point(0, 105.1);
			var uv1:Point = new Point(128, 11.88);
			var uv2:Point = new Point(256, 105.1);
			var uv3:Point = new Point(207.11, 256);
			var uv4:Point = new Point(48.89, 256);
			var uvCen:Point = new Point(128, 146.83);
			var uvAll:Vector.<Point> = Vector.<Point>([uv0, uv1, uv2, uv3, uv4, uvCen]);
			for (var u:int = 0; u < 6; u++) {
				uvAll[u].x *= 1 / 256.0;
				uvAll[u].y *= 1 / 256.0;
			}
			if (textureSize>0) {
				var scl:Number = ((textureSize / 2)-1) / (textureSize / 2);
				for (u = 0; u < 5; u++) {
					uvAll[u].x -= uvCen.x;
					uvAll[u].y -= uvCen.y;
					uvAll[u].x *= scl;
					uvAll[u].y *= scl;
					uvAll[u].x += uvCen.x;
					uvAll[u].y += uvCen.y;
				}
			}
			trace(uv0, uv1, uv2, uv3, uv4, uvCen);
			
			
			var ico:Icosahedron = new Icosahedron(cubeSize);
			var icoVertices:Vector.<Vector3D> = ico.icosahedronCorners;
			var icoTriangles:Vector.<Triangle> = ico.triangles;
			ico = null;
			
			var icoCornerAmount:int = icoVertices.length;
			var icoTriangleAmount:int = icoTriangles.length;
			var t:int;
			for (var v:int = 0; v < icoCornerAmount; v++) {
				
				/*
				 * find the 5 contacting triangles for each ico corner (->surroundingTriangles)
				 */ 
				var vertex:Vector3D = icoVertices[v];
				var surroundingTriangles:Vector.<Triangle> = new Vector.<Triangle>();
				for (t = 0; t < icoTriangleAmount; t++) {
					if (icoTriangles[t].hasVertex(vertex)) {
						surroundingTriangles.push(icoTriangles[t]);
					}
				}
				if (surroundingTriangles.length != 5) throw new Error("Something wrong, surrounding triangles not 5");
				
				/*
				 * Extract the 5 corner points (the ones that are not vertex)
				 */
				var icoCorners:Vector.<Vector3D> = new Vector.<Vector3D>();
				for (t = 0; t < 5; t++) {
					var tri:Triangle = surroundingTriangles[t];
					var abc:Vector.<Vector3D> = Vector.<Vector3D>([tri.a, tri.b, tri.c]);
					abc.splice(abc.indexOf(vertex), 1); // remove the vertex
					var v0:Vector3D = abc[0];
					var v1:Vector3D = abc[1];
					if (icoCorners.indexOf(v0) < 0) {
						icoCorners.push(v0);
					} 
					if (icoCorners.indexOf(v1) < 0) {
						icoCorners.push(v1);
					}
				}
				trace("ICO CORNERS");
				trace("\t", icoCorners[0]);
				trace("\t", icoCorners[1]);
				trace("\t", icoCorners[2]);
				trace("\t", icoCorners[3]);
				trace("\t", icoCorners[4]);
				//trace("Penta corners (" + pentaCorners.length + ")", pentaCorners);
				/*var distances:String = "";
				for (t = 0; t < 4; t++) {
					var c0:Vector3D = pentaCorners[t];
					var c1:Vector3D = pentaCorners[t + 1];
					var distance:Number = Vector3D.distance(c0, c1);
					distances += t + "->" + (t + 1) + ":" + distance.toFixed(1) + ",";
				}
				trace("Distances", distances);*/
				//trace(pentaCorners);
				
				/*
				 * Now sort them so that at least we have them in a circle
				 */
				var wantedDistance:Number = Vector3D.distance(vertex, icoCorners[0]);
				var icoCornersCircle:Vector.<Vector3D> = new Vector.<Vector3D>();
				for (t = 0; t < 5; t++) {
					var foundCorner:Vector3D = null;
					if (t == 0) {
						foundCorner = icoCorners[0];
					} else {
						for (u = 0; u < icoCorners.length; u++) {
							var testCorner:Vector3D = icoCorners[u];
							if (testCorner != icoCornersCircle[t - 1]) {
								if (Vector3D.distance(testCorner, icoCornersCircle[t - 1]) <= wantedDistance * 1.01) {
									//OK!
									//icoCornersCircle.push(testCorner);
									foundCorner = testCorner;
									u = 100;// break;
								}
							}
						}
					}
					
					icoCorners.splice(icoCorners.indexOf(foundCorner), 1);
					icoCornersCircle[t] = foundCorner;
				}
				
				trace("icoCornersCircle in circle (" + icoCornersCircle.length + ")", icoCornersCircle);
				/*distances = "";
				for (t = 0; t < 4; t++) {
					c0 = pentaCornersCircle[t];
					c1 = pentaCornersCircle[t + 1];
					distance = Vector3D.distance(c0, c1);
					distances += t + "->" + (t + 1) + ":" + distance.toFixed(1) + ",";
				}
				trace("Distances", distances);*/
				
				
				
				
				
				//TODO: CLOCKWISE SORTING???? HOW???
				// sorting: compare the normal of the face vertex / pcc[0] / pcc[1] with the vector avCenter->vertex
				// this way we can check clockwise / counterclockwise
				var vx_p0:Vector3D = icoCornersCircle[0].subtract(vertex);
				var p0_p1:Vector3D = icoCornersCircle[1].subtract(icoCornersCircle[0]);
				var normal:Vector3D = vx_p0.crossProduct(p0_p1);
				
				var pcc:Vector.<Vector3D> = icoCornersCircle;
				var avCenter:Vector3D = pcc[0].add(pcc[1]).add(pcc[2]).add(pcc[3]).add(pcc[4]);
				avCenter.scaleBy(1 / 5.0);
				var cenToV:Vector3D = vertex.subtract(avCenter);
				
				var angle:Number = Vector3D.angleBetween(normal, cenToV);
				if (angle > Math.PI / 2) {
					trace("reversing direction of icoCornersCircle");
					var temp:Vector.<Vector3D> = new Vector.<Vector3D>(5);
					for (t = 0; t < 5; t++) {
						temp[t] = icoCornersCircle[4 - t];
					}
					icoCornersCircle = temp;
				}
				trace("ICO CORNERS CIRCLE aound VERTEX",vertex);
				trace("\t", icoCornersCircle[0]);
				trace("\t", icoCornersCircle[1]);
				trace("\t", icoCornersCircle[2]);
				trace("\t", icoCornersCircle[3]);
				trace("\t", icoCornersCircle[4]);
				
				
				/*
				 * Now get the 5 centers to create a Pentagon
				 * from averaging vertex, corner0 and corner1
				 */
				var pentagon:Vector.<Vector3D> = new Vector.<Vector3D>(5);
				var pentagonCenter:Vector3D = new Vector3D();
				for (t = 0; t < 5; t++) {
					var c0:Vector3D = icoCornersCircle[t];
					var c1:Vector3D = icoCornersCircle[(t + 1) % 5];
					var c2:Vector3D = vertex;
					var triCenter:Vector3D = c0.add(c1).add(c2);
					triCenter.scaleBy(1 / 3.0);
					pentagon[t] = triCenter;
					trace("AVERAGING");
					trace("\t", c2, "(vertex)");
					trace("\t", c0);
					trace("\t", c1);
					trace("\t =", pentagon[t]);
					pentagonCenter = pentagonCenter.add(triCenter);
				}
				pentagonCenter.scaleBy(1 / 5.0);
				trace("PENTAGON", pentagon);
				
				/*
				 * Now create the triangles from the pentagon
				 */
				
				for (t = 0; t < 5; t++) {
					c0 = pentagon[t];
					c1 = pentagon[(t + 1) % 5];
					c2 = pentagonCenter;
					
					var uvA:Point = uvAll[t];
					var uvB:Point = uvAll[(t + 1) % 5];
					var uvC:Point = uvCen;
					
					triangles[index++] = new Triangle(c0, c1, c2, uvA, uvB, uvC);
				}
				
				
				
				
				
				
			} // each icosahedron corner
			
			
		}
		
	}

}