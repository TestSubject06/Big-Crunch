package { 
	import org.flixel.FlxPreloader; 
	
	public class Preloader extends FlxPreloader { 
		
		public function Preloader():void {	
			className = "Main";
			//myURL = "2bam.com";
			super();	
		}
	}
}
