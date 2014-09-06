package game 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Zack Tarvit & Ed Dubois
	 */
	public class Finger extends FlxSprite 
	{
		[Embed(source = '../assets/Point2.png')] private var finger:Class;
		private var timer:Number = 0;
		public function Finger(X:Number = 0, Y:Number = 0, SimpleGraphic:Class = null) 
		{
			super(X, Y);
			//createGraphic(12, 20, 0xFF00FF00);
			loadGraphic(finger, true, true, 88, 66);
			addAnimation("Point", [3, 3, 3, 3, 3, 0, 1, 2, 2, 2, 2, 2, 2], 20, true);
			play("Point");
		}
		public override function update():void {
			timer += FlxG.elapsed;
			if (timer > 3) {
				dead = true;
				visible = false;
				active = false;
				exists = false;
				solid = false;
			}
			super.update();
			
		}
	}

}