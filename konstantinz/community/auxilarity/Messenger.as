//Класс предназначен для вывода отладочных сообщений и рассылки статистических сообщенийдля обработки их другими компонентами
package konstantinz.community.auxilarity{
	
   import flash.events.Event; 
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import konstantinz.community.auxilarity.*;
   
	public class Messenger extends EventDispatcher{
		
		private var debugeLevel:String;
		
		public var messageMark:String;
		private var modelEvent:ModelEvent;
		
		public static const HAVE_EXT_DATA:String = 'have_ext_data';
		
		public var msg:String;
		
		
		public function Messenger(dbgLevel:String = '3'):void{
			debugeLevel = dbgLevel;
			messageMark = '';
			modelEvent = new ModelEvent();//Будем брать основные константы от сюда
			}
		
		public function message(messageString:String, messageLevel:int = 3):void{
			msg = messageString;
			if(messageLevel == modelEvent.STATISTIC_MARK){
			
				dispatchEvent(new Event(Messenger.HAVE_EXT_DATA));//Посылаем статистику в виде сообщения, ведь неизвестно, какой компонент и как ее будет обрабатывать
			}
			if(messageLevel <= int(debugeLevel)){
				if(messageLevel == modelEvent.ERROR_MARK){//Если пришло сообщение об ошибке
					trace('[' + messageMark + ' Error!]: ' + messageString + ';' + '\n');
					msg = '';
					}else{
				trace('[' + messageMark + ']: ' + messageString + ';' + '\n');
			}
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
