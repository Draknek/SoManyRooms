package  
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.utils.*;
	import roomCore.RoomCoreLogic;

	public class Level extends World
	{
		public var isRoomComplete:Boolean = false;
		
		public var black:Image;
		public var red:Image;
		
		[Embed(source="audio/bg.mp3")]
		public static var BgMusic:Class;
		
		[Embed(source="audio/door.mp3")]
		public static var DoorSfx:Class;
		
		public var musicSfx:Sfx;
		public var doorSfx:Sfx;
		
		override public function begin():void 
		{
			RoomCoreLogic.roomBegins(); //this tells container room has now begun
			
			super.begin();
			
			musicSfx = new Sfx(BgMusic);
			doorSfx = new Sfx(DoorSfx);
			
			musicSfx.loop();
			doorSfx.play();
			
			black = Image.createRect(640, 480, 0x000000); // for fading in/out
			red = Image.createRect(640, 480, 0xFF0000); // for choosing the wrong door
			
			var text:Text = new Text("Press 'X' to Win!");
			add(new Entity((FP.width - text.width) / 2, 100, text));
			
			addGraphic(black, -100);
			
			FP.tween(black, {alpha: 0}, 120);
		}
		
		override public function update():void 
		{
			trace(black.alpha);
			super.update();
			if (!isRoomComplete)
			{
				//FOLLOWING CODE IS NOT REQUIRED JUST AN EXAMPLE
				if (Input.check(Key.X))
				{
					roomComplete();
				}
				//END OF NOT REQUIRED CODE
			}
		}
		
		//room complete but not yet all black
		public function roomComplete():void
		{
			if (!isRoomComplete) //to prevent fade from being called a bunch of times
			{
				// Door sfx is 5 seconds long
				
				isRoomComplete = true;
				FP.tween(black, {alpha: 1}, 300);
				FP.tween(musicSfx, {volume: 0}, 300);
				
				doorSfx.play();
			}
		}
		
		public function screenFadeComplete():void
		{
			if (isRoomComplete) //room complete and screen black
			{
				notifyRoomCompleteAndDisable();
			}
		}
		
		//call function once room is complete and you want to notify container
		//screen should already be black before calling this function
		public function notifyRoomCompleteAndDisable():void
		{
			RoomCoreLogic.roomComplete(); //notifies container room is complete, the container will then remove from stage
			active = false;
			FP.screen.color = 0x000000; //just makes sure the screen is black when everything is removed
			//Note: Do not put clean up code in here, put it in end instead, as this can be skipped if the person skips level, but destroy will not be skipped
		}
		
		//this gets automatically called at the very end, if you have any clean up code (ex: remaininingEventListeners) put them in here
		//Note: Do not put your clean up code in the roomComplete
		override public function end():void 
		{
			removeAll();
			//Put clean up code here if any
		}
		
	}

}
