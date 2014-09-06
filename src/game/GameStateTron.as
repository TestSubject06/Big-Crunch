package game 
{
	import flash.text.engine.TextLineMirrorRegion;
	import org.flixel.FlxEmitter;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxTileblock;
	import org.flixel.FlxTilemap;
	import org.flixel.FlxU;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author Zack Tarvit & Ed Dubois
	 */
	public class GameStateTron extends FlxState 
	{
		[Embed(source = '../assets/TRPlatform.png')] private var stoneBlock:Class;
		[Embed(source = '../assets/DerpCycle.png')] private var fallingBlock:Class;
		[Embed(source = '../assets/Static.png')] private var Static:Class;
		[Embed(source = '../assets/FallingTile.png')] private var fallingTile:Class;
		[Embed(source = '../assets/DeTR.png')] private var imgDebris:Class;
		[Embed(source = '../assets/TRbg.png')] private var VoidBG:Class;
		
		private var soundGen:SfxrSynth = new SfxrSynth();
		private var firstRun:Boolean = true;
		private var blocksGroup:FlxGroup;
		private var orbsCont:FlxGroup;
		private var player:Player;
		private var point:Finger;
		private var blockoffset:int;
		private var nexus:Nexus;
		private var blackTiles:FlxTilemap;
		private var rockRain:FlxEmitter;
		private var brixEmitter:FlxEmitter;
		private var destructionEmitter1:FlxEmitter;
		private var destructionEmitter2:FlxEmitter;
		private var timer:Number = 0;
		private var wallTearTimer:Number = 0;
		private var blockDropTimer:Number = 0;
		private var staticSprite:FlxSprite;
		private var fallingBrick:FlxSprite;
		private var backTiles:FlxGroup;
		private var fallingGroup:FlxGroup;
		private var mapData:String;
		//Block Destruction
		private var wreckBlocks:Boolean = false;
		private var blockSmashTiimer:Number = 0;
		private var wallCrushTimer:Number = 0;
		private var useFirstEmitter:Boolean = true;
		
		public function GameStateTron() 
		{
			super();
			
			//Player
			player = new Player();
			point = new Finger();
			
			//Static Background present in all universes
			staticSprite = new FlxSprite(0, 0);
			staticSprite.loadGraphic(Static, true, false, 320, 240);
			staticSprite.scrollFactor.x = staticSprite.scrollFactor.y = 0;
			staticSprite.addAnimation("Static", [0, 1, 2, 3], 30, true);
			staticSprite.play("Static");
			add(staticSprite);
			
			//Groups for layering
			backTiles = new FlxGroup();
			blocksGroup = new FlxGroup();
			orbsCont = new FlxGroup();
			generateGround();
			
			//Background Tiles
			mapData = "";
			blackTiles = new FlxTilemap();
			for (var i:int = 0; i < 20; i++) {
				for (var k:int = 0; k < FlxG.width; k++) {
					mapData += Math.ceil(FlxU.random() * 1).toString() + ",";
				}
				mapData += "\n"
			}
			blackTiles.loadMap(mapData, VoidBG, 16, 16);
			blackTiles.x = -64;
			blackTiles.y = -32;
			blackTiles.scrollFactor.x = blackTiles.scrollFactor.y = .1;
			add(blackTiles);
			
			//Falling Blocks emitter
			brixEmitter =  new FlxEmitter(0, 0);
			brixEmitter.setSize(400, 10);
			brixEmitter.createSprites(fallingBlock, 30, 32, false, 0);
			brixEmitter.setXSpeed( -200, -50);
			brixEmitter.setYSpeed( 100, 20);
			brixEmitter.visible = true;
			brixEmitter.start(false, 1, 0);
			
			//The brick shatter emitters
			destructionEmitter1 = new FlxEmitter();
			destructionEmitter1.createSprites(imgDebris, 40, 16, true);
			destructionEmitter1.setSize(64, 64);
			destructionEmitter1.setXSpeed( -200, 50);
			destructionEmitter1.setYSpeed(-200, 200);
			destructionEmitter2 = new FlxEmitter();
			destructionEmitter2.createSprites(imgDebris, 40, 16, true);
			destructionEmitter2.setSize(64, 64);
			destructionEmitter2.setXSpeed( -200, 50);
			destructionEmitter2.setYSpeed( -200, 200);
			
			//rock Rain
			rockRain = new FlxEmitter();
			for (var i:int = 0; i < 60; i++) {
				var particle:FlxSprite = new FlxSprite();
				particle.createGraphic(3, 3, 0xFF1385C3);
				rockRain.add(particle);
			}
			rockRain.setSize(320, 1);
			rockRain.setXSpeed( -150, -75);
			rockRain.setYSpeed( 100, 200);
			rockRain.scrollFactor.x = rockRain.scrollFactor.y = 0;
			rockRain.gravity = 0;
			
			//The falling foreground brick
			fallingBrick = new FlxSprite();
			fallingBrick.loadGraphic(stoneBlock);
			fallingBrick.visible = false;
			fallingBrick.maxVelocity.x = fallingBrick.maxVelocity.y = 350;
			
			//falling tiles group
			fallingGroup = new FlxGroup();
			fallingGroup.x = -64;
			fallingGroup.y = -32;
			fallingGroup.scrollFactor.x = fallingGroup.scrollFactor.y = .1;
			
			add(fallingGroup);
			add(rockRain);
			add(brixEmitter);
			add(blocksGroup);
			add(fallingBrick);
			add(destructionEmitter1);
			add(destructionEmitter2);
			add(orbsCont);
			add(player);
			add(point);
			
			rockRain.start(false, .1, 0);
			soundGen.params.setSettingsString("3,0.0865,0.2405,0.2471,0.625,1,,-0.019,0.019,,,-0.077,,0.55,-0.5716,0.5479,0.2119,0.173,0.9996,-0.0288,,0.1316,,0.5");
			soundGen.play();
		}
		
		public override function update():void {
			super.update();
			point.x = player.x - 44;
			point.y = player.y - 80;
			point.facing = FlxSprite.LEFT;
			if (firstRun) {
				FlxG.flash.start(0xFFFFFFFF, 1);
				firstRun = false;
			}
			brixEmitter.x = player.x-50;
			brixEmitter.y = player.y - 150;
			rockRain.x = player.x - 50;
			rockRain.y = player.y - 150;
			FlxG.follow(player, .8);
			timer += FlxG.elapsed;
			if (timer > 10) {
				if(brixEmitter.delay > .2)
					brixEmitter.delay -= .1;
				timer = 0;
			}
			wallTearTimer += FlxG.elapsed;
			if (wallTearTimer > 1) {
				trashScreen();
				wallTearTimer = 0;
			}
			blockDropTimer += FlxG.elapsed;
			if (blockDropTimer > 2) {
				dropBlock();
				blockDropTimer = 0;
			}
			if (FlxG.keys.justPressed("A")) {
				trashScreen();
			}
			if (FlxG.keys.justPressed("S")) {
				dropBlock();
			}
			if (blockoffset - player.x < 200) {
				generateGround();
			}
			FlxG.followBounds(player.x - 300, player.y - 200, player.x + 300, player.y + 200, true);
			//FlxU.setWorldBounds(player.x - 300, player.y - 200, player.x + 300, player.y + 200);
			FlxU.overlap(blocksGroup, fallingBrick, crush);
			FlxU.collide(player, blocksGroup);
			FlxU.overlap(player, nexus, catchPlayer);
			
			if (wreckBlocks) {
				blockDropTimer = 0;
				blockSmashTiimer += FlxG.elapsed;
				if (blockSmashTiimer > .5) {
					blockSmashTiimer = 0;
					if(useFirstEmitter && blocksGroup.members[0] != null){
						destructionEmitter1.x = blocksGroup.members[0].x;
						destructionEmitter1.y = blocksGroup.members[0].y;
						destructionEmitter1.start();
						blocksGroup.remove(blocksGroup.members[0], true);
						useFirstEmitter = false;
						FlxG.flash.start(0xFFBEFEFE, .2);
					}else if(blocksGroup.members[0] != null) {
						destructionEmitter2.x = blocksGroup.members[0].x;
						destructionEmitter2.y = blocksGroup.members[0].y;
						destructionEmitter2.start();
						blocksGroup.remove(blocksGroup.members[0], true);
						useFirstEmitter = true;
						FlxG.flash.start(0xFFBEFEFE, .2);
					}else {
						FlxG.fade.start(0xFFFFFFFF, 1, changeScene);
					}
					soundGen.params.setSettingsString("3,,0.2782,0.2704,0.418,0.0817,,0.212,,,,-0.4049,0.872,,,,,,1,,,,,0.5");
					soundGen.play();
				}
				wallCrushTimer += FlxG.elapsed;
				if (wallCrushTimer > .05) {
					trashScreen();
					wallCrushTimer = 0;
				}
			}
		}
		
		private function changeScene():void {
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
		}
		
		private function catchPlayer(object1:FlxSprite, object2:FlxSprite):void {
			Nexus(object2).grabPlayer(Player(object1));
			wreckBlocks = true;
		}
		
		private function crush(object1:FlxObject, object2:FlxObject):void {
			destructionEmitter1.x = object1.x;
			destructionEmitter1.y = object1.y;
			destructionEmitter1.start(true, 5);
			object1.kill();
			destructionEmitter2.x = object1.x;
			destructionEmitter2.y = object1.y;
			destructionEmitter2.start(true, 5);
			object2.solid = false;
			object2.visible = false;
			FlxG.quake.start(.02, .3);
			FlxG.flash.start(0xFFBAFEFE, .2);
			soundGen.params.setSettingsString("3,,0.2782,0.2704,0.418,0.0817,,0.212,,,,-0.4049,0.872,,,,,,1,,,,,0.5");
					soundGen.play();
		}
		
		private function dropBlock():void {
			fallingBrick.velocity.x = fallingBrick.velocity.y = 0;
			fallingBrick.visible = true;
			fallingBrick.solid = true;
			fallingBrick.x = player.x + 300;
			fallingBrick.y = player.y - 250;
			fallingBrick.angularVelocity = -((FlxU.random()*120)+60);
			fallingBrick.acceleration.y = 400;
			fallingBrick.velocity.x = -(FlxU.random() * 150 + 50);
		}
		
		private function generateGround():void {
			//Spawn a new chunk
			var setHeight:int = Math.floor(FlxU.random() * 92)+36;
			for (var i:int = 0; i < Math.ceil(FlxU.random() * 9); i++) {
				if (FlxU.random() * 100 < 5) {
					blockoffset += 32;
				}else {
					var block:FlxSprite = FlxSprite(blocksGroup.getFirstAvail());
					if (block != null) {
						block.solid = true;
						block.active = true;
						block.visible = true;
						block.dead = false;
						block.exists = true;
					}else {
						block = new FlxSprite(0, 0, stoneBlock);
						blocksGroup.add(block);
						block.fixed = true;
					}
					block.x = blockoffset;
					block.y = setHeight;
					blockoffset += 32;
				}
			}
			if (blockoffset > 8000 && FlxU.random() * 100 < 100) {
				if(nexus == null){
					nexus = new Nexus(orbsCont, blockoffset - 86, setHeight - 64);
					add(nexus);
				}
			}
			blockoffset += 64;
			
			//Delete blocks that are over 300 pixels behind the player
			for (var j:int = 0; j < blocksGroup.members.length; j++) {
				if (blocksGroup.members[j].x - player.x < -200) {
					blocksGroup.members[j].solid = false;
					blocksGroup.members[j].active = false;
					blocksGroup.members[j].visible = false;
					blocksGroup.members[j].dead = true;
					blocksGroup.members[j].exists = false;
				}
			}
		}
		private function trashScreen():void {
			var count:int = 0;
			do {
				var randomX:int = Math.floor(FlxU.random() * 30) + (Math.floor((player.x / 16)*.1) - 5);
				var randomY:int = Math.floor(FlxU.random() * 20)
				count++
			}while (blackTiles.getTile(randomX, randomY) == 0 && count < 100 );
			
			if (count < 100){
				blackTiles.setTile(randomX, randomY, 0, true);
				var tmp:FlxSprite = FlxSprite(fallingGroup.getFirstAvail());
				if (tmp != null) {
					tmp.solid = true;
					tmp.active = true;
					tmp.visible = true;
					tmp.dead = false;
					tmp.exists = true;
					tmp.velocity.x = tmp.velocity.y = 0;
				}else {
					tmp = new FlxSprite();
					tmp.loadGraphic(fallingTile, true, false, 16, 16);
					tmp.addAnimation("Flip", [0, 1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1], 30, true);
					fallingGroup.add(tmp, true);
				}
				tmp.acceleration.y = 100+Math.random()*25;
				tmp.acceleration.x = -50 + Math.random() * 25;
				tmp.x = ((randomX) * 16)-64;
				tmp.y = ((randomY) * 16)-32;
				tmp.play("Flip", true);
				
				if (Math.random() > .3) {
					if (blackTiles.getTile(randomX - 1, randomY) != 0) {
						blackTiles.setTile(randomX-1, randomY, 0, true);
						var tmp:FlxSprite = FlxSprite(fallingGroup.getFirstAvail());
						if (tmp != null) {
							tmp.solid = true;
							tmp.active = true;
							tmp.visible = true;
							tmp.dead = false;
							tmp.exists = true;
							tmp.velocity.x = tmp.velocity.y = 0;
						}else {
							tmp = new FlxSprite();
							tmp.loadGraphic(fallingTile, true, false, 16, 16);
							tmp.addAnimation("Flip", [0, 1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1], 30, true);
							fallingGroup.add(tmp, true);
						}
						tmp.acceleration.y = 100+Math.random()*25;
						tmp.acceleration.x = -50 + Math.random() * 25;
						tmp.x = ((randomX-1) * 16)-64;
						tmp.y = ((randomY) * 16)-32;
						tmp.play("Flip", true);
					}
				}
				if (Math.random() > .3) {
					if (blackTiles.getTile(randomX + 1, randomY) != 0) {
						blackTiles.setTile(randomX+1, randomY, 0, true);
						var tmp:FlxSprite = FlxSprite(fallingGroup.getFirstAvail());
						if (tmp != null) {
							tmp.solid = true;
							tmp.active = true;
							tmp.visible = true;
							tmp.dead = false;
							tmp.exists = true;
							tmp.velocity.x = tmp.velocity.y = 0;
						}else {
							tmp = new FlxSprite();
							tmp.loadGraphic(fallingTile, true, false, 16, 16);
							tmp.addAnimation("Flip", [0, 1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1], 30, true);
							fallingGroup.add(tmp, true);
						}
						tmp.acceleration.y = 100+Math.random()*25;
						tmp.acceleration.x = -50 + Math.random() * 25;
						tmp.x = ((randomX+1) * 16)-64;
						tmp.y = ((randomY) * 16)-32;
						tmp.play("Flip", true);
					}
				}
				if (Math.random() > .3) {
					if (blackTiles.getTile(randomX, randomY-1) != 0) {
						blackTiles.setTile(randomX, randomY-1, 0, true);
						var tmp:FlxSprite = FlxSprite(fallingGroup.getFirstAvail());
						if (tmp != null) {
							tmp.solid = true;
							tmp.active = true;
							tmp.visible = true;
							tmp.dead = false;
							tmp.exists = true;
							tmp.velocity.x = tmp.velocity.y = 0;
						}else {
							tmp = new FlxSprite();
							tmp.loadGraphic(fallingTile, true, false, 16, 16);
							tmp.addAnimation("Flip", [0, 1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1], 30, true);
							fallingGroup.add(tmp, true);
						}
						tmp.acceleration.y = 100+Math.random()*25;
						tmp.acceleration.x = -50 + Math.random() * 25;
						tmp.x = ((randomX) * 16)-64;
						tmp.y = ((randomY-1) * 16)-32;
						tmp.play("Flip", true);
					}
				}
				if (Math.random() > .3) {
					if (blackTiles.getTile(randomX, randomY+1) != 0) {
						blackTiles.setTile(randomX, randomY+1, 0, true);
						var tmp:FlxSprite = FlxSprite(fallingGroup.getFirstAvail());
						if (tmp != null) {
							tmp.solid = true;
							tmp.active = true;
							tmp.visible = true;
							tmp.dead = false;
							tmp.exists = true;
							tmp.velocity.x = tmp.velocity.y = 0;
						}else {
							tmp = new FlxSprite();
							tmp.loadGraphic(fallingTile, true, false, 16, 16);
							tmp.addAnimation("Flip", [0, 1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1], 30, true);
							fallingGroup.add(tmp, true);
						}
						tmp.acceleration.y = 100+Math.random()*25;
						tmp.acceleration.x = -50 + Math.random() * 25;
						tmp.x = ((randomX) * 16)-64;
						tmp.y = ((randomY+1) * 16)-32;
						tmp.play("Flip", true);
					}
				}
			}
			
			//Make old ones ready for recycling
			for (var j:int = 0; j < fallingGroup.members.length; j++) {
				if (fallingGroup.members[j].y - player.y > 300) {
					fallingGroup.members[j].solid = false;
					fallingGroup.members[j].active = false;
					fallingGroup.members[j].visible = false;
					fallingGroup.members[j].dead = true;
					fallingGroup.members[j].exists = false;
				}
			}
		}
		
	}

}