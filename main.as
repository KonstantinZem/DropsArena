// Author: Konstantin Zemoglyadchuk konstantinz@bk.ru
// Copyright (C) 2017 Konstantin Zemoglyadchuk
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

package{
    
    import flash.display.Sprite;
	import flash.events.Event; 
	import konstantinz.community.comStage.*;
	import konstantinz.community.comStage.behaviour.BehaviourChoicer;
	import konstantinz.community.auxilarity.*;
	import konstantinz.community.auxilarity.gui.*;
   
    public class main extends Sprite{
		
		private const IND_NUMB:String = 'ind_numb:';//Пометка сообщения о количестве особей
		private const CRITIAL_IND_NUMBER:int = 5;//Минимально подходящие для отслеживания статистики количество особей
		private const STAT_MSG_MARK:int = 10;
		private const ERROR_MARK:int = 0;//Сообщение об ошибке помечаются в messanger помечаеся цифрой 0
		
		private var stgHeight:int;
		private var stgWidth:int;
		private var indNumber:int;
		private var debugLevel:String;
		private var msgString:String;
		private var statRefreshTime:String;//Время обновления статистической информации
		private var versionText:Sprite;
		private var statusBar:StatusBar;
		private var msgWindow:TextWindow;
		private var messenger:Messenger;
		private var behaviourChoicer:BehaviourChoicer;
		private var eventsForPlugins:Object;
		private var eventsForPluginsList:Array;
		
		public var indSuspender:Vector.<Suspender>//Структура, через которую особей можно на нужное время останавливать
		public var individuals:Vector.<Individual>;
		public var model:Sprite;
		public var plugins:PluginLoader;
		public var configuration:ConfigurationContainer;
		public var commStage:CommunityStage;
		public var startStopButtonEvent:DispatchEvent;
		public var reloadButtonEvent:DispatchEvent;
		public var startStopButton:KzSimpleButton;
		public var reloadButton:KzSimpleButton;

		public function main(){
			
			stgHeight = parent.stage.stageHeight;
			stgWidth = parent.stage.stageWidth;
			initConfig();	
			}
        
        public function getNewStatistics(e:Event):void{//При получении информации, которую нужно сохранить для дальнейшего анализа
				Accumulator.instance.pushToBuffer(e.target.msg);//Передаем ее в копонент, формирующий таблицу
				statusBar.setTexSource(Accumulator.instance.statusBarText);//А затем выводим текущую статистическую информацию в статусную строку
				behaviourChoicer.getConditionsMeaning(e.target.msg);
			    }
        
        private function removeAllObjects():void{//Очищает все объекты программы перед ее перезапуском
			var counter:int;
			Accumulator.instance.clear();
			
			startStopButtonEvent.removeEventListener(ModelEvent.FIRST_CLICK, onStartClick);
			startStopButtonEvent.removeEventListener(ModelEvent.SECOND_CLICK, onStopClick);
			reloadButtonEvent.removeEventListener(ModelEvent.CLICKING, onReloadClick);
			
			messenger.removeEventListener(Messenger.HAVE_EXT_DATA, getNewStatistics);
			messenger = null;
			
			counter = individuals.length;
			for(var i:int = 0;i< counter;i++){//Полностью останавливаем особей и убираем их со сцены
				indSuspender[i].stopIndividual(0);
				commStage.removeChild(individuals[i]);
			}
			indSuspender.length = 0;

			model.removeChild(commStage);
			model.removeChild(plugins);
			
			statusBar.clear();
			startStopButton.clear();
			reloadButton.clear();
			model.removeChild(versionText);
			model.removeChild(statusBar);
			
			removeChild(model);
			
			configuration = null;
			commStage = null;
			reloadButton = null;
			startStopButton = null;
			}
        
        private function initConfig():void{
			configuration = ConfigurationContainer.instance;
			configuration.setConfigFileName('configuration.xml');
			configuration.addEventListener(ConfigurationContainer.LOADED, init);//
			configuration.addEventListener(ConfigurationContainer.LOADING_ERROR, init);//Если не найдем конфигурационного файла, все равно загружаем программу дальше
			
			model = new Sprite();
			addChild(model);
			}
        
		private function init(e:Event):void{
			var initPosition:String;//Каким образом будут добавлятся первые особи
			var intX:int = 0;//Первоначальная координата по x
			var intY:int = 0;//Первоначальная координата по y
			
			configuration.removeEventListener(ConfigurationContainer.LOADED, init);//Эти листенеры уже отработали и не неужны
			configuration.removeEventListener(ConfigurationContainer.LOADING_ERROR, init);
			
			debugLevel = configuration.getOption('main.debugLevel'); //Нужно ли отображать отладочную информацию
			messenger = new Messenger(debugLevel);
			messenger.setMessageMark('Main');
			messenger.addEventListener(Messenger.HAVE_EXT_DATA, getNewStatistics);
						
			versionText = new myVersion('0.6.4',debugLevel);
			
			if(configuration.getOption('main.behaviourSwitching.enable') == 'true'){
			
				behaviourChoicer = new BehaviourChoicer(configuration, debugLevel);
				behaviourChoicer.addEventListener(BehaviourChoicer.BEHAVIOUR_HAS_FOUND, onConditionsChange)
				}
			
			initPosition = configuration.getOption('main.initPosition');
			model.addChild(versionText);
			
			versionText.x = 10;
			versionText.y = 0;

			commStage = new CommunityStage(stgHeight+10,stgWidth+20,configuration);
			model.addChild(commStage);
			commStage.x = 10;
			commStage.y = 20;
			commStage.scaleX = 0.9;
			commStage.scaleY = 0.9;
			
			indNumber = int(configuration.getOption('main.indQuntaty'));
			
			individuals = new Vector.<Individual>(indNumber);
			indSuspender = new Vector.<Suspender>(indNumber);
			
			statRefreshTime = configuration.getOption('main.statRefreshTime');
			Accumulator.instance.setDebugLevel(debugLevel);
			Accumulator.instance.setRefreshTime(int(statRefreshTime));//Устанавливаем время обновления статистики
			
			initGUIElements();
						
			switch(initPosition){//Помещаем первых особей по разным схемам, согласно конфигу
				case 'left-top':
					intX = 0;
					intY = 0;
					addInitIndividuals(intX,intY);
				break;
				
				case 'left-bottom':
					intX = commStage.chessDesk.length-1;
					intY = 0;
					addInitIndividuals(intX,intY);
				break;
				
				case 'right-top':
					intX = 0;
					intY = commStage.chessDesk[1].length-1;
					addInitIndividuals(intX,intY);
				break;
				
				case 'right-bottom':
					intX = commStage.chessDesk.length-1;
					intY = commStage.chessDesk[0].length-1;
					addInitIndividuals(intX,intY);
				break;
				
				case 'center':
					intX = commStage.chessDesk.length/2;
					intY = commStage.chessDesk[0].length/2;
					addInitIndividuals(intX,intY);
				break;
				
				case 'random':
					rndAddInitIndividuals();
				break;
				
				default:
					addInitIndividuals(0,0);
				}
			
			if(configuration.getOption('main.pluginEnable')=='true'){
				try{
				if(configuration.getOption('main.pluginsList') =='Error'){//Если в конфигурационном файле нет списка плагинов
					throw new ArgumentError('Plugins are enabled but plugins list not set');//Прекращаем загрузку
				}
					eventsForPluginsList = new Array();
	
					eventsForPluginsList = [{//Перечисляем при помощи массива каким структурам плагина на какие события надо реагирывать
						sendToRootObject:'getNewStatistics',//Какая структура в главной программе должна реагирывать на событие плагина
						sendFromPluginObject:'messenger',//Какая структура плагина должна посылать событие
						pluginEventHandler:Messenger.HAVE_EXT_DATA
						},
						{
						sendFromRootObject:'startStopButtonEvent',
						sendToPluginObject:'suspendPlugin',
						rootEventHandler:ModelEvent.SECOND_CLICK
						},
						{
						sendFromRootObject:'startStopButtonEvent',
						sendToPluginObject:'startPlugin',
						rootEventHandler:ModelEvent.FIRST_CLICK
						}];
				
					plugins = new PluginLoader(configuration);//Загружаем плагины
					plugins.setPluginsEventsList(eventsForPluginsList);
					plugins.loaderEvent.addEventListener(ModelEvent.PLUGIN_LOADED, onPluginsLoading);//После загрузки плагинов даем команду на загрузку элементов интерфейса
					model.addChild(plugins);
					msgString = 'Plugins are enabled';
				}catch(e:ArgumentError){
					msgString = e.message;
					messenger.message(msgString, ERROR_MARK);
					addChild(startStopButton);//Просто добавляем кнопку пуск
					addChild(reloadButton);
					}
				
			}else{
				msgString = 'Plugins are disabled';
				addChild(startStopButton);
				addChild(reloadButton);
				}
					
			messenger.message(msgString, 2);
				
			}
			
		private function initGUIElements():void{
			try{
				startStopButton = new KzSimpleButton();
				startStopButton.setButtonSkins('pictures/interface/start.png','pictures/interface/stop.png');
				startStopButton.x = 10;
				startStopButton.y = commStage.height + 30;
				startStopButton.height = 30;
				startStopButton.width = 30;
				startStopButtonEvent = startStopButton.buttonEvent;
			
				startStopButtonEvent.addEventListener(ModelEvent.FIRST_CLICK, onStartClick);
				startStopButtonEvent.addEventListener(ModelEvent.SECOND_CLICK, onStopClick);
			
				reloadButton = new KzSimpleButton();//Кнопка перезагрузки модели
				reloadButton.setButtonSkins('pictures/interface/reload.png');
				reloadButton.x = 20 + startStopButton.height;
				reloadButton.y = commStage.height + 30;
				reloadButton.height = 30;
				reloadButton.width = 30;
			
				reloadButtonEvent = reloadButton.buttonEvent;
				reloadButtonEvent.addEventListener(ModelEvent.CLICKING, onReloadClick);
			
				statusBar = new StatusBar();
				model.addChild(statusBar);
				statusBar.setBarAt((70 + startStopButton.width + reloadButton.width), startStopButton.y);
				}catch(e:Error){
					
					}
			}
		
		private function addInitIndividuals(indX:int, indY:int):void{//Добавляем первых особей
			
			for (var i:int = 0; i< indNumber; i++){
				individuals[i] = new Individual(this,commStage.chessDesk,configuration,i,indX,indY);
				indSuspender[i] = new Suspender(individuals[i],commStage.chessDesk,configuration)
				
				commStage.addChild(individuals[i]);
				individuals[i].IndividualEvent.addEventListener(ModelEvent.MATURING, addNewIndividuals);
				individuals[i].IndividualEvent.addEventListener(ModelEvent.DEATH, removeIndividuals);
				
				indSuspender[i].stopIndividual(0);//Останавливаем особей. Потом они запустятся кнопкой Старт
			}
			msgString = IND_NUMB + individuals.length;
			messenger.message(msgString, STAT_MSG_MARK);//Сохраняем количество особей для статистики
			
			}
			
		private function rndAddInitIndividuals():void{//Добавляем первых особей в случайных позициях
			
			var indXRnd : int;
			var indYRnd : int;
			
			var chessDeskLengthX:int = commStage.chessDesk.length - 1;
			var chessDeskLengthY:int = commStage.chessDesk[1].length - 1;
			
			for (var i:int = 0; i< indNumber; i++){
				indXRnd = Math.round(Math.random() * chessDeskLengthX);
				indYRnd = Math.round(Math.random() * chessDeskLengthY);
				
				individuals[i] = new Individual(this,commStage.chessDesk,configuration,i,indXRnd,indYRnd);
				indSuspender[i] = new Suspender(individuals[i],commStage.chessDesk,configuration);
				commStage.addChild(individuals[i]);
				
				individuals[i].IndividualEvent.addEventListener(ModelEvent.MATURING, addNewIndividuals);
				individuals[i].IndividualEvent.addEventListener(ModelEvent.DEATH, removeIndividuals);
			}
			msgString = IND_NUMB + individuals.length;
			messenger.message(msgString, STAT_MSG_MARK);//Сохраняем количество особей для статистики
			}
		
		private function addNewIndividuals(e:Event):void {

			var startPos:int = this.individuals.length;
			var stopPos:int = startPos + int(configuration.getOption('main.offspringsQuant'));
				
				for(var i:int = startPos;i<stopPos;i++){
					var newX:int = e.target.currentChessDeskI;
					var newY:int = e.target.currentChessDeskJ;
					individuals[i] = new Individual(this,commStage.chessDesk, configuration, i,newX,newY);
					indSuspender[i] = new Suspender(individuals[i],commStage.chessDesk,configuration);
					
					commStage.addChild(individuals[i]);
					
					individuals[i].IndividualEvent.addEventListener(ModelEvent.MATURING, addNewIndividuals);
					individuals[i].IndividualEvent.addEventListener(ModelEvent.DEATH, removeIndividuals);
				}
				msgString = IND_NUMB + individuals.length;
			    messenger.message(msgString, STAT_MSG_MARK);//Сохраняем количество особей для статистики
		}
		
		private function removeIndividuals(e:Event):void{
			var individual:int = e.target.individual;//Получаем номер особи, которую надо удалить
			var counter:int;
			try{
			
			individuals[individual].IndividualEvent.removeEventListener(ModelEvent.DEATH, removeIndividuals);
			individuals[individual] = null;//Убираем из массива особей
			indSuspender[individual] = null;//И связанные с ними драйверы
			
			indSuspender.splice(individual,1);//Ужимаем массивы
			individuals.splice(individual,1);
			
			counter = individuals.length;
			for(var i:int = 0; i< counter; i++){
				individuals[i].setName(i);//После ужимания массива делаем так, чтобы имя особи совпадало с ее позицией
				}
			
			msgString = 'Now number of individuals is ' + individuals.length;
			messenger.message(msgString, 2);
			msgString = IND_NUMB + individuals.length;
			messenger.message(msgString, STAT_MSG_MARK);//Сохраняем количество особей для статистики
			
			if(individuals.length < CRITIAL_IND_NUMBER){//Если особей слишком мало
				messenger.removeEventListener(Messenger.HAVE_EXT_DATA, getNewStatistics);//Перестаем за ними следить
				Accumulator.instance.stopRefresh();//И выключаем таймер
				showMessageWindow();
				}
			}catch(e:Error){
				messenger.message(e.message, ERROR_MARK);
				}
				catch(e:RangeError){
					messenger.message(e.message, ERROR_MARK);
					}
			}
		private function onPluginsLoading(e:ModelEvent):void{
			if(plugins.loaderEvent.pluginName=='last'){
				addChild(startStopButton);//Когда плагины загрузились, показываем кнопку старта. Иначе могут случатся ошибки, когда плагин еще не загрузился а юзер уже пытается его остановить кнопкой
				addChild(reloadButton);
				plugins.loaderEvent.removeEventListener(ModelEvent.PLUGIN_LOADED, onPluginsLoading);//Когда плагины загрузились, больше не нужно ждать сообщений об окончании загрузки
			}
		}
			
		private function onStartClick(e:ModelEvent):void{//Действия по нажатию на кнопку старт
			var counter:int;
			
			if(msgWindow){//Если окно статистики уже было открыто
				removeChild(msgWindow);//Закрываем его
				msgWindow = null;
				}
			
			counter = individuals.length;
			for(var i:int = 0; i< counter; i++){
				indSuspender[i].stopIndividual(1);
				}
			msgString = 'Individuals begin to move';
			messenger.message(msgString, 2);
			Accumulator.instance.startRefresh();
			}
		
		private function onStopClick(e:ModelEvent):void{//Действия по нажатию на кнопку стоп
			var counter:int;
			
			counter = individuals.length;
			for(var i:int = 0; i< counter; i++){
				indSuspender[i].stopIndividual(0);
				}
			msgString = 'Individuals has stoped';
			messenger.message(msgString, 2);
			
			showMessageWindow();//Показываем статистику в окне
			Accumulator.instance.stopRefresh();//Останавливаем сбор статистики
			}
		
		private function onReloadClick(e:ModelEvent):void{//При нажатии на кнопку перезагрузки модели
			
			removeAllObjects();//Очищаем все объекты модели
			initConfig();//Запускаем программу с самого начала
			}
			
		private function onConditionsChange(e:Event):void{
			var condition:String = e.target.behaviourName;
			var counter:int;
			
			counter = individuals.length;
			for(var i :int = 0; i< counter; i++){
				individuals[i].motionBehaviour.switchBehaviour(condition)
				}
			}
		
		private function showMessageWindow():void{
			
			msgWindow = new TextWindow(400,600, Accumulator.instance.getStatistic());
			addChild(msgWindow);
			msgWindow.x = 100;
			msgWindow.y = 100;
			}

    }
}
