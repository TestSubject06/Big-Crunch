package game 
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxGroup;
	import org.flixel.FlxG;
	import org.flixel.FlxU;
	
	/**
	 * ...
	 * @author Zack Tarvit & Ed Dubois
	 */
	public class Nexus extends FlxSprite 
	{
		[Embed(source = '../assets/nexus.png')] private var ImgNexus:Class;
		[Embed(source = '../assets/nexusorb.png')] private var ImgNexusOrb:Class;
		
		private var numOrbs:int = 50;
		private var orbCont:FlxGroup;
		private var player:Player;
		private var grabbingPlayer:Boolean = false;
		public function Nexus(orbContainer:FlxGroup, X:Number = 0, Y:Number = 0, SimpleGraphic:Class = null) 
		{
			super(X, Y, SimpleGraphic);
			loadGraphic(ImgNexus, true, false, 64, 64, false);
			addAnimation("Idle", [0, 1, 2, 3, 4, 5, 4, 3, 2, 1], 30, true);
			play("Idle");
			orbCont = orbContainer;
			for (var i:int = 0; i < numOrbs; i++) {
				var orb:FlxSprite = new FlxSprite(x, y, ImgNexusOrb);
				orb.solid = false;
				orbCont.add(orb);
				orb.velocity.x = FlxU.random() * 200;
				orb.velocity.y = FlxU.random() * 200;
			}
			for (var i:int = 0; i < numOrbs/2; i++) {
				var orb:FlxSprite = new FlxSprite(x, y, ImgNexusOrb);
				orb.solid = true;
				orbCont.add(orb);
				orb.velocity.x = FlxU.random() * 200;
				orb.velocity.y = FlxU.random() * 200;
			}
		}
		
		public override function update():void {
			super.update();
			for each(var a:FlxSprite in orbCont.members) {
				if (!a.solid){
					if (y + 32 > a.y)
					{
						a.velocity.y += FlxU.random() * 50 + 5;
					}
					if (y + 32 < a.y)
					{
						a.velocity.y -= FlxU.random() * 50 + 5;
					}
					if (x + 32 > a.x)
					{
						a.velocity.x += FlxU.random() * 50 + 5;
					}
					if (x + 32 < a.x)
					{
						a.velocity.x -= FlxU.random() * 50 + 5;
					}
				}else {
					if (y + 32 > a.y)
					{
						a.velocity.y += FlxU.random() * 15 + 5;
					}
					if (y + 32 < a.y)
					{
						a.velocity.y -= FlxU.random() * 15 + 5;
					}
					if (x + 32 > a.x)
					{
						a.velocity.x += FlxU.random() * 15 + 5;
					}
					if (x + 32 < a.x)
					{
						a.velocity.x -= FlxU.random() * 15 + 5;
					}
				}
				if (a.velocity.x > 300)
					a.velocity.x = 300;
				if (a.velocity.y > 300)
					a.velocity.y = 300;
			}
			
			if (grabbingPlayer) {
				if (player.x+5 < x+32) {
					player.velocity.x = 100;
				}
				if (player.x+5 > x+32) {
					player.velocity.x = -100;
				}
				if (player.y+6 < y+32) {
					player.velocity.y = 100;
				}
				if (player.y+6 > y+32) {
					player.velocity.y = -100;
				}
			}
		}
		public function grabPlayer(thePlayer:Player):void {
			player = thePlayer;
			grabbingPlayer = true;
			player.revokeControl();
			FlxG.quake.start(.01, 5);
		}
		
	}

}