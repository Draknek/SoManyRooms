package
{
	import net.flashpunk.*;
	import roomCore.RoomCoreLogic;
	
	[SWF(width = "640", height = "480", backgroundColor="#000000")]
	public class Main extends Engine
	{
		public function Main () 
		{
			super(640, 480, 60, true);
			
			RoomCoreLogic.init(this);
			
			FP.world = new Level();
		}
	}
}
