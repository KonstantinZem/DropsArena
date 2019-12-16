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
		private const IND_NUMB:String = 'ind_numb:';//Пометка сообщения о количестве особей
	
		public function morisita (){
			activeOnLoad = 'true';
			messenger.setMessageMark('Morisita counter');
			}	
	
		public override function initSpecial(task:Array, taskName:String, taskNumber:int):void{
			var investigatedAreaPositionString:String
			task[taskNumber] = new MorisitaTask();
			currentTask = task[taskNumber];
			initCurrentTaskData(currentTask, taskName,  taskNumber);
			
			investigatedAreaPositionString = configuration.getOption('plugins.morisitaCounter.task.plotPosition');
			debugeLevel = configuration.getOption('plugins.morisitaCounter.task.debugLevel');
			currentTask.releveSize = int(configuration.getOption('plugins.morisitaCounter.task.releveSize'));
			
			parsePositiongString(investigatedAreaPositionString, currentTask);
	
			currentTask.plotsCells = new Array;
			currentTask.plotsPosition = new Array;
			messenger.setDebugLevel (debugeLevel);
				
			drawMorisitaPlot();
			
			setTimeout(pluginEvent.ready, 50);//Сообщение о том что плагин полностью готов к работе принимается функцией onPluginsJobeFinish в pluginLoader
			}
		
		private function initCurrentTaskData(currentTask:Task, taskName:String, taskNumber:int):void{
			currentTask.name = taskName;
			currentTask.number = taskNumber;
			currentTask.observationPosition = new Array(0,0,taskNumber,0);
			currentTask.switchingEvent = setSwitchingEvent(currentTask);
			currentTask.switchingInterval = setSwitchingInterval(currentTask);
			}
		
		private function parsePositiongString(posString:String, task:MorisitaTask):void{
			try{
				task.investigatedAreaPosition = new Array;
				
				if(posString == 'Error'){//Если координаты области для расчета не заданы
					throw new ArgumentError('Plot position not set');
					}
				var positionFromConfig:Array = posString.split(';');
				
				if(positionFromConfig.length < 4){//Если не хватает координат
					throw new ArgumentError('Plot position is wrong');
					}
				
				task.investigatedAreaPosition.upX = int(positionFromConfig[0]);
				task.investigatedAreaPosition.upY = int(positionFromConfig[1]);
				task.investigatedAreaPosition.dwnX = int(positionFromConfig[2]);
				task.investigatedAreaPosition.dwnY = int(positionFromConfig[3]);
				
				if(task.investigatedAreaPosition.upX > task.investigatedAreaPosition.dwnX
					||
					task.investigatedAreaPosition.upY > task.investigatedAreaPosition.dwnY
				){
					throw new ArgumentError('Up coordinates les then down');
					}

				if(//Если заданные координаты выходят за границы сцены
					task.investigatedAreaPosition.dwnX >= communityStage.chessDesk[0].length //width is out
					||
					task.investigatedAreaPosition.dwnY >= communityStage.chessDesk.length //height is out
					){
					msgString = 'Bottom rigth coner coordinates are: Y=' + communityStage.chessDesk[0].length + ', X=' +  communityStage.chessDesk.length;
					messenger.message(msgString, modelEvent.ERROR_MARK);
					throw new ArgumentError('Coordinates out from borders');
					}
				
				}
				catch(e:ArgumentError){
					msgString = e.message
					messenger.message(msgString, modelEvent.ERROR_MARK);
					
					task.investigatedAreaPosition.upX = 0;
					task.investigatedAreaPosition.upY = 0;
					task.investigatedAreaPosition.dwnX = communityStage.chessDesk[0].length -1;//width
					task.investigatedAreaPosition.dwnY = communityStage.chessDesk.length -1;//height
				}
			};
		
		private function drawMorisitaPlot():void{	//Разлинеивает игровое поле в квадратики для большей наглядности
	
			var cellUpX:int = currentTask.investigatedAreaPosition.upX; //Позиция квадрата на поле 0
			var cellUpY:int = currentTask.investigatedAreaPosition.upY; 
			var cellDwnX:int = currentTask.investigatedAreaPosition.dwnX; 
			var cellDwnY:int = currentTask.investigatedAreaPosition.dwnY; 
			
			var xpos:int = communityStage.chessDesk[cellUpY][cellUpX].sqrX;
			var ypos:int = communityStage.chessDesk[cellUpY][cellUpX].sqrY;
			
			var plotLength:int = communityStage.chessDesk[cellDwnY][cellDwnX].sqrX - communityStage.chessDesk[cellDwnY][cellUpX].sqrX;
			var plotHeigth:int = communityStage.chessDesk[cellDwnY][cellUpX].sqrY - communityStage.chessDesk[cellUpY][cellUpX].sqrY; 
			
			var releveLength:int = communityStage.chessDesk[0][currentTask.releveSize].sqrX;
			
			msgString = 'Up corner X=' + cellUpX + ', Y=' + cellUpY + '. Down corner X=' + cellDwnX + ', Y=' + cellDwnY;
			messenger.message(msgString, modelEvent.DEBUG_MARK);
			
			currentTask.plotsXQuantaty = plotLength/releveLength;
			currentTask.plotsYQuantaty = plotHeigth/releveLength;
			
			var morisitaPlotSize:int = plotLength/currentTask.plotsXQuantaty;

				for(var i:int = 0; i < currentTask.plotsYQuantaty;i++){
					currentTask.plotsCells[i]  = new Array;
					
					for(var j:int = 0; j < currentTask.plotsXQuantaty;j++){
						currentTask.plotsCells[i][j] = new Sprite();
						currentTask.plotsCells[i][j].graphics.lineStyle(1,BORDERCOLOR);
						currentTask.plotsCells[i][j].graphics.drawRect(xpos,ypos,morisitaPlotSize,morisitaPlotSize);
						communityStage.addChild(currentTask.plotsCells[i][j]);
						xpos += morisitaPlotSize;//Следующий квадрат рисуем сразу после предыдущего
					}
					
					ypos += morisitaPlotSize;
	                xpos = communityStage.chessDesk[cellUpY][cellUpX].sqrX;
				}
			}
			
		override public function startPluginJobe():void{
			countMorisita();
			}
		
		private function countMorisita():void{
	
			msgString = 'Counting Morisita index';
			messenger.message(msgString, modelEvent.DEBUG_MARK);
			var morisita:Number;

			if(currentTask.plotsPosition.length == 0){//Если пречень координат  квадратов еще не составлялся
				getPlotPosition();//Составляем его чтобы в дальнейшем не расчитывать позиции которые уже не изменятся а просто брать уже готовые координаты
				}	
				
			morisita = morisitaIndex();//Высчитываем индекс Мориситы
			
			if(isNaN(morisita)){//Проверяем, можем ли мы расчитать индекс
				msgString = 'morisita_index:-';//И если индекс уже не может быть расчитан (особей слишком мало)
				messenger.message('Stoping to count Morisita index', modelEvent.INFO_MARK);
				}
				else{//Если индекс расчитан
					msgString = 'morisita_index:' + morisita;//Посылаем результат для дальнейшей обработки сторонними компонентами
					}
			
			messenger.message(msgString, modelEvent.STATISTIC_MARK);
		}
		
		private function getPlotPosition():int{
			
			var newX:int = currentTask.investigatedAreaPosition.upX;//Верхний левый угол зоны подсчета
			var newY:int = currentTask.investigatedAreaPosition.upY;
			var counter:int = 0;//Подсчет зон участвующих в вычислении
			
			for(var i:int = 0; i < currentTask.plotsYQuantaty;i++){//Пробегаемся по квадратам и высчитываем количество особей в каждом из них

				for(var j:int = 0; j < currentTask.plotsXQuantaty;j++){
					currentTask.plotsPosition[counter] = new Array;
					currentTask.plotsPosition[counter].push(newX);
					currentTask.plotsPosition[counter].push(newY);
					newX += currentTask.releveSize;
					counter++;
					}
			
				newX = currentTask.investigatedAreaPosition.upX;
				newY += currentTask.releveSize;
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
			
			counter = currentTask.plotsPosition.length;
			
			for (var i:int = 0; i< counter; i++){
				newX = currentTask.plotsPosition[i][0];//Берем заранее подсчитанные позиции квадратов
				newY = currentTask.plotsPosition[i][1];
				ind = countIndividuals(newX,newY,currentTask.releveSize);
				individualsInplot.push(ind);//Подсчитываем количество особей в каждом квадрате
				}
			//Вот здесь вставляем формулу подсчета другого варианта мориситы
			
			allPlotsNumber = individualsInplot.length;
				
			for(i = 0; i< allPlotsNumber; i++){//Подсчитываем общее количество особей в квадратах
				allIndividuals += individualsInplot[i];
				}
			
			for(i = 0; i < allPlotsNumber; i++){
				niSumm += individualsInplot[i]*(individualsInplot[i]-1);
				}
			
			mIndex = allPlotsNumber*(niSumm/(allIndividuals*(allIndividuals-1)));
			msgString = 'source data: Idividuals '+ allIndividuals + ', plots ' + allPlotsNumber;
			messenger.message(msgString, 3);//Возвращаем индекс Мориситы с точностью 3 знака после запятой
			msgString = IND_NUMB + allIndividuals;
			messenger.message(msgString, modelEvent.STATISTIC_MARK);//Сохраняем количество особей для статистики
			
			return mIndex.toFixed(3);
		}
		
		private function countIndividuals(xcrd:int,ycrd:int,plSize:int):int{//Подсчет количества особей в исследуемых площадках
			
			var individualsNumber:int;
			for(var i:int = 0; i< plSize; i++){
		
				for(var j:int = 0; j< plSize; j++){
					individualsNumber += communityStage.chessDesk[ycrd+i][xcrd+j].numberOfIndividuals.adult;
					individualsNumber += communityStage.chessDesk[ycrd+i][xcrd+j].numberOfIndividuals.young;
					}
				}
			
			return individualsNumber;
		}
	}
}
