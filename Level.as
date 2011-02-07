package  
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.utils.*;
	import net.flashpunk.tweens.misc.*;
	import flash.text.*;
	import roomCore.RoomCoreLogic;

	public class Level extends World
	{
		public var preventInput:Boolean = false;
		
		public var black:Image;
		public var red:Image;
		public var dark:Image;
		public var light:Image;
		
		[Embed(source="audio/bg.mp3")]
		public static var BgMusic:Class;
		
		[Embed(source="audio/door.mp3")]
		public static var DoorSfx:Class;
		
		[Embed(source="audio/reset.mp3")]
		public static var ResetSfx:Class;
		
		[Embed(source = 'fonts/Frank Knows.ttf', embedAsCFF="false", fontFamily = 'gargoylefont')]
		public static var GargoyleFont:Class;
		
		public var musicSfx:Sfx;
		public var doorSfx:Sfx;
		public var resetSfx:Sfx;
		
		public var player:Entity;
		public var sprite:Spritemap;
		public var walk:Number = 0;
		
		public const DOOR_COUNT:int = 10;
		
		public var doors:Array = [];
		public var text:Array = [];
		public var openDoorText:Array = [];
		public var gargoyles:Array = [];
		
		public var startX:Number = 20;
		
		public var time:Number = 0;
		
		public override function begin():void 
		{
			RoomCoreLogic.roomBegins(); //this tells container room has now begun
			
			camera.y = 22;
			
			super.begin();
			
			musicSfx = new Sfx(BgMusic);
			doorSfx = new Sfx(DoorSfx);
			resetSfx = new Sfx(ResetSfx);
			
			musicSfx.loop();
			doorSfx.play();
			
			black = Image.createRect(640, 480, 0x000000); // for fading in/out
			red = Image.createRect(640, 480, 0xFF0000); // for choosing the wrong door
			
			dark = Image.createRect(640, 480, 0x000000); // for lighting
			dark.alpha = 0.9;
			dark.blend = "hardlight";
			
			addGraphic(dark, -25);
			
			light = new Image(Assets.get("light"));
			light.color = 0xf1f09a;
			light.centerOO();
			light.alpha = 0.5;
			//light.blend = "hardlight";
			
			light.x = 270;
			light.y = 240;
			
			//addGraphic(light, -24);
			light.render(dark.source, FP.zero, camera);
			
			black.scrollX = 0;
			dark.scrollX = 0;
			red.scrollX = 0;
			black.scrollY = 0;
			dark.scrollY = 0;
			red.scrollY = 0;
			
			red.alpha = 0;
			
			addGraphic(black, -100);
			addGraphic(red, -101);
			
			var bg:Backdrop = new Backdrop(Assets.get("doorway"), true, false);
			bg.y = 22;
			
			addGraphic(bg);
			
			addGraphic(new Stamp(Assets.get("doorway_start"), 0, 22));
			
			var entryDoor:Image = new Image(Assets.get("door"));
			entryDoor.x = 7;
			entryDoor.y = 480 - 163;
			entryDoor.smooth = true;
			
			addGraphic(entryDoor);
			
			entryDoor.scaleX = 0.8;
			
			for (var i:int = 0; i <= DOOR_COUNT; i++) {
				var e:Entity = new Entity;
				e.width = 114;
				e.height = 163;
				e.x = 135 + 7 + i*135;
				e.y = 480 - e.height;
				e.graphic = new Image(Assets.get("door"));
				Image(e.graphic).smooth = true;
				
				if (i == 0) e.graphic.visible = false;
				
				doors.push(e);
				
				add(e);
				
				var plinth:Spritemap = new Spritemap(Assets.get("plinth"), 78, 51);
				plinth.frame = i;
				plinth.x = e.x - (plinth.width - e.width)*0.5;
				plinth.y = e.y - plinth.height - 5 - FP.rand(10);
				addGraphic(plinth);
				
				if (i == 0) plinth.y = 400;
				
				var gargoyle:Stamp = new Stamp(Assets.get("gargoyle" + (FP.rand(4) + 1)));
				
				gargoyle.x = e.x - (gargoyle.width - e.width)*0.5;
				gargoyle.y = plinth.y - gargoyle.height + 20;
				
				addGraphic(gargoyle);
				
				gargoyles[i] = gargoyle;
				
				var t:Text = new Text("", 0, 16 + 22, {align:"center", width:640, font:"gargoylefont", size:((i == 0) ? 24 : 32), color: 0xDD2222});
				
				t.scale = 0;
				
				text.push(t);
				
				addGraphic(t, -50);
				
				t = new Text("Z\nto open", 0, 480 - 160 + 8, {align:"center", alpha: 0});
				t.x = e.x - (t.width - e.width)*0.5;
				
				openDoorText.push(t);
				
				addGraphic(t, -50);
			}
			
			text[0].text =  "Just one door is all it takes\nTo send you on your way\nBut heed our warning truths and lies\nOr here you might well stay";
			
			text[1].text +=  "You want to go through door 4"; // false
			text[2].text +=  "All even numbered gargoyles tell the truth"; // false
			text[3].text +=  "Every gargoyle which is a multiple of three is lying"; // false: impossible
			text[4].text +=  "This door is the way out!"; // false
			text[5].text +=  "Door 6 is the only safe one"; // false
			text[6].text +=  "All odd numbered gargoyles are lying"; // true
			text[7].text +=  "The exit has a lying gargoyle above it"; // false
			text[8].text +=  "The exit has a truthful gargoyle above it"; // true
			text[9].text +=  "Gargoyles seven and eight are both liars"; // false: impossible
			text[10].text += "The exit is door 3"; // false
			
			for (i = 0; i <= 10; i++) {
				text[i].centerOO();
			}
			
			player = new Entity;
			player.width = 80;
			player.height = 125;
			player.x = startX + player.width*0.5;
			player.y = 480 - player.height;
			
			sprite = new Spritemap(Assets.get("player"), player.width, player.height);
			sprite.x = -30;
			
			player.graphic = sprite;
			
			add(player);
			
			FP.tween(black, {alpha: 0}, 120);
			
			FP.tween(entryDoor, {scaleX: 1.0}, 300);
		}
		
		public override function update():void 
		{
			var i:int;
			
			time++;
			
			dark.source.fillRect(dark.source.rect, 0xFF000000);
			
			//light.alpha = 0.2 + Math.sin(time / 33.674635) * 0.05;
			
			light.x = player.x;
			light.y = player.y + 40;
			light.scaleX = FP.random * 0.05 + 0.9;
			light.scaleY = FP.random * 0.05 + 0.9;
			light.alpha = 0.5;
			
			light.render(dark.source, FP.zero, camera);
			
			/*for (i = 3; i < 12; i++) {
				light.x = -3 + i* 135;
				light.y = 300;
				light.scaleX = FP.random * 0.03 + 0.4;
				light.scaleY = FP.random * 0.03 + 0.4;
				light.alpha = 0.2;
			
				light.render(dark.source, FP.zero, camera);
			}*/
			
			dark.alpha = 0.7 + Math.sin(time / 600.0) * 0.05;
			
			if (preventInput) return;
			
			var dx:int = 0;
			
			if (Input.check(Key.LEFT)) {
				sprite.flipped = true;
				sprite.x = -50;
				player.x -= 2;
				walk += 0.15;
				dx = -1;
			}
			
			if (Input.check(Key.RIGHT)) {
				sprite.flipped = false;
				sprite.x = -30;
				player.x += 2;
				walk += 0.15;
				dx = 1;
			}
			
			if (dx == 0) {
				walk = 0.8;
			}
			
			sprite.frame = walk % 8;
			
			if (player.x < 30) player.x = 30;
			
			var maxX:Number = doors[10].x + doors[10].width + 15;
			
			if (player.x > maxX - 30) player.x = maxX - 30;
			
			camera.x = player.x - 320;
			
			if (camera.x < 0) camera.x = 0;
			if (camera.x > maxX - 640) camera.x = maxX - 640;
			
			for (i = 0; i <= DOOR_COUNT; i++) {
				text[i].scale -= 0.04;
				if (text[i].scale < 0) text[i].scale = 0;
				
				openDoorText[i].alpha -= 0.05;
				Image(doors[i].graphic).scaleX = 1.0;
				
				if (doors[i].collidePoint(doors[i].x, doors[i].y, player.x, player.y)) {
					text[i].scale += 0.07;
					if (text[i].scale > 1) text[i].scale = 1;
					
					if (i != 0)
					{
						Image(doors[i].graphic).scaleX = 0.96;
						openDoorText[i].alpha += 0.1;
						if (Input.pressed(Key.Z) || Input.pressed(Key.X)) {
							openDoor(i);
						}
					}
				}
				
				
				var targetX:Number = (i == 0) ? 180 : camera.x+320;
				var targetY:Number = (i == 0) ? 180 : 100;
				text[i].x = FP.lerp(doors[i].x + doors[i].width*0.5, targetX, text[i].scale*text[i].scale);
				text[i].y = FP.lerp(gargoyles[i].y + 40, targetY, text[i].scale*text[i].scale);
			}
		}
		
		public function openDoor (i:int):void
		{
			doorSfx.play();
			
			preventInput = true;
			
			// Note that 300 = 5s = length of door sfx
			
			FP.tween(doors[i].graphic, {scaleX: 0.8}, 300);

			if (i == 8) { // Right door
				FP.tween(black, {alpha: 1}, 300);
				FP.tween(musicSfx, {volume: 0}, 300, {complete: RoomCoreLogic.roomComplete});
			} else { // Wrong door
				FP.tween(black, {alpha: 1}, 300);
				FP.tween(musicSfx, {volume: 0}, 300, {complete: reset});
			}
		}
		
		public function reset ():void
		{
			FP.tweener.clearTweens();
			
			resetSfx.play();
			
			red.alpha = 1;
			black.alpha = 0;
			
			player.x = startX;
			
			preventInput = false;
			
			for (var i:int = 0; i <= DOOR_COUNT; i++) {
				text[i].scale = 0;
				openDoorText[i].alpha = 0;
			}
			
			FP.tween(red, {alpha: 0}, 30);
			FP.tween(musicSfx, {volume: 1}, 30);
		}
		
		//Note: Do not put your clean up code somewhere else
		override public function end():void
		{
			removeAll();
			musicSfx.stop();
			doorSfx.stop();
		}
		
	}

}
