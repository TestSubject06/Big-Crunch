package game 
{
	import flash.ui.Mouse;
	import org.flixel.*;
	import org.flixel.data.FlxMouse;
	
	/**
	 * ...
	 * @author Zack Tarvit & Ed Dubois
	 */
	public class GameOver extends FlxState 
	{
		[Embed(source = '../assets/BigCrunch.png')] private var bigCrunch:Class;
		[Embed(source = '../assets/BigCrunchText.png')] private var bigCrunchText:Class;
		[Embed(source = '../assets/PlayButton.png')] private var playButton:Class;
		[Embed(source = '../assets/PlayOver.png')] private var playOver:Class;
		[Embed(source = '../assets/332716_fallin__14.5.2010_.mp3')]private var menuMusic:Class;
		[Embed(source = '../assets/391123_8_Bit_runner_loop.mp3')]private var gameMusic:Class;
		
		
		private var firstRun:Boolean = true;
		private var nexus:NexusMenu;
		private var orbsContainer:FlxGroup;
		private var universes:FlxText;
		private var timeLasted:FlxText;
		private var bleh:FlxSound = new FlxSound();
		public function GameOver() 
		{
			super();
			var bg:FlxSprite = new FlxSprite(0, 0, bigCrunch);
			add(bg);
			orbsContainer = new FlxGroup();
			nexus = new NexusMenu(orbsContainer, (FlxG.width/2) - 32, (FlxG.height/2) - 32);
			add(nexus);
			
			
			FlxG.mouse.load(null);
			FlxG.mouse.show();
			add(orbsContainer);
			var Crunch:FlxSprite = new FlxSprite(50, 20, bigCrunchText);
			add(Crunch);
			var startGame:FlxButton = new FlxButton(101, 202, beginGame);
			//startGame.loadText(new FlxText(0, 0, 100, "start", true), new FlxText(0, 0, 100, "Start"));
			startGame.loadGraphic(new FlxSprite(0, 0, playButton), new FlxSprite(0, 0, playOver));
			add(startGame);
			
			if (Player.numUniverses == 1) {
				universes = new FlxText(0, 90, FlxG.width, "You've Cascaded through " + Player.numUniverses.toString() + " universe,", true);
				timeLasted = new FlxText(0, 110, FlxG.width, "and you survived for " + Math.ceil(Player.Time).toString() + " seconds,", true);
			}else if (Player.numUniverses == 0) {
				universes = new FlxText(0, 90, FlxG.width, "You were immediately crushed into oblivion, ", true);
				timeLasted = new FlxText(0, 110, FlxG.width, "only survivng for " + Math.ceil(Player.Time).toString() + " seconds,", true);
			}else{
				universes = new FlxText(0, 90, FlxG.width, "You've Cascaded through " + Player.numUniverses.toString() + " universes,", true);
				timeLasted = new FlxText(0, 110, FlxG.width, "and you survived for " + Math.ceil(Player.Time).toString() + " seconds,", true);
			}
			universes.setFormat(null, 8, 0xFFFFFF, "center", 0x666666);
			
			
			timeLasted.setFormat(null, 8, 0xFFFFFF, "center", 0x666666);
			
			var funny:FlxText = new FlxText(0, 130, FlxG.width, "because someone divided by 0.", true);
			funny.setFormat(null, 8, 0xFFFFFF, "center", 0x666666);
			
			add(universes);
			add(timeLasted);
			add(funny);
			
			FlxG.music.stop();
			bleh.loadEmbedded(menuMusic, true);
			bleh.play();
		}
		
		override public function update():void {
			super.update();
			if (firstRun) {
				FlxG.flash.start(0xFFFFFFFF, .5);
				firstRun = false;
			}
		}
		
		public function beginGame():void {
			bleh.stop();

			Player.Time = 0;
			Player.numUniverses = 0;
			var level:int = Math.ceil(Math.random()*7)
			if (Math.random() < .5) {
				switch(level) {
					case 1:
					FlxG.state = new GameStateCircutLeft();
					break;
					
					case 2:
					FlxG.state = new GameStateBrickLeft();
					break;
					case 3:
					FlxG.state = new GameStateGrassyLeft();
					break;
					case 4:
					FlxG.state = new GameStateConcreteLeft();
					break;
					case 5:
					FlxG.state = new GameStateNotebookLeft();
					break;
					case 6:
					FlxG.state = new GameStateVoidLeft();
					break;
					case 7:
					FlxG.state = new GameStateTronLeft();
					break;
				}
				
			}else {
				switch(level) {
					case 1:
					FlxG.state = new GameStateCircut();
					break;
					
					case 2:
					FlxG.state = new GameStateBrick();
					break;
					case 3:
					FlxG.state = new GameStateGrassy();
					break;
					case 4:
					FlxG.state = new GameStateConcrete();
					break;
					case 5:
					FlxG.state = new GameStateNotebook();
					break;
					case 6:
					FlxG.state = new GameStateVoid();
					break;
					case 7:
					FlxG.state = new GameStateTron();
					break;
				}
			}
			FlxG.music.loadEmbedded(gameMusic, true);
			FlxG.music.play();
		}
		
	}

}