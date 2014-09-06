package game 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Zack Tarvit & Ed Dubois
	 */
	public class Player extends FlxSprite 
	{
		[Embed(source = '../assets/PlayerCharacter.png')] private var doodImg:Class;
		
		public static var numUniverses:int = 0;
		public static var Time:Number = 0;
		private var canControl:Boolean = true;
		private var soundGen:SfxrSynth =  new SfxrSynth();
		private var soundGenParans:SfxrParams = new SfxrParams();
		private var canDouble:Boolean = false;
		public function Player(X:Number = 0, Y:Number = 0, SimpleGraphic:Class = null) 
		{
			super(X, Y);
			//createGraphic(12, 20, 0xFF00FF00);
			loadGraphic(doodImg, true, true, 20, 32);
			addAnimation("Idle", [0, 1], 5, true);
			addAnimation("Run", [2, 3, 4, 5, 6, 7, 8, 9], 30, true);
			addAnimation("Jump", [10]);
			acceleration.y = 800;
			drag.x = 750;
			width = 20;
			height = 32;
			maxVelocity.x = 200;
			maxVelocity.y = 400;
			play("Jump");
			
			soundGen.params.setSettingsString("0,,0.1237,,0.182,0.3446,,0.2907,,,,,,0.0067,,,,,1,,,0.031,,0.5");
			soundGen.cacheSound();
		}
		public override function update():void {
			acceleration.x = 0;
			if(canControl){
				if (FlxG.keys.LEFT) {
					acceleration.x = -500;
					facing = LEFT;
				}
				if (FlxG.keys.RIGHT) {
					acceleration.x = 500;
					facing = RIGHT;
				}
				if (FlxG.keys.justPressed("UP") && onFloor) {
					soundGen.play();
					velocity.y = -400;
					canDouble = true;
				}else if (FlxG.keys.justPressed("UP") && canDouble) {
					soundGen.play();
					velocity.y = -300;
					canDouble = false;
				}
			}
			if ((velocity.x < -10 || velocity.x > 10) && Math.abs(velocity.y) <= 10) {
				play("Run");
			}else if (Math.abs(velocity.y) >= 10) {
				play("Jump");
			}else {
				play("Idle");
			}
			super.update();
			if (y > 400) {
				FlxG.fade.start(0xFFFFFFFF, .5, gameOver);
			}
			upScores()
		}
		public function revokeControl():void {
			if(canControl){
				canControl = false;
				Player.numUniverses++;
				soundGen.params.setSettingsString("2,0.434,0.5747,0.2471,0.9523,0.9927,,0.1673,-0.2092,-0.0171,,-0.5822,,0.55,-0.5716,0.7808,0.1554,0.1239,0.9996,-0.0288,-0.0371,0.1316,,0.5");
				soundGen.play();
			}
		}
		private function gameOver():void {
			FlxG.state = new GameOver();
		}
		private function upScores():void {
			Player.Time += FlxG.elapsed;
		}
	}

}