/* 
 * The MIT License
 *
 * Copyright (c) 2008
 * United Nations Office at Geneva
 * Center for Advanced Visual Analytics
 * http://cava.unog.ch
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package org.un.cava.birdeye.geovis.transformations
{
	public class EckertIVTransformation extends Transformation
	{
		private var _latRad:Number;
		private var _longRad:Number;
		private var _theta:Number=1;
		private var _loopCounter:Number=0;

		public function EckertIVTransformation(lat:Number,long:Number)
		{
			super();
			_latRad=convertDegToRad(lat);
			_longRad=convertDegToRad(long);

			this.scalefactor=163.6;
			this.xoffset=2.524;
			this.yoffset=1.31;
			
			_theta = approx_theta(_latRad);
		}

		private function approxIsGoodEnough(tP:Number, la:Number):Boolean {
			var maxDiff:Number = 1E-100; //acceptable deviation
			_loopCounter++;
			//diff = Left side - Right side = tP + sin(tP)cos(tP) + 2sin(tP) - (2 + pi/2)*sin(lat)
			var diff:Number = tP+Math.sin(tP)*Math.cos(tP)+2*Math.sin(tP) - (2+Math.PI/2) * Math.sin(la); 
			return (Math.abs(diff)<maxDiff || _loopCounter>=100);
		}
		
		private function newtonRaphson(tP:Number, la:Number):Number {
			//numerator: (2+pi/2)*sin(lat) - tP - sin(tP)cos(tP) - 2sin(tP)
			//denominator: 2cos(tP)*(1+cos(tP))
			return ((2+Math.PI/2)*Math.sin(la) - tP - Math.sin(tP)*Math.cos(tP) - 2*Math.sin(tP))/(2*Math.cos(tP)*(1+Math.cos(tP)));
		}

		private function approx_theta(la:Number):Number
		{
			var _thetaPrim:Number = la/2;
			while (approxIsGoodEnough(_thetaPrim, la)==false) {
				_thetaPrim = _thetaPrim + newtonRaphson(_thetaPrim, la);
			}
			return _thetaPrim;
		}

		public override function calculateX():Number
		{
			const lstart:Number = 0;
			const c:Number = 2/Math.sqrt(Math.PI*(4+Math.PI));
			var xCentered:Number;
			
			xCentered = c *(_longRad-lstart)*(1+Math.cos(_theta));
			return translateX(xCentered);
		}

		public override function calculateY():Number
		{
			const c:Number = 2*Math.sqrt(Math.PI/(4+Math.PI));
			var yCentered:Number;
			
			yCentered = c * Math.sin(_theta);
			return translateY(yCentered);
		}

	}
}