//Класс предназначен для вывода отладочных сообщений и рассылки статистических сообщенийдля обработки их другими компонентами
package konstantinz.community.auxilarity{
	
   import flash.events.Event; 
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   
	public class Messenger extends EventDispatcher{
		
		private const EXT_DATA_MARK:int = 10;//Значение messageLevel при котором поступившую информацию нужно посылать сообщением
		private var debugeLevel:String;
		
		public var messageMark:String;
		
		public static const HAVE_EXT_DATA:String = 'have_ext_data';
		public var msg:String;
		
		public function Messenger(dbgLevel:String = '3'):void{
			debugeLevel = dbgLevel;
			messageMark = '';
			}
		
		public function message(messageString:String, messageLevel:int = 3):void{
			msg = messageString;
			if(messageLevel <= int(debugeLevel)){
				if(messageLevel ==0){//Если пришло сообщение об ошибке
					trace('[' + messageMark + ' Error!]: ' + messageString + ';' + '\n');
					}else{
				trace('[' + messageMark + ']: ' + messageString + ';' + '\n');
			}
			}
			if(messageLevel == EXT_DATA_MARK){
			
				dispatchEvent(new Event(Messenger.HAVE_EXT_DATA));//Посылаем статистику в виде сообщения, ведь неизвестно, какой компонент и как ее будет обрабатывать
			}
			}
		
		public function setMessageMark(mark:String):void{
			messageMark = mark;
			}
		
		public function setDebugLevel(dbgLevel:String):void{
				debugeLevel = dbgLevel;
			}
		
		}
}
