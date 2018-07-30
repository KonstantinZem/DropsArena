package konstantinz.plugins{
	
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.events.TimerEvent; 
	import flash.utils.*;
	import konstantinz.community.auxilarity.*;
	import konstantinz.community.comStage.*;
	import konstantinz.plugins.*;
	
	public class morisita extends Sprite{
		private const BORDERCOLOR:Number = 0x000000;
		private const STATISTIC_MARK:int = 10;//Сообщение статистического характера помечаются в messanger помечаеся цифрой 10
		
		private var debugeLevel:String;
		private var msgString:String;
		private var refreshTime:int;//Время обновления
		private var plotSize:int;//Количество пробных площадок
		private var plotsXQuantaty:int//Колиство квадратов в ряду
		private var plotsYQuantaty:int//Колиство квадратов в столбце
		private var plotsPosition:Array;//Координаты площадок (чтобы не высчитывать их каждый раз заново)
		private var plotsCells:Array;
		private var cellSize:int;
		private var config:Object;
		private var communityStage:Object;
		private var indDrivers:Vector.<Suspender>;
		private var individuals:Vector.<Individual>;
		private var initTimer:Timer;
		private var refreshTimer:Timer;
		
		public var messenger:Messenger;
		public var activeOnLoad:String
		public var pluginName:String; //Должна быть включена в интерфейс этого типа плагинов
		public var pluginEvent:DispatchEvent; //Дает возможность плагину общатся с главной программой с помощью отсылки сообщений
	
		public function morisita (){
			
			debugeLevel = '3';
			activeOnLoad = 'true';
			pluginEvent = new DispatchEvent();
			messenger = new Messenger(debugeLevel);
			messenger.setMessageMark('Morisita counter');
			initTimer = new Timer(1000, 1);//Ждем некоторое время, пока в главная программа не передаст нужные плагину параметры
			initTimer.addEventListener(TimerEvent.TIMER, initPlugin);// потом запускаем программу
			initTimer.start();
			
			}
			
		public function suspendPlugin(e:ModelEvent):void{
			refreshTimer.stop();
			}
	
		public function startPlugin(e:ModelEvent):void{
			refreshTimer.start();
			}
	
		private function initPlugin(e:TimerEvent):void{
		
			if(root != null){//Если плагин загрузился внутри модели
				var time:int;
				config = root.configuration;
				communityStage = root.commStage;
				indDrivers = root.indSuspender;
				individuals = root.individuals;
				
				debugeLevel = config.getOption('plugins.morisitaCounter.debugLevel');
				plotSize = int(config.getOption('plugins.morisitaCounter.plotSize'));
				refreshTime = (int(config.getOption('plugins.morisitaCounter.refreshTime')))*1000;//Берем время обновления из конфига и переводим его в миллисекунды
				
				cellSize = int(config.getOption('main.dropSize'));
				plotsCells = new Array;
				plotsPosition = new Array;
				messenger.setDebugLevel (debugeLevel);
				
				plotsXQuantaty = communityStage.chessDesk[0].length/plotSize;
				plotsYQuantaty = communityStage.chessDesk.length/plotSize;
				drawMorisitaPlot();
				
				msgString = 'Morisita counter plugin';
				messenger.message(msgString, 1);
				
				if(refreshTime>0){
					refreshTimer = new Timer(refreshTime);
					refreshTimer.addEventListener(TimerEvent.TIMER, countMorisita);
					if(activeOnLoad=='true'){
						refreshTimer.start();
					}
				}else{
					msgString = 'Refresh time not set';
					messenger.message(msgString, 0);
					}

			}
		pluginEvent.ready();//Сообщаем загружающей плагин программе о том что плагин загружен и готов к работе
		}
		
		private function drawMorisitaPlot():void{	//Разлинеивает игровое поле в квадратики для большей наглядности
			var xpos:int = 0; //Позиция квадрата на поле
			var ypos:int = 0;

			var morisitaPlotSize:int = communityStage.width/plotsXQuantaty

				for(var i:int = 0; i<plotsXQuantaty;i++){
					plotsCells[i]  = new Array;
					
					for(var j:int = 0; j<plotsYQuantaty;j++){
						plotsCells[i][j] = new Sprite();
						plotsCells[i][j].graphics.lineStyle(1,BORDERCOLOR);
						plotsCells[i][j].graphics.drawRect(ypos,xpos,morisitaPlotSize,morisitaPlotSize);
						communityStage.addChild(plotsCells[i][j]);
						xpos =xpos+ morisitaPlotSize;
					}
					
					ypos = ypos+ morisitaPlotSize;
	                xpos = 0;
				}
			}
		
		private function countMorisita(e:TimerEvent):void{
			msgString = 'Counting Morisita index';
			messenger.message(msgString, 3);
			var morisita:Number;
			var drvCounter:int;
			var indCounter:int
		
			if(plotsPosition.length == 0){//Если пречень координат  квадратов еще не составлялся
				getPlotPosition();//Составляем его чтобы в дальнейшем не расчитывать позиции которые уже не изменятся а просто брать уже готовые координаты
				}
		
			drvCounter = indDrivers.length;
			for(var i:int = 0; i< drvCounter;i++){//Перед тем как расчитать индекс приостанавливаем особей на некоторое время
				indDrivers[i].stopIndividual(500);
				}
				
				clearStage();//Очищаем массив сцены от информации о прибывании там особе, так как отметка от пристутсвия особи часто остается в уже пустой ячейки
				
			indCounter = individuals.length;
			for(var j:int = 0; j< indCounter;j++){
				individuals[j].markPresenceInPlot();//Даем особям команду обозначить те квадраты в которых они уже находятся
				}
				
			morisita = morisitaIndex();//Высчитываем индекс Мориситы
			
			if(isNaN(morisita)){//Проверяем, можем ли мы расчитать индекс
				msgString = 'morisita_index:-';//И если индекс уже не может быть расчитан (особей слишком мало)
				refreshTimer.stop();//Перестаем расчитывать индекс
				messenger.message('Stoping to count Morisita index',2);
				}
				else{//Если индекс расчитан
					msgString = 'morisita_index:' + morisita;//Посылаем результат для дальнейшей обработки сторонними компонентами
					}
			
			messenger.message(msgString, STATISTIC_MARK);
		}
		
		private function getPlotPosition():int{
			var newX:int = 0;
			var newY:int = 0;
			var counter:int = 0;

			for(var i:int = 0; i<plotsXQuantaty;i++){//Пробегаемся по квадратам и высчитываем количество особей в каждом из них

				for(var j:int = 0; j<plotsYQuantaty;j++){
					plotsPosition[counter] = new Array;
					plotsPosition[counter].push(newX);
					plotsPosition[counter].push(newY);
					newX += plotSize;
					counter++;
					}
					
				newX = 0;
				newY += plotSize;
			}
		}
		
		private function clearStage():void{
			var counterI:int;
			var counterJ:int;
			
			counterI = communityStage.chessDesk.length;
			for(var i:int = 0; i< counterI;i++){
				
				counterJ = communityStage.chessDesk[i].length;
				for(var j:int = 0;j< counterJ; j++){
					communityStage.chessDesk[i][j].numberOfIndividuals = '';
					}
				}
			}
	
		private function morisitaIndex():Number{
		
			var mIndex:Number;
			var allIndividuals:int = 0;
			var allPlotsNumber:int = 0;
			var individualsInplot:Array = new Array;//Количество особей в каждой из площадок
			var ind:int = 0;
			var niSumm:int = 0;
			var newX:int = 0;
			var newY:int = 0;
			var counter:int;
			
			counter = plotsPosition.length;
	
			for (var i:int = 0; i< counter; i++){
				newX = plotsPosition[i][0];
				newY = plotsPosition[i][1];
				ind = countIndividuals(newX,newY,plotSize);
				individualsInplot.push(ind);
				}
			
			allPlotsNumber = individualsInplot.length;
				
			for(i = 0; i< allPlotsNumber; i++){//Подсчитываем общее количество особей в квадратах
				allIndividuals += individualsInplot[i];
				}
			
			for(i = 0; i< allPlotsNumber; i++){
				niSumm += individualsInplot[i]*(individualsInplot[i]-1);
				}
			
			mIndex = allPlotsNumber*(niSumm/(allIndividuals*(allIndividuals-1)));
			msgString = 'source data: nidividuals '+ allIndividuals + ', plots ' + allPlotsNumber;
			messenger.message(msgString, 3);//Возвращаем индекс Мориситы с точностью 3 знака после запятой
			
			return mIndex.toFixed(3);
		}
		
		private function countIndividuals(xcrd:int,ycrd:int,plSize:int):int{//Подсчет количества особей в исследуемых площадках
			var individualsNumber:int;
			for(var i:int = 0; i<plSize; i++){
		
				for(var j:int = 0; j<plSize; j++){
					individualsNumber += communityStage.chessDesk[xcrd+i][ycrd+j].numberOfIndividuals.length;
					}
				}
			return individualsNumber;
		}
	}
}
