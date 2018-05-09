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
		private var plugins:Array;
		private var currentPlNumber:int
		private var content:Array
		private var options:Object;
		private var debugLevel:String;
		private var messanger:Messenger;
		private var msgString:String;
		private var ClassReference:Class;
		
		public var loaderEvent:Object;
		
		function PluginLoader(opt:Object){
			var pluginString:String
			errorType = new ModelErrors();
			try{
				options = opt;
				debugLevel = options.getOption('main.debugLevel');
				plugins = new Array();
				messanger = new Messenger(debugLevel);
				messanger.setMessageMark('Plugins loader');
				
				currentPlNumber = 0;
				pluginString = options.getOption('main.pluginsList');
				pluginsList = pluginString.split(';')//Отделяем пути к плагинам друг от друга
				content = new Array();
				loaderEvent = new DispatchEvent();
			
			for(var i:int = 0; i<pluginsList.length;i++){
				plugins[i] = new Loader();//Создаем на каждый плагин по загрузчику
				
				}
			 
			 
			 loadPlugins(currentPlNumber)
		
			}
			catch(error:ArgumentError){
				messanger.message(error.message, 0);
				}
			}
		
		public function loadPlugins(i:int):*{//Начинаем загрузку файлов плагинов в корневой ролик
			
			if(i>pluginsList.length-1){//Когда список плагинов закончился, прерываемся
				//return 'complite';
				msgString = 'All plugins has loaded';
				messanger.message(msgString, 1)
				return 0
				}
           else{
				plugins[i].contentLoaderInfo.addEventListener(Event.COMPLETE, onPluginFileDownloading);
				plugins[i].load(new URLRequest(pluginsList[i]));//А здесь тогда уже загружать не pluginsList[i] а myPlugin['file']
				currentPlugName = pluginsList[i];
				msgString = 'Load plugin ' + i + ' '+ currentPlugName;
				messanger.message(msgString, 3)
				}
			}
			
			function onPluginFileDownloading(e:Event):void{
				//После того, как файл плагина загрузится в основной ролик
				//Отделяем имя плагина из названия файла и его пути
				parent.addChild(plugins[currentPlNumber].content.plEntry)
				var plugDir:Array = currentPlugName.split("/"); 
				var plugFile:Array = plugDir[1].split(".");
				var className:String = plugFile[0];	
				currentPlugName = className;// Заносим в переменную с именем плагина, уже обработанное имя, очищенное от пути и расширения
				
				loaderEvent.pluginName = currentPlugName;//Когда плагин загрузился, передаем ему через событие его имя
				
				
				if(plugins[currentPlNumber].content.plEntry.hasOwnProperty('pluginName')){
					plugins[currentPlNumber].content.plEntry.pluginName = currentPlugName;
				}
				else{
					msgString = 'Plugin ' + currentPlugName + ' has no property pluginName'
					messanger.message(msgString, 1);
					}
				
				
				if(plugins[currentPlNumber].content.plEntry.hasOwnProperty('pluginEvent')){//Проверяем, есть ли вообще в загружаемом плагине pluginEvent
					plugins[currentPlNumber].content.plEntry.pluginEvent.addEventListener(ModelEvent.FINISH, onPluginsJobeFinish);//Если это так, то ждем от плагина сообщения что он отработал и загружаем следующий только потом
				}
				else{//Если плагин не содержит такого события, то просто загружаем следующий не дожидаясь окончания работы предыдущего
					loadPlugins(currentPlNumber);
					msgString = 'Plugin ' + currentPlugName + ' has no property pluginEvent';
					messanger.message(msgString, 1);
					}
					
				if(plugins[currentPlNumber].content.plEntry.hasOwnProperty('messenger')){//Проверяем, есть ли вообще в загружаемом плагине компонент Messenger

					if(plugins[currentPlNumber].content.plEntry['messenger']==null){
						msgString ='Plugin '+ currentPlNumber+ '. Mesannger component exist but not initilazed yet'
						}
						else{
							plugins[currentPlNumber].content.plEntry['messenger'].addEventListener(Messenger.HAVE_EXT_DATA, root['getNewStatistics']);//Если это так, то ждем от плагина сообщения что он отработал и загружаем следующий только потом
						}
				}
				

				loaderEvent.pluginLoaded();//Сообщаем плагину о том, что он загружен
				
				plugins[currentPlNumber].removeEventListener(Event.COMPLETE, onPluginFileDownloading);
				
				msgString = 'Plugin '+ currentPlNumber +': ' + className + ' has loaded';
				messanger.message(msgString, 1);
				
				currentPlNumber++;
				
				}
			
			function onError(e:ModelEvent):void{
				msgString = 'Plugin has not loaded. ' + errorType.fileNotFound;
				messanger.message(msgString, 0);
				}
			
			private function onPluginsJobeFinish(e:ModelEvent):void{
				
				loadPlugins(currentPlNumber);//После загрузки очередного плагина загружаем следующий
				
				}
		}
	}
