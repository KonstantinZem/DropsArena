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
		private var messanger:Messenger;
		private var errorType:ModelErrors;
		
		public var loaderEvent:Object;
		public var currentPlugName:String;
		
		function PluginLoader(opt:ConfigurationContainer){
			var pluginString:String;
			
			errorType = new ModelErrors();
			pluginsEventsList = new Array();
			loaderEvent = new DispatchEvent();
			
			try{
				options = opt;
				debugLevel = options.getOption('main.debugLevel');
				arePluginsActiveOnLoading = options.getOption('main.arePluginsActiveOnLoading');
				plugins = new Array();
				messanger = new Messenger(debugLevel);
				messanger.setMessageMark('Plugins loader');
				
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
				messanger.message(error.message, 0);
				}
			}
		
		private function loadPlugins(pluginNumber:int):void{//Начинаем загрузку файлов плагинов в корневой ролик
			
			if(pluginNumber>pluginsList.length-1){//Когда список плагинов закончился, прерываемся
				loaderEvent.pluginName = 'last';
				loaderEvent.pluginLoaded();
				msgString = 'All plugins has loaded';
				messanger.message(msgString, 1);
				}
           else{
				plugins[pluginNumber].contentLoaderInfo.addEventListener(Event.COMPLETE, onPluginFileDownloading);
				plugins[pluginNumber].load(new URLRequest(pluginsList[pluginNumber]));
				currentPlugName = pluginsList[pluginNumber];
				msgString = 'Load plugin ' + pluginNumber + ' '+ currentPlugName;
				messanger.message(msgString, 3);
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
								messanger.message(msgString, 1);
								}else{
									msgString = 'Try to set lstener to ' + plugins[pluginNumber].content.plEntry[pluginsEventsList[i].sendFromPluginObject]
									messanger.message(msgString, 3);
									plugins[pluginNumber].content.plEntry[pluginsEventsList[i].sendFromPluginObject].addEventListener(pluginsEventsList[i].pluginEventHandler, root[pluginsEventsList[i].sendToRootObject]);//Соединям плагин с определенной функцией в главной программе
									}
								}
							}
						if(pluginsEventsList[i].sendFromRootObject != undefined){//Если есть что отослать плагину из главной программы
	
							if(root.hasOwnProperty(pluginsEventsList[i].sendFromRootObject) && plugins[pluginNumber].content.plEntry.hasOwnProperty(pluginsEventsList[i].sendToPluginObject)){//Проверяем, есть ли вообще в главной программе нужное нам свойство
								msgString = 'Try to set listener to ' + root[pluginsEventsList[i].sendFromRootObject];
								messanger.message(msgString, 2);
								root[pluginsEventsList[i].sendFromRootObject].addEventListener(pluginsEventsList[i].rootEventHandler, plugins[pluginNumber].content.plEntry[pluginsEventsList[i].sendToPluginObject]);//Если это так, то ждем от плагина сообщения что он отработал и загружаем следующий только потом
								}
							}
						}
					}
				}
			
		private function onPluginFileDownloading(e:Event):void{
				//После того, как файл плагина загрузится в основной ролик
				//Отделяем имя плагина из названия файла и его пути
				parent.addChild(plugins[currentPlNumber].content.plEntry)
				var plugDir:Array = currentPlugName.split("/"); 
				var plugFile:Array = plugDir[1].split(".");
				var className:String = plugFile[0];	
				currentPlugName = className;// Заносим в переменную с именем плагина, уже обработанное имя, очищенное от пути и расширения
				
				loaderEvent.pluginName = currentPlugName;//Когда плагин загрузился, передаем ему через событие его имя
				
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
						messanger.message(msgString, 0);
					break
					}
				}
				
				if(plugins[currentPlNumber].content.plEntry.hasOwnProperty('pluginName')){
					plugins[currentPlNumber].content.plEntry.pluginName = currentPlugName;
					}
					else{
						msgString = 'Plugin ' + currentPlugName + ' has no property pluginName';
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
					
				linkRootAndPlugisByEvents(currentPlNumber);
				
				loaderEvent.pluginLoaded();//Сообщаем плагину о том, что он загружен
				
				plugins[currentPlNumber].removeEventListener(Event.COMPLETE, onPluginFileDownloading);
				
				msgString = 'Plugin '+ currentPlNumber +': ' + className + ' has loaded';
				messanger.message(msgString, 1);
				
				currentPlNumber++;
				
				}
			
			private function onError(e:ModelEvent):void{
				msgString = 'Plugin has not loaded. ' + errorType.fileNotFound;
				messanger.message(msgString, 0);
				}
			
			private function onPluginsJobeFinish(e:ModelEvent):void{
				
				loadPlugins(currentPlNumber);//После загрузки очередного плагина загружаем следующий
				
				}
		}
	}
