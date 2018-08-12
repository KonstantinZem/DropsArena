package konstantinz.plugins{
	
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.events.TimerEvent; 
	import flash.utils.*;
	import konstantinz.community.auxilarity.*;
	import konstantinz.community.comStage.*;
	import konstantinz.plugins.*;
	
	public class morisita extends Plugin{
		private const BORDERCOLOR:Number = 0x000000;
		
		private var refreshTime:int;//Время обновления
		private var plotSize:int;//Количество пробных площадок
		private var plotsXQuantaty:int//Колиство квадратов в ряду
		private var plotsYQuantaty:int//Колиство квадратов в столбце
		private var plotsPosition:Array;//Координаты площадок (чтобы не высчитывать их каждый раз заново)
		private var plotsCells:Array;
		private var cellSize:int;
		private var indDrivers:Vector.<Suspender>;
		private var individuals:Vector.<Individual>;
		private var refreshTimer:Timer;
		
		public function morisita (){
			activeOnLoad = 'true';
			messenger.setMessageMark('Morisita counter');
			}
			
		override public function suspendPlugin(e:ModelEvent):void{
			refreshTimer.stop();
			}
	
		override public function startPlugin(e:ModelEvent):void{
			refreshTimer.start();
			}
	
		public override function initSpecial():void{
			indDrivers = root.indSuspender;
			individuals = root.individuals;
				
			debugeLevel = configuration.getOption('plugins.morisitaCounter.debugLevel');
			plotSize = int(configuration.getOption('plugins.morisitaCounter.plotSize'));
			refreshTime = (int(configuration.getOption('plugins.morisitaCounter.refreshTime')))*1000;//Берем время обновления из конфига и переводим его в миллисекунды
				
			cellSize = int(configuration.getOption('main.dropSize'));
			plotsCells = new Array;
			plotsPosition = new Array;
			messenger.setDebugLevel (debugeLevel);
				
			plotsXQuantaty = communityStage.chessDesk[0].length/plotSize;
			plotsYQuantaty = communityStage.chessDesk.length/plotSize;
			drawMorisitaPlot();
				
			if(refreshTime>0){
				refreshTimer = new Timer(refreshTime);
				refreshTimer.addEventListener(TimerEvent.TIMER, countMorisita);
				if(activeOnLoad=='true'){
					refreshTimer.start();
					}
			}else{
				msgString = 'Refresh time not set';
				messenger.message(msgString, modelEvent.ERROR_MARK);
				}
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
			messenger.message(msgString, modelEvent.DEBUG_MARK);
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
				messenger.message('Stoping to count Morisita index', modelEvent.INFO_MARK);
				}
				else{//Если индекс расчитан
					msgString = 'morisita_index:' + morisita;//Посылаем результат для дальнейшей обработки сторонними компонентами
					}
			
			messenger.message(msgString, modelEvent.STATISTIC_MARK);
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
