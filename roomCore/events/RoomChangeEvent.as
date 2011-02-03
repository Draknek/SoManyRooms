//Created by Devin Reimer - blog.almostlogical.com
package roomCore.events 
{
	import flash.events.Event;
	
	public class RoomChangeEvent extends Event 
	{
		public static const ROOM_BEGINS:String = "roomBegins";
		public static const ROOM_FINISHED:String = "roomFinished";
		
		public function RoomChangeEvent(type:String) 
		{ 
			super(type, true, false);
		} 
	}
}