package konstantinz.community.auxilarity{
	
	import flash.events.Event
	import flash.events.EventDispatcher;
	import flash.errors.IOError;
	import flash.events.IOErrorEvent;
	import flash.display.Sprite
	import flash.net.URLRequest
	import com.shortybmc.data.parser.CSV;
	
	
	public class OptionsContainer extends EventDispatcher{
		public static var LOADED:String = 'loaded';
		public static var LOADING_ERROR:String = 'loading_error';
		
		public var pluginsList:Array
		public var debugLevel:Boolean;//Надо ли выводить отладочную информацию
		public var indQuntaty:int//Первоначальное количество особей на сцене
		public var lifeTime:int//Время жизни особи в ходах. Передается особи
		public var lifeQuant:int//Величина убывания жизни в ходах. Передается сцене
		public var adultAge:int //Время достижения половозрелости, в ходах
		public var maturingDeley:int//Промежуток между размножениями
		public var offspringsQuant:int//Количество потомков
		public var rectSize:int;//Размер ячеик игрового поля
		private var configFileName:String;
		private var cfgData:Object;
		protected var optionsFromFile:Array;//Служебные массивы для предварительной загрузки названия
		protected var valuesFromFile:Array;//И значения переменных из конфига
		private var errorType:Object;//Контейнер для ошибок;
		private var msg:String;
		protected var varItem:Array;
		
		function OptionsContainer(config:String = 'community.cfg'){
			this.errorType = new ModelErrors();
			this.optionsFromFile = new Array()
			this.valuesFromFile = new Array()
			this.configFileName = config
			this.cfgData = new CSV();
			this.pluginsList = new Array();
			
			
			initVars()
			loadCSV(configFileName);
			}
		
		public function initVars():void{
			debugLevel = true;
			indQuntaty = 10;
			lifeQuant = 4;
			rectSize = 10;
			//lifeTime = 2448//Это соответствует четырем годам жизни, если за день особь совершает 2 хода
			lifeTime = 0;
			adultAge = 10000;
			maturingDeley = 10000;
			offspringsQuant = 3;
			varItem = new Array('debugLevel', 'pluginsList', 'indQuntaty', 'lifeTime', 'adultAge', 'maturingDeley', 'offspringsQuant')
			}
		protected function loadCSV(configFileName:String):void{
			cfgData.embededHeader = false;
			cfgData.fieldSeperator = ',';
			cfgData.addEventListener(Event.COMPLETE, parseCSV);
			cfgData.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			cfgData.load (new URLRequest(configFileName) );
		}
		
		protected function errorHandler(error:IOErrorEvent):void{
			//Если загрузка не удалась
			msg = 'OptionsContainer class error\n' + configFileName + ': '+ errorType.fileNotFound + '. ' + errorType.defaultValue;
			debugMsg(msg);
			dispatchEvent(new Event(OptionsContainer.LOADING_ERROR));
			}
		
		protected function parseCSV(e:Event):void{
			for(var i:int=0;i<cfgData.data.length;i++){
				var str:Array = cfgData.data[i][0].split('=');//Отделяем название переменной от ее значение
				optionsFromFile[i] = new Array();
				valuesFromFile[i] = new Array();
				optionsFromFile[i] = str[0];//Здесь будут названия опций
				valuesFromFile[i] = str[1];//Здесь их значения
				}
			
			msg = 'Program has got next options:\n'
			debugMsg(msg);
			
			getVarsFromConfig();
			
			
			
			msg = 'Options container has loaded OK';
			debugMsg(msg);
			dispatchEvent(new Event(OptionsContainer.LOADED));//Когда все опции распарсены и расталканы по переменным, сообщаем об этом
			cfgData = null;//Убираем из памяти теперь уже не нужный CSV файл
			//optionsFromFile.length = 0; //Убираем из памяти ставшими не нужными служебные временные массивы
			//valuesFromFile.length = 0;
		}
		
		public function getVarsFromConfig():void{
			for (var i:int = 0; i<varItem.length; i++){
			getVar(varItem[i])
			}

			}
		
		protected function getVar(vn:String):void{
			var varName:String = vn;
			var varValue:*  = findVarValue(varName);

			if(varValue != 'not_found'){
				switch(true){
					case this[varName] is String:
					this[varName] = varValue
					break;
				
					case this[varName] is int:
					//так как строка преобразуется в число, можно просто проверить тот случай, когда в
					//Значении переменной символов много, а после преобразования выходит ноль
					//После этого спросить пользователя, не ввел ли он в конфиг строку вместо числа
						this[varName] = varValue
					break;
				
					case this[varName] is Array:
					//Плагин может иметь любое имя, поэтому будет просто достаточно предупредить если 
					//в названии плагина не найдено расширение .swf
						var arr:Array = new Array();
						arr = varValue.split(';');
						this[varName]  = arr;
					break
				
					case this[varName] is Boolean:
						if(varValue=='true'||varValue==1){
							this[varName] = true
							break
						}
						if(varValue=='false'||varValue==0){
							this[varName] = false;
							break
						}
						else{
							this[varName] = true;
							//trace(varName + ' '+ errorType.varIsIncorrect)
							break
						}
					this[varName] = varValue;
					break
					}
					if(this[varName] == varValue){//На всякий случай проверяем, установилась ли переменная в это значение
						msg = 'OK'
						debugMsg(msg);
						}
						else{
							msg = 'Error: '+ errorType.varNotSet
							debugMsg(msg);
							}
				}
			}
				
			protected function findVarValue(varName:String):*{
				//Аккуратное оформление поиска значения переменной в массиве
				var varValue:*;
				var varIndex:int;
				varIndex = optionsFromFile.indexOf(varName)
				
				if(varIndex>-1){
					varValue = valuesFromFile[varIndex];
					msg = 'Option '+ varName + ': '+ valuesFromFile[varIndex];
					debugMsg(msg);
					return varValue;
					}
					else{
						msg = varName + ': '+ errorType.varIsIncorrect + ' ' + errorType.defaultValue;
						debugMsg(msg)
						return 'not_found';
						}
				}
			
			protected function debugMsg(msg:String):void{
				if(debugLevel){
					trace(msg);
				}
			}
	}
}
