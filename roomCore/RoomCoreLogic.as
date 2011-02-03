//Created by Devin Reimer - blog.almostlogical.com
package roomCore 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import roomCore.events.RoomChangeEvent;
	
	public class RoomCoreLogic
	{
		private static var disp:EventDispatcher;
		private static var hasRoomBeginsBeenCalled:Boolean = false;
		private static var hasRoomCompleteBeenCalled:Boolean = false;
		
		//called at the very start, pass in a reference to this from the top level class
		public static function init(self:DisplayObjectContainer):void
		{
			disp = new EventDispatcher(self);
		}
		
		//the moment the game is beginning call this (must be after init called and game has been added to stage)
		public static function roomBegins():void
		{
			if (!hasRoomBeginsBeenCalled && checkEventDispatchAvailablity())
			{
				disp.dispatchEvent(new RoomChangeEvent(RoomChangeEvent.ROOM_BEGINS));
				hasRoomBeginsBeenCalled = true;
				trace("Room Begins");
			}
		}
		
		//called at the very end of the game after the screen is completely black
		public static function roomComplete():void
		{
			if (!hasRoomCompleteBeenCalled && checkEventDispatchAvailablity())
			{
				disp.dispatchEvent(new RoomChangeEvent(RoomChangeEvent.ROOM_FINISHED));
				hasRoomCompleteBeenCalled = true;
				trace("Room Complete");
				clear(); //clearing up dispatcher
			}
		}
		
		private static function checkEventDispatchAvailablity():Boolean
		{
			if (disp == null) { trace("Need to call init and pass in this before calling roomBegins or roomComplete"); }
			
			return disp!=null;
		}
		
		public static function clear():void
		{
			disp = null;
		}
	}
}