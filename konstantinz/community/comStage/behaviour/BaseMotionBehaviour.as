package konstantinz.community.comStage.behaviour{
	
	import konstantinz.community.auxilarity.*

	public class BaseMotionBehaviour implements MotionBehaviour{
		
		protected const CONSTANT_STATE:String = 'constant';
		protected const HOLD_STATE:String = 'hold';
		protected const RESET_STATE:String = 'reset';
		
		protected var debugLevel:String;
		private var previosChessDeskI:int;
		private var previosChessDeskJ:int;
		
		protected var currentPlaceQuality:int;
		protected var stepLength:int;
		protected var populationArea:Array;
		protected var msgString:String;
		protected var modelEvent:ModelEvent;
		protected var behaviourName:String;
		protected var state:String;
		protected var directionAlreadyChoised:Boolean;
		
		protected var newPosition:Array = new Array();
		protected var individualName:int;
		protected var indDirection:int;
		
		public var messenger:Messenger;
		
		function BaseMotionBehaviour(dbgLevel:String='3'){
			behaviourName = 'RandomWalker';
			directionAlreadyChoised = false;
			state = CONSTANT_STATE;//Модель поведения не имеет условия начала и окончания
			debugLevel = dbgLevel;
			messenger = new Messenger();
			modelEvent = new ModelEvent();
			messenger.setDebugLevel (debugLevel);
			messenger.setMessageMark('Behaviour');
			previosChessDeskI = 0;
			previosChessDeskJ = 0;
			stepLength = 1;
			indDirection = 0;
			}
		
		public function setPopulationArea(area:Array):void{//передает классу ссылку на массив координат внутри класса CommunityStage А еще лучше передавать это через конструктор
			try{
			
				if(area.length == 0){
					throw new Error('Population area array is empty');
					}
				populationArea = area;
			}catch(err:Error){
				msgString = err.message;
				messenger.message(msgString, modelEvent.ERROR_MARK);
				}
			} 
		
		public function getPlaceQuality(currentX:int, currentY:int):int{
			return populationArea[currentX][currentY].speedDeleyA;
			}
		
		protected function getMovieDirection():int{
			return Math.round(Math.random()*5);//Пускай лучше этот код будет прописан в одном месте
			};
	
		public function getNewPosition(currentX:int, currentY:int):Array{//Класс на основе выбранного алгоритма поведения определяет новую позицию особи
			
			onBeginChoisingPosition(currentX, currentY);
			
			try{
				
				if(directionAlreadyChoised == false){//Направление передвижения может выбираться и в другом месте. Флаг подымается, чтобы небыло повторов
					if(state != HOLD_STATE){//Если выбранное направление не нужно удерживать в течении нескольких ходов
						indDirection = getMovieDirection();//Вычисляем новое направление движения особи
						if(state != CONSTANT_STATE){ //Если линия поведение имеет начало и конец
							state = HOLD_STATE;//Делаем пометку о начале данной линии поведения, чтобы удерживать направление до конца 
							}
						}
					}
					
			switch(indDirection){
				case 0: //Стоим наместе
					onStay(currentX, currentY);
				break;
				case 1://Направо
					onStepRight(currentX, currentY);
				break;
				case 2://Налево
					onStepLeft(currentX, currentY);
				break;
				case 3: //Вниз
					onStepDown(currentX, currentY);
				break;
				case 4://Вверх
					onStepUp(currentX, currentY);
				break;

				default://Стоим на месте
					onStay(currentX, currentY);
					//throw new Error('Wrong direction code');
				break;
				}
		
			onEndChoisingPosition();
			
			}catch(err:Error){
				msgString = 'Individual ' + individualName + ': ' + 'getNewPosition() ' + err.message;
				messenger.message(msgString, modelEvent.ERROR_MARK);
				}	
				
			return newPosition;
			}
		

		public function getState():String{//На основе выбранного алгоритма поведения определяется новое состояние особи
			return state;
			}
		
		public function getName():String{
			return behaviourName;
			};
		
		public function getDirection():int{
			return indDirection;
			};
		
		public function setIndividualNumber(newNumber:int):void{
			individualName = newNumber;
			}
			
		public function setStepLength(stLength:int = 1):void{
			stepLength = stLength;
			}
		
		protected function onStepUp(currentX:int, currentY:int):void{
			if (currentY > 0){
				newPosition.y = currentY - stepLength;
				}
			}
		
		protected function onStepDown(currentX:int, currentY:int):void{
			if(currentY > populationArea[0].length-2){
				newPosition.y = currentY - stepLength;
				}else{
					newPosition.y = currentY + stepLength;
					}
			}
		
		protected function onStepRight(currentX:int, currentY:int):void{
			if(currentX > populationArea.length-2){//Если особь дошла до правого края сцены
				newPosition.x = currentX - stepLength;//Делаем шаг назад
				}else{
					newPosition.x = currentX + stepLength;
					}
		}
		
		protected function onStepLeft(currentX:int, currentY:int):void{
			if(currentX > stepLength){
				newPosition.x = currentX - stepLength;
				}else{
					newPosition.x = currentX + stepLength;
				}
		}
		
		protected function onStay(currentX:int, currentY:int):void{
			newPosition.x = currentX;
			newPosition.y = currentY;
			};
		
		protected function onBeginChoisingPosition(currentX:int, currentY:int):void{
			newPosition.x = currentX;
			newPosition.y = currentY;
			};
		
		protected function onEndChoisingPosition():void{
			
		};
	
	}

}
