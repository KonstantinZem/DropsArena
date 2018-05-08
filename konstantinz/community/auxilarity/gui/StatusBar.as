package konstantinz.community.auxilarity.gui{
	//Конечно очень простой класс, но я хочу вынести все платформозависимые вещи в отдельные модули для более легкого переноса
	
	import flash.display.Sprite;
    import flash.text.*; 

	public class StatusBar extends Sprite{
		private var statusBarText:TextField;
		public var texSource:String;
	
		function StatusBar(){
		
			statusBarText = new TextField();
			statusBarText.autoSize = TextFieldAutoSize.LEFT;
			statusBarText.text = '...'
			addChild(statusBarText);
		}
		
		public function setBarAt(stBarX, stBarY){
			this.x = stBarX;
			this.y = stBarY;
			}
		
		public function setTexSource(ts){
			statusBarText.htmlText = '';
			texSource = ts;
			statusBarText.htmlText = texSource;
			}

	}

}
