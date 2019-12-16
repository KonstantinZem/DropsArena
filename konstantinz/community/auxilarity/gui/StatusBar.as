package konstantinz.community.auxilarity.gui{
	//Конечно очень простой класс, но я хочу вынести все платформозависимые вещи в отдельные модули для более легкого переноса
	
	import flash.display.Sprite;
    import flash.text.*; 
    import flash.events.TimerEvent; 
	import flash.events.Event; 
	import flash.utils.*;
    import konstantinz.community.auxilarity.*;

	public class StatusBar extends Sprite{
		private const MAX_MESSAGE_LENGTH:int = 120;
		private var statusBarText:TextField;
		private var spacer:String;
		private var msgString:String;
		private var debugLevel:String;
		private var shotStrings:Array;
		private var messenger:Messenger;
		private var modelEvent:ModelEvent;
		private var stringsCounter:int;
		private var timer:Timer
		
		public var texSource:String;
	
		function StatusBar(dbgLevel:String = '3'){
			modelEvent = new ModelEvent();//Будем брать основные константы от сюда
			debugLevel = dbgLevel;
			messenger = new Messenger(debugLevel);
			messenger.setMessageMark('Status Bar');
			msgString = "Status Bar loaded";
			messenger.message(msgString, modelEvent.INIT_MSG_MARK);
			
			spacer = ';'
			
			statusBarText = new TextField();
			statusBarText.autoSize = TextFieldAutoSize.LEFT;
			statusBarText.text = '...';
			addChild(statusBarText);
			
			stringsCounter = 0;
			
			timer = new Timer(3000);
			timer.addEventListener(TimerEvent.TIMER, nextString);
			
		}
		
		public function setSpacer(newSpacer:String):void{
			spacer = newSpacer;
			msgString = "New spacer is " + spacer;
			messenger.message(msgString, modelEvent.INFO_MARK);
		};
		
		public function setBarAt(stBarX:int, stBarY:int):void{
			this.x = stBarX;
			this.y = stBarY;
			}
		
		public function setTexSource(ts:String):void{
			timer.reset();
			var substrings:Array = new Array();
			var sbstrLength:int;
			var strNumber:int = 0;
			shotStrings = new Array();
			shotStrings[0] = '';
			
			substrings = ts.split(spacer);
			sbstrLength = substrings.length;
			
			for(var i:int = 0; i < sbstrLength; i++){
				if(shotStrings[strNumber].length >  MAX_MESSAGE_LENGTH){
					strNumber++;
					shotStrings[strNumber] = ' ';
					}
				shotStrings[strNumber]+=substrings[i] + ' ';
				}
				timer.start();
			}
			
		public function clear():void{
			statusBarText.text = '...';
			removeChild(statusBarText);
			}
			
		private function nextString(event:TimerEvent):void{
			statusBarText.htmlText = shotStrings[stringsCounter];
			if(stringsCounter == shotStrings.length - 1){
				stringsCounter = 0;
				}else{
					stringsCounter++;
					}
			};

	}

}
