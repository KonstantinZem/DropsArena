package{
	
	import flash.display.Sprite
	import flash.text.*; 
	import konstantinz.plugins.cover
	import konstantinz.community.auxilarity.*
	
	public class CoverMain extends Sprite{
		public var plEntry:Object
		private var myTextBox:TextField; 
		private var errors:Object = new ModelErrors()
		
		public function CoverMain(){
			
			plEntry = new cover()

			plEntry.pluginEvent.addEventListener(ModelEvent.FINISH, jobeDone)
			if(plEntry.root==null){
				msg = errors.pluginStartAlong;
				myTextBox = new TextField(); 
				addChild(myTextBox); 
				myTextBox.htmlText = msg;
				myTextBox.x = 100
				myTextBox.y = 100
				myTextBox.width = 400
				}
			}
		
		private function jobeDone(e:ModelEvent):void{
			plEntry.pluginEvent.removeEventListener(ModelEvent.FINISH, jobeDone)
			plEntry = null
			}
		}
	
	}
