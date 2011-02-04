package  
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.utils.*;
	import flash.text.*;
	import roomCore.RoomCoreLogic;

	public class Level extends World
	{
		public var preventInput:Boolean = false;
		
		public var black:Image;
		public var red:Image;
		
		[Embed(source="audio/bg.mp3")]
		public static var BgMusic:Class;
		
		[Embed(source="audio/door.mp3")]
		public static var DoorSfx:Class;
		
		[Embed(source="audio/reset.mp3")]
		public static var ResetSfx:Class;
		
		[Embed(source = 'fonts/Frank Knows.ttf', embedAsCFF="false", fontFamily = 'gargoylefont')]
		public static var GargoyleFont:Class;
		
		[Embed(source="images/doorway.jpg")]
		public static var BgGfx:Class;
		
		[Embed(source="images/door.png")]
		public static var DoorGfx:Class;
		
		[Embed(source="images/player.png")]
		public static var PlayerGfx:Class;
		
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
		
		public var startX:Number = 25;
		
		public override function begin():void 
		{
			RoomCoreLogic.roomBegins(); //this tells container room has now begun
			
			super.begin();
			
			musicSfx = new Sfx(BgMusic);
			doorSfx = new Sfx(DoorSfx);
			resetSfx = new Sfx(ResetSfx);
			
			musicSfx.loop();
			doorSfx.play();
			
			black = Image.createRect(640, 480, 0x000000); // for fading in/out
			red = Image.createRect(640, 480, 0xFF0000); // for choosing the wrong door
			
			black.scrollX = 0;
			red.scrollX = 0;
			
			red.alpha = 0;
			
			addGraphic(black, -100);
			addGraphic(red, -101);
			
			var bg:Backdrop = new Backdrop(BgGfx, true, false);
			bg.y = 480 - bg.height;
			
			addGraphic(bg);
			
			for (var i:int = 0; i <= DOOR_COUNT; i++) {
				var e:Entity = new Entity;
				e.width = 114;
				e.height = 163;
				e.x = 270 + 7 + i*135;
				e.y = 480 - e.height;
				e.graphic = new Image(DoorGfx);
				
				doors.push(e);
				
				add(e);
				
				var t:Text = new Text("", 0, 16 + 22, {align:"center", width:640, scrollX:0, alpha: 0, font:"gargoylefont", size:24, color: 0xFF4444});
				
				text.push(t);
				
				addGraphic(t);
				
				t = new Text("Press Z\nto open door " + i, 0, 480 - 160, {align:"center", alpha: 0});
				t.x = e.x - (t.width - e.width)*0.5;
				
				openDoorText.push(t);
				
				addGraphic(t);
			}
			
			text[0].text =  "Just one door is all it takes\nTo send you on your way\nBut heed our warning truths and lies\nOr here you might well stay";
			
			text[1].text +=  "You want to go through door 4"; // false
			text[2].text +=  "All even numbered gargoyles tell the truth"; // false
			text[3].text +=  "Every gargoyle which is a multiple of three is lying"; // false: impossible
			text[4].text +=  "This door is the way out!"; // false
			text[5].text +=  "Door 6 is the only safe one"; // false
			text[6].text +=  "All odd numbered gargoyles are lying"; // true
			text[7].text +=  "The safe door has a lying gargoyle above it"; // false
			text[8].text +=  "The safe door has a truthful gargoyle above it"; // true
			text[9].text +=  "Gargoyles seven and eight are both liars"; // false: impossible
			text[10].text += "The exit is door 3"; // false
			
			player = new Entity;
			player.width = 80;
			player.height = 125;
			player.x = startX + player.width*0.5;
			player.y = 480 - player.height;
			
			sprite = new Spritemap(PlayerGfx, player.width, player.height);
			sprite.x = -30;
			
			player.graphic = sprite;
			
			add(player);
			
			FP.tween(black, {alpha: 0}, 120);
		}
		
		public override function update():void 
		{
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
			
			if (player.x < 0) player.x = 0;
			
			camera.x = player.x - 320;
			
			if (camera.x < 0) camera.x = 0;
			
			for (var i:int = 0; i <= DOOR_COUNT; i++) {
				text[i].alpha -= 0.05;
				openDoorText[i].alpha -= 0.05;
				
				if (doors[i].collidePoint(doors[i].x, doors[i].y, player.x, player.y)) {
					text[i].alpha += 0.1;
					
					if (i != 0)
					{
						openDoorText[i].alpha += 0.1;
						if (Input.pressed(Key.Z) || Input.pressed(Key.X)) {
							openDoor(i);
						}
					}
				}
			}
		}
		
		public function openDoor (i:int):void
		{
			doorSfx.play();
			
			preventInput = true;
			
			// Note that 300 = 5s = length of door sfx

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
				text[i].alpha = 0;
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
