package konstantinz.community.auxilarity{
  	import flash.display.Sprite;
  	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	
	public class PluginLoader extends Sprite{
		//Класс предназначен для загрузки в главную программу дополнительных модулей и предоставления информации об этих модулях
		private var currentPlNumber:int;
		private var pluginsList:Array;//Ссылка на список плагинов в списки передаваемых ролику опций
		private var pluginsEventsList:Array
		private var plugins:Array;
		private var content:Array;
		private var debugLevel:String;
		private var msgString:String;
		private var arePluginsActiveOnLoading:String;//Будут ли плагины активироваться сразу после загрузки
		private var options:ConfigurationContainer;
		private var messenger:Messenger;
		private var errorType:ModelErrors;
		private var modelEvent:ModelEvent;
		
		public var loaderEvent:Object;
		public var currentPlugName:String;
		
		function PluginLoader(opt:ConfigurationContainer){
			var pluginString:String;
			
			errorType = new ModelErrors();
			pluginsEventsList = new Array();
			loaderEvent = new DispatchEvent();
			modelEvent = new ModelEvent();//Будем брать основные константы от сюда
			
			try{
				options = opt;
				debugLevel = options.getOption('main.debugLevel');
				arePluginsActiveOnLoading = options.getOption('main.arePluginsActiveOnLoading');
				plugins = new Array();
				messenger = new Messenger(debugLevel);
				messenger.setMessageMark('Plugins loader');
				
				currentPlNumber = 0;
				pluginString = options.getOption('main.pluginsList');
				if(pluginString=='Error'){
					throw new ArgumentError('Plugins list not set');
					}else{
					pluginsList = pluginString.split(';')//Отделяем пути к плагинам друг от друга
					content = new Array();
				}
			
			for(var i:int = 0; i<pluginsList.length;i++){
				plugins[i] = new Loader();//Создаем на каждый плагин по загрузчику
				}
			 
			 loadPlugins(currentPlNumber);
		
			}catch(error:ArgumentError){
				loaderEvent.pluginName = 'last';//Если в списке плагинов есть ошибки, посылаем сообщение что мы уже ничего не загружаем
				loaderEvent.pluginLoaded();
				messenger.message(error.message, modelEvent.ERROR_MARK);
				}
			}
		
		private function loadPlugins(pluginNumber:int):void{//Начинаем загрузку файлов плагинов в корневой ролик
			
			if(pluginNumber>pluginsList.length-1){//Когда список плагинов закончился, прерываемся
				loaderEvent.pluginName = 'last';
				loaderEvent.pluginLoaded();
				msgString = 'All plugins has loaded';
				messenger.message(msgString, 1);
				}
           else{
				plugins[pluginNumber].contentLoaderInfo.addEventListener(Event.COMPLETE, onPluginFileDownloading);//Это событие должно придти щт URLRequest ко
				plugins[pluginNumber].load(new URLRequest(pluginsList[pluginNumber]));
				currentPlugName = pluginsList[pluginNumber];
				msgString = 'Load plugin ' + pluginNumber + ' '+ currentPlugName;
				messenger.message(msgString, modelEvent.DEBUG_MARK);
				}
			}
			
		public function setPluginsEventsList(eventsList:Array):void{
			pluginsEventsList = eventsList;
			}
			
		private function linkRootAndPlugisByEvents(pluginNumber:int):void{

			if(pluginsEventsList.length>0){//Если нам передали список объектов, которые нужно связать событиями
				for(var i:int = 0;i<pluginsEventsList.length;i++){
					if(pluginsEventsList[i].sendToRootObject != undefined){//Если есть событие которое надо отослать в главную программу
						if(plugins[pluginNumber].content.plEntry.hasOwnProperty(pluginsEventsList[i].sendFromPluginObject)){//Проверяем, есть ли вообще в загружаемом плагине компонент Messenger
							if(plugins[pluginNumber].content.plEntry[pluginsEventsList[i].sendFromPluginObject]==null){
								msgString ='Plugin '+ currentPlNumber+ '.' + pluginsEventsList[i].sendFromPluginObject + 'component exist but not initilazed yet';
								messenger.message(msgString, modelEvent.INIT_MSG_MARK);
								}else{
									msgString = 'Try to set lstener to ' + plugins[pluginNumber].content.plEntry[pluginsEventsList[i].sendFromPluginObject]
									messenger.message(msgString, modelEvent.DEBUG_MARK);
									plugins[pluginNumber].content.plEntry[pluginsEventsList[i].sendFromPluginObject].addEventListener(pluginsEventsList[i].pluginEventHandler, root[pluginsEventsList[i].sendToRootObject]);//Соединям плагин с определенной функцией в главной программе
									}
								}
							}
						if(pluginsEventsList[i].sendFromRootObject != undefined){//Если есть что отослать плагину из главной программы
	
							if(root.hasOwnProperty(pluginsEventsList[i].sendFromRootObject) && plugins[pluginNumber].content.plEntry.hasOwnProperty(pluginsEventsList[i].sendToPluginObject)){//Проверяем, есть ли вообще в главной программе нужное нам свойство
								msgString = 'Try to set listener to ' + root[pluginsEventsList[i].sendFromRootObject];
								messenger.message(msgString, modelEvent.INFO_MARK);
								root[pluginsEventsList[i].sendFromRootObject].addEventListener(pluginsEventsList[i].rootEventHandler, plugins[pluginNumber].content.plEntry[pluginsEventsList[i].sendToPluginObject]);//Если это так, то ждем от плагина сообщения что он отработал и загружаем следующий только потом
								}
							}
						}
					}
				}
			
		private function onPluginFileDownloading(e:Event):void{
			try{
				//После того, как файл плагина загрузится в основной ролик
				//Отделяем имя плагина из названия файла и его пути
				
				if(plugins[currentPlNumber].content.plEntry != null && root['model'] != null){
					
					root['model'].addChild(plugins[currentPlNumber].content.plEntry);
					
				}else{
					throw new Error('plEntry is null');
					}
				
				var plugDir:Array = currentPlugName.split("/"); 
				var plugFile:Array = plugDir[1].split(".");
				var className:String = plugFile[0];	
				currentPlugName = className;// Заносим в переменную с именем плагина, уже обработанное имя, очищенное от пути и расширения
				
				if(loaderEvent.pluginName != null){
					loaderEvent.pluginName = currentPlugName;//Когда плагин загрузился, передаем ему через событие его имя
				}
				
				if(plugins[currentPlNumber].content.plEntry.hasOwnProperty('activeOnLoad')){

				switch(arePluginsActiveOnLoading){
					case 'true':
							plugins[currentPlNumber].content.plEntry.activeOnLoad = 'true'
					break
					case 'false':
						plugins[currentPlNumber].content.plEntry.activeOnLoad = 'false'
					break
					default:
						msgString='Wrong option item';
						messenger.message(msgString, modelEvent.ERROR_MARK);
					break
					}
				}
				
				if(plugins[currentPlNumber].content.plEntry.hasOwnProperty('pluginName')){
					plugins[currentPlNumber].content.plEntry.pluginName = currentPlugName;
					}
					else{
						msgString = 'Plugin ' + currentPlugName + ' has no property pluginName';
						messenger.message(msgString, modelEvent.INIT_MSG_MARK);
						}
				
				
				if(plugins[currentPlNumber].content.plEntry.hasOwnProperty('pluginEvent')){//Проверяем, есть ли вообще в загружаемом плагине pluginEvent
					plugins[currentPlNumber].content.plEntry.pluginEvent.addEventListener(ModelEvent.FINISH, onPluginsJobeFinish);//Если это так, то ждем от плагина сообщения что он отработал и загружаем следующий только потом
					}
					else{//Если плагин не содержит такого события, то просто загружаем следующий не дожидаясь окончания работы предыдущего
						loadPlugins(currentPlNumber);
						msgString = 'Plugin ' + currentPlugName + ' has no property pluginEvent';
						messenger.message(msgString, modelEvent.INIT_MSG_MARK);
						}
					
				linkRootAndPlugisByEvents(currentPlNumber);
				
				loaderEvent.pluginLoaded();//Сообщаем плагину о том, что он загружен
				
				plugins[currentPlNumber].removeEventListener(Event.COMPLETE, onPluginFileDownloading);
				
				msgString = 'Plugin '+ currentPlNumber +': ' + className + ' has loaded';
				messenger.message(msgString, modelEvent.INIT_MSG_MARK);
				
				currentPlNumber++;
			}catch(e:Error){
				msgString = e.message;
				messenger.message(msgString, modelEvent.ERROR_MARK);
				}
				
				}
			
			private function onError(e:ModelEvent):void{
				msgString = 'Plugin has not loaded. ' + errorType.fileNotFound;
				messenger.message(msgString, modelEvent.ERROR_MARK);
				}
			
			private function onPluginsJobeFinish(e:ModelEvent):void{
				
				loadPlugins(currentPlNumber);//После загрузки очередного плагина загружаем следующий
				
				}
		}
	}
