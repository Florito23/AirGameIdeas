package platonics 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class Dodecahedron extends Platonic 
	{
		
		public function Dodecahedron(cubeSize:Number) 
		{
			
			
			trace(this);
			// how to construct:
			/*Once you have the coordinates of the vertices of the icosahedron, the vertices of the 
			dodecahedron can be taken to be the centers of each of the icosahedron’s triangles. You 
			can get the coordinates of such a center point by averaging each of the coordinates of the 
			vertices of the triangle*/
			
			
			var ico:Icosahedron = new Icosahedron(cubeSize);
			var icoVertices:Vector.<Vector3D> = ico.icosahedronCorners;
			var icoTriangles:Vector.<Triangle> = ico.triangles;
			ico = null;
			
			var icoCornerAmount:int = icoVertices.length;
			var icoTriangleAmount:int = icoTriangles.length;
			for (var v:int = 0; v < icoCornerAmount; v++) {
				
				/*
				 * find the 5 contacting triangles for each ico corner (->surroundingTriangles)
				 */ 
				var vertex:Vector3D = icoVertices[v];
				var surroundingTriangles:Vector.<Triangle> = new Vector.<Triangle>();
				for (var t:int = 0; t < icoTriangleAmount; t++) {
					if (icoTriangles[t].hasVertex(vertex)) {
						surroundingTriangles.push(icoTriangles[t]);
					}
				}
				if (surroundingTriangles.length != 5) throw new Error("Something wrong, surrounding triangles not 5");
				
				/* 
				 * now sort the 5 triangles by matching edges (surroundingTriangles -> sortedTriangles)
				 */
				var sortedTriangles:Vector.<Triangle> = new Vector.<Triangle>();
				sortedTriangles.push(surroundingTriangles.pop()); // start with one triangle:
				var centerVertex:Vector3D = vertex;
				var edgeVertex1:Vector3D = sortedTriangles[0].getAVertexThatIsNot(vertex);
				
				var j:int;
				for (j = 0; j < 4;j++) {
					
					// find another triangle with the same edge
					var foundTriangle:Triangle;
					for (var s:int = 0; s < surroundingTriangles.length; s++) {
						if (surroundingTriangles[s].hasVertex(centerVertex) && surroundingTriangles[s].hasVertex(edgeVertex1) && sortedTriangles.indexOf(surroundingTriangles[s])==-1) {
							foundTriangle = surroundingTriangles.splice(s, 1)[0];
							s = 5;
						}
					}
					sortedTriangles.push(foundTriangle);
					
					// and update the edge
					edgeVertex1 = foundTriangle.getOtherVertex(vertex, edgeVertex1);

				}
				trace("sorted triangles", sortedTriangles.length);
				if (sortedTriangles.length != 5) throw new Error("summin wrong");
				
				
				/*
				 * now calculate the 5 triangles centers
				 */
				var triangleCenters:Vector.<Vector3D> = new Vector.<Vector3D>(5);
				var triangleCentersAveraged:Vector3D = new Vector3D;
				for (j = 0; j < 5;j++) {
					triangleCenters[j] = sortedTriangles[j].calculateCenter();
					triangleCentersAveraged.add(triangleCenters[j]);
				}
				triangleCentersAveraged.scaleBy(1 / 5.0);
				
				
				/*
				 * Check that the direction of these 5 triangles is clockwise
				 */
				trace("DIRECTION (angles)");
				var temp:Vector.<Number> = new Vector.<Number>();
				var v0:Vector3D = triangleCenters[0];
				for (j = 1; j <= 5; j++) {
					var v1:Vector3D = triangleCenters[j % 5];
					temp.push(Vector3D.angleBetween(v0, v1));
					v0 = v1;
				}
				trace(temp);
				
				/*
				 * And create pentagonal faces
				 */
				
			} // each icosahedron corner
			
			
		}
		
	}

}