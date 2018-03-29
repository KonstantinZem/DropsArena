package konstantinz.community.auxilarity{
   
   import flash.events.Event; 
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.net.*
	
	public class ConfigurationContainer extends EventDispatcher{
		public static var LOADED:String = 'loaded';//Так мы говорим, что загрузка файла окнчена и программа может к нему обращаться
		public static var LOADING_ERROR:String = 'loading_error';//Так говорим, что произошла какая то ошибка
		
		private var cfgFileName:String = 'configuration.xml';
		private var myXML:XML;
		private var myXMLURL:URLRequest;
		private var myLoader:URLLoader;
		private var debugLevel:String;
		private var msgStreeng:String;
		private var debugeMessage:DebugeMessenger
		
		function ConfigurationContainer(loadedFileName:String, dbg:String){
			cfgFileName = loadedFileName;
			debugLevel = dbg
			myXML = new XML(); 
			myXMLURL = new URLRequest(cfgFileName); 
			myLoader = new URLLoader(myXMLURL);
			
			myLoader.addEventListener(Event.COMPLETE, xmlLoaded);  
			myLoader.addEventListener(IOErrorEvent.IO_ERROR, onError)
			
			debugLevel = 'true';
			
			}
		
		private function xmlLoaded(event:Event):void { //Загружаем файл
			myXML = XML(myLoader.data);
			dispatchEvent(new Event(ConfigurationContainer.LOADED))  
			removeListeners();//Убираем уже ненужные листенеры
			
			debugLevel = getOption('main.debugLevel');
			debugeMessage = new DebugeMessenger(debugLevel);
			debugeMessage.setMessageMark('Options container');
			
				msgStreeng = 'Configuration file ' + cfgFileName + ' has loaded';
				debugeMessage.message(msgStreeng, 1)
			
			
		}
		
		
		private function onError(event:IOErrorEvent):void{//Если загрузить XML файл не удалось
			dispatchEvent(new Event(ConfigurationContainer.LOADING_ERROR))
			removeListeners()//Убираем уже ненужные листенеры
			}
			
		private function removeListeners():void{
			myLoader.removeEventListener(Event.COMPLETE, xmlLoaded);
			myLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError)
			}
		
		public function getOption(optionPath:String):String{//С помощью этого вызова программа будет получать от класса запрашиваемые опции
			var parsedPath:Array;
			var optionValue:String;
			
			parsedPath = parsePathString(optionPath)//Разбираем переданную строку на массив из слов
			
			optionValue = displayXML(myXML, 0, parsedPath)//Ищем нужное значение в XML 
					
			return optionValue
			}
		
		private function parsePathString(optionPath:String):Array{
			var parsedPath:Array
			parsedPath = optionPath.split('.')
	
			return parsedPath
			}
				 
		private function displayXML(node:XML, indentLevel:int, elementsList:Array):String {//Функция взята из кники Рич Шуп, Зеван Россер Изучаем ActionScript 3.0.
			var optionValueString:String = 'Error';//По умолчанию опция не найдена
						
			for each (var element:XML in node.elements()) {
			
				if (element.name() == elementsList[indentLevel]){//Ищем ноду с требуемым названием 
					
						if(element.hasSimpleContent()){//Если дошли до значения ноды
							optionValueString = element;//Возвращаем этот элемент
							}
							else{//Иначе рекурсивно опускаемся на следующий уровень 
								optionValueString = displayXML(element, indentLevel + 1, elementsList);
							}
				
				}
			
			}
			return optionValueString;
		}
	
	}
}
