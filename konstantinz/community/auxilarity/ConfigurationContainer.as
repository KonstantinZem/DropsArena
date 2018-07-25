package konstantinz.community.auxilarity{
   
   import flash.events.Event; 
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.net.*
	
	public class ConfigurationContainer extends EventDispatcher{
		
		private const 	DEFAULT_FILE_NAME:String = 'configuration.xml';
		private const ERROR_MARK:int = 0;//Сообщение об ошибке помечаются в messanger помечаеся цифрой 0
		
		public static var LOADED:String = 'loaded';//Так мы говорим, что загрузка файла окнчена и программа может к нему обращаться
		public static var LOADING_ERROR:String = 'loading_error';//Так говорим, что произошла какая то ошибка
		
		private var cfgFileName:String = DEFAULT_FILE_NAME;
		private var myXML:XML;//Сюда будет загружаться внешний файл
		private var myXMLURL:URLRequest;
		private var myLoader:URLLoader;
		private var debugLevel:String;
		private var msgStreeng:String;
		private var currentStatus:String;
		private var messenger:Messenger;
		
		private static var _instance:ConfigurationContainer;
		private static var _okToCreate:Boolean = false;//Переменная сигнализирует существует ли уже экземпляр данного класса
		
		public function ConfigurationContainer(){
		
			if ((!_okToCreate)){//Singleton realisation
				throw new Error("Class is singleton. Use method instance() to get it");
			}else{
				debugLevel = '3';//По умолчанию показываем все сообщения, кроме тей что посылаются из цикла
				currentStatus = 'ready';
			}	
			}
			
		public static function get instance():ConfigurationContainer{
            if (!_instance){
				_okToCreate = true;
				_instance = new ConfigurationContainer();
				_okToCreate = false;
				}
            return _instance;
            }
			
		public function setConfigFileName(fileName:String):void{
			cfgFileName = fileName;
            XML.ignoreWhitespace = true;
			myXML = new XML(); 
			myXMLURL = new URLRequest(cfgFileName); 
			myLoader = new URLLoader(myXMLURL);
			
			myLoader.addEventListener(Event.COMPLETE, xmlLoaded);  
			myLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		
		public function setDebugLevel(dbgLevel:String):void{
			debugLevel = dbgLevel;
			}
			
		public function getCurrentStatus():String{
			return currentStatus;
			}
			
		public function getOption(optionPath:String, ...args):String{//С помощью этого вызова программа будет получать от класса запрашиваемые опции
			try{
				if(currentStatus == 'busy'){
					throw new Error('Function yet busy');
					}
				currentStatus = 'busy';
			var parsedPath:Array;
			var optionValue:String;
			var parsedPosition:Array = new Array();
			
			parsedPath = parsePathString(optionPath);//Разбираем переданную строку на массив из слов
            
            if(args[0] is Array){//Если дополнительно была передана точная позиция опции
				parsedPosition = args[0];
				optionValue = searchValueByPosition(myXML, parsedPath, parsedPosition);//Ищем опцию с учетом точной позиции в файле
				}else{			
					optionValue = searchValue(myXML, 0, parsedPath)//Ищем нужное значение в XML 
				}
			}catch(e:Error){
				msgStreeng = e.message;
				messenger.message(msgStreeng, ERROR_MARK);
				}
			currentStatus = 'ready';//Помечаем: контейнер готов к обработки нового запроса
			return optionValue;
			}
		
		private function xmlLoaded(event:Event):void { //Загружаем файл
			myXML = XML(myLoader.data);
			dispatchEvent(new Event(ConfigurationContainer.LOADED))  
			removeListeners();//Убираем уже ненужные листенеры
			
			debugLevel = getOption('main.debugLevel');
			
			messenger = new Messenger(debugLevel);
			messenger.setMessageMark('Options container');
			
			msgStreeng = 'Configuration file ' + cfgFileName + ' has loaded';
			messenger.message(msgStreeng, 1);
			
			if(debugLevel=='Error'){
				debugLevel = '3';
				messenger.setDebugLevel(debugLevel);
				msgStreeng = 'Debuge Level not found in the configuration file. It will be set in ' + debugLevel;
				messenger.message(msgStreeng, 1);
				}
			}
		
		
		private function onError(event:IOErrorEvent):void{//Если загрузить XML файл не удалось
			dispatchEvent(new Event(ConfigurationContainer.LOADING_ERROR))
			removeListeners();//Убираем уже ненужные листенеры
			}
			
		private function removeListeners():void{
			myLoader.removeEventListener(Event.COMPLETE, xmlLoaded);
			myLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		
		private function parsePathString(optionPath:String):Array{
			var parsedPath:Array;
			parsedPath = optionPath.split('.');
	
			return parsedPath;
			}
				 
		private function searchValue(node:XML, indentLevel:int, elementsList:Array):String {//Функция взята из книги Рич Шуп, Зеван Россер Изучаем ActionScript 3.0.
			var optionValueString:String = 'Error';//По умолчанию опция не найдена
						
			for each (var element:XML in node.elements()) {
			
				if (element.name() == elementsList[indentLevel]){//Ищем ноду с требуемым названием 
					
						if(element.hasSimpleContent()){//Если дошли до значения ноды
							optionValueString = element;//Возвращаем этот элемент
							}
							else{//Иначе рекурсивно опускаемся на следующий уровень 
								optionValueString = searchValue(element, indentLevel + 1, elementsList);
							}
				
				}
			
			}
			return optionValueString;
		}
		
		private function searchValueByPosition(config:XML, pathStrings:Array, pathNumbers:Array):String{
			var auxXML:XML;
			var resultValue:String = 'Error';
			
			try{
				auxXML = config;
				if(pathStrings.length != pathNumbers.length){
					throw new ArgumentError('The number of elements in path and position  options are different');
					}
				for(var i:int = 0; i < pathStrings.length; i++){
                  
					if(pathNumbers[i] < auxXML[pathStrings[i]].length()){//Если мы еще не дотигли последнего элемента ветки
						auxXML = auxXML[pathStrings[i]][pathNumbers[i]];
					}else{
						break
						}
					
					if(auxXML == null){
						throw new Error('XML become null');
						}
				
				    if(auxXML.hasSimpleContent() && auxXML != ''){//Если мы дошли до текста, передаем его переменной resultValue
						resultValue = auxXML;
						}
					if(resultValue == null){
						throw new Error('Result value is null');
						}
					
				}
			}catch(e:ArgumentError){
				msgStreeng = e.message;
				messenger.message(msgStreeng, ERROR_MARK);
				}
			catch(e:Error){
				msgStreeng = e.message;
				messenger.message(msgStreeng, ERROR_MARK);
				}
			return resultValue;
		}
	
	}
}
