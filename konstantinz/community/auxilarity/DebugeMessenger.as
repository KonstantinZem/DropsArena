package konstantinz.community.auxilarity{
	public class DebugeMessenger{//Вывод отладочных сообщений
		private var debugeLevel:String
		private var messageMark:String
		
		public function DebugeMessenger(dbgLevel:String = '3'){
			debugeLevel = dbgLevel;
			messageMark = '';
			}
		
		public function message(messageString:String, messageLevel:int = 3):void{
			if(messageLevel <= int(debugeLevel)){
				trace('[' + messageMark + ']: ' + messageString + ';' + '\n');
			}
			}
		
		public function setMessageMark(mark:String):void{
			messageMark = mark;
			}
		
		}
}
