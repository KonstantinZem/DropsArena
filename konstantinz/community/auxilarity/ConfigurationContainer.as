package konstantinz.community.auxilarity{
   
   import flash.events.Event; 
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.net.*
	
	public class ConfigurationContainer extends EventDispatcher{
		public static var LOADED:String = 'loaded';//Так мы говорим, что загрузка файла окнчена и программа может к нему обращаться
		public static var LOADING_ERROR:String = 'loading_error';//Так говорим, что произошла какая то ошибка
		
		private var cfgFileName:String;
		private var myXML:XML;
		private var myXMLURL;
		private var myLoader;
		private var debugeLevel:String
		
		function ConfigurationContainer(loadedFileName:String='configuration.xml'){
			cfgFileName = loadedFileName;
			myXML = new XML(); 
			myXMLURL = new URLRequest(cfgFileName); 
			myLoader = new URLLoader(myXMLURL);
			
			myLoader.addEventListener(Event.COMPLETE, xmlLoaded);  
			myLoader.addEventListener(IOErrorEvent.IO_ERROR, onError)
			
			debugeLevel = '0'
			
			}
		
		private function xmlLoaded(event:Event):void { //Загружаем файл
			myXML = XML(myLoader.data);
			dispatchEvent(new Event(ConfigurationContainer.LOADED))  
			removeListeners();//Убираем уже ненужные листенеры
			
			debugeLevel = getOption('main.debugLevel')
			
			if(debugeLevel == 'true'){
				trace('Configuration file ' + cfgFileName + ' has loaded')
				
				}
			
		}
		
		
		private function onError(event:IOErrorEvent){//Если загрузить XML файл не удалось
			dispatchEvent(new Event(ConfigurationContainer.LOADING_ERROR))
			removeListeners()//Убираем уже ненужные листенеры
			}
			
		private function removeListeners():void{
			myLoader.removeEventListener(Event.COMPLETE, xmlLoaded);
			myLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError)
			}
		
		public function getOption(optionPath:String){//С помощью этого вызова программа будет получать от класса запрашиваемые опции
			var optionValue:String
			var parsedPath:Object
			
			parsedPath = parsePathString(optionPath)//Разбираем переданную строку на массив из слов
			
			optionValue = displayXML(myXML, 0, parsedPath)//Ищем нужное значение в XML 
					
			return optionValue
			}
		
		private function parsePathString(optionPath:String):Array{
			var parsedPath:Array
			parsedPath = optionPath.split('.')
	
			return parsedPath
			}
				 
		private function displayXML(node:XML, indentLevel:int, elementsList):String {//Функция взята из кники Рич Шуп, Зеван Россер Изучаем ActionScript 3.0.
			var optionValueString:String = 'Error'//По умолчанию опция не найдена
						
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
