package konstantinz.community.auxilarity{
  	import flash.display.Sprite;
  	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	
	public class PluginLoader extends Sprite{
		//Класс предназначен для загрузки в главную программу дополнительных модулей и предоставления информации об этих модулях
		private var pluginsList:Array;//Ссылка на список плагинов в списки передаваемых ролику опций
		private var errorType:Object;
		public var currentPlugName:String;
		private var m_loader:Array;
		private var currentPlNumber:int
		private var content:Array
		private var options:Object;
		private var debugLevel:String;
		private var msgString:String;
		private var ClassReference:Class;
		
		public var loaderEvent:Object;
		
		function PluginLoader(opt:Object){
			var pluginString:String
			errorType = new ModelErrors();
			try{
				this.options = opt;
				this.debugLevel = options.getOption('main.debugLevel');
				this.m_loader = new Array();
				this.currentPlNumber = 0;
				pluginString = options.getOption('main.pluginsList');
				this.pluginsList = pluginString.split(';')//Отделяем пути к плагинам друг от друга
				this.content = new Array();
				loaderEvent = new DispatchEvent();
			
			for(var i:int = 0; i<pluginsList.length;i++){
				m_loader[i] = new Loader();//Создаем на каждый плагин по загрузчику
				
				}
			 
			 
			 loadPlugins(currentPlNumber)
		
			}
			catch(error:ArgumentError){
				trace("<Error> " +  error.message);
				}
			}
		
		public function loadPlugins(i:int):*{//Начинаем загрузку файлов плагинов в корневой ролик
			
			if(i>pluginsList.length-1){//Когда список плагинов закончился, прерываемся
				//return 'complite';
				msgString = 'All plugins has loaded';
				debugMsg(msgString)
				return 0
				}
           else{
			    //Здесь надо вставить код, разбивающий строку по двоеточию на имя файла и передаваемые ему параметы. 
			    //Например так
			    //var myPlugin = parsePlStreeng(pluginsList[i])
				m_loader[i].contentLoaderInfo.addEventListener(Event.COMPLETE, onPluginFileDownloading);
				m_loader[i].load(new URLRequest(pluginsList[i]));//А здесь тогда уже загружать не pluginsList[i] а myPlugin['file']
				currentPlugName = pluginsList[i];
				msgString = 'Load plugin ' + i + ' '+ currentPlugName + '\n';
				debugMsg(msgString)
				}
			}
			
			//function parsePlStreeng(rawStreeng:String){
			//Только надо сначала проверить строку на наличие двоеточий
			//var plInformation:Array = new Array;
			//return plInformation
			//}
			
			function onPluginFileDownloading(e:Event):void{
				//После того, как файл плагина загрузится в основной ролик
				//Отделяем имя плагина из названия файла и его пути
				parent.addChild(m_loader[currentPlNumber].content.plEntry)
				var plugDir:Array = currentPlugName.split("/"); 
				var plugFile:Array = plugDir[1].split(".");
				var className:String = plugFile[0];	
				currentPlugName = className;// Заносим в переменную с именем плагина, уже обработанное имя, очищенное от пути и расширения
				
				loaderEvent.pluginName = currentPlugName;//Когда плагин загрузился, передаем ему через событие его имя
				
				
				if(m_loader[currentPlNumber].content.plEntry.hasOwnProperty('pluginName')){
					m_loader[currentPlNumber].content.plEntry.pluginName = currentPlugName;
				}
				else{
					msgString = 'Plugin ' + currentPlugName + ' has no property pluginName\n'
					debugMsg(msgString)
					}
				
				
				if(m_loader[currentPlNumber].content.plEntry.hasOwnProperty('pluginEvent')){//Проверяем, есть ли вообще в загружаемом плагине pluginEvent
					m_loader[currentPlNumber].content.plEntry.pluginEvent.addEventListener(ModelEvent.FINISH, onPluginsJobeFinish);//Если это так, то ждем от плагина сообщения что он отработал и загружаем следующий только потом
				}
				else{//Если плагин не содержит такого события, то просто загружаем следующий не дожидаясь окончания работы предыдущего
					loadPlugins(currentPlNumber)
					msgString = 'Plugin ' + currentPlugName + ' has no property pluginEvent\n'
					debugMsg(msgString)
					}

				loaderEvent.pluginLoaded();//Сообщаем плагину о том, что он загружен
				
				m_loader[currentPlNumber].removeEventListener(Event.COMPLETE, onPluginFileDownloading);
				
				msgString = 'Plugin '+ currentPlNumber +': ' + className + ' has loaded';
				debugMsg(msgString);
				
				currentPlNumber++;
				
				}
			
			function onError(e:ModelEvent):void{
				msgString = 'Error plagin has not loaded. ' + errorType.fileNotFound
				debugMsg(msgString)
				//m_loader.removeEventListener(IOErrorEvent.IO_ERROR,onError);
				}
			private function debugMsg(msg:String):void{
				if(debugLevel =='true'){
				trace(msg);
				}
			}
			
			private function onPluginsJobeFinish(e:ModelEvent):void{
				
				loadPlugins(currentPlNumber)//После загрузки очерного плагина загружаем следующий
				
				}
		}
	}
