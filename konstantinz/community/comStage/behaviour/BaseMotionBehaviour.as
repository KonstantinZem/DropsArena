package konstantinz.community.comStage.behaviour{
	
	import konstantinz.community.auxilarity.*

	public class BaseMotionBehaviour implements MotionBehaviour{
		
		private var debugeLevel:String;
		private var previosChessDeskI:int
		private var previosChessDeskJ:int
		
		protected var currentPlaceQuality:int;
		protected var stepLength:int;
		protected var populationArea:Array;
		protected var msgString:String;
		protected var modelEvent:ModelEvent;
		
		private var newPosition:Array = new Array();
		protected var individualName:int;
		
		public var messenger:Messenger;
		
		function BaseMotionBehaviour(dbgLevel:String='3'){
			debugeLevel = dbgLevel;
			messenger = new Messenger();
			modelEvent = new ModelEvent();
			messenger.setDebugLevel (debugeLevel);
			messenger.setMessageMark('Behaviour');
			previosChessDeskI = 0;
			previosChessDeskJ = 0;
			stepLength = 1;
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
			currentPlaceQuality = populationArea[currentX][currentY].speedDeleyA;
			return currentPlaceQuality;
			}
	
		public function getNewPosition(currentX:int, currentY:int):Array{//Класс на основе выбранного алгоритма поведения определяет новую позицию особи
			
			clearCell();
			
			newPosition.x = currentX;
			newPosition.y = currentY;
			
			var indDirection:int = 0;
			
			try{
				indDirection = Math.round(Math.random()*8);
			
			
			switch(indDirection){
				case 0: //Стоим наместе
				
				break;
				case 1://Идем вниз
				
				if(currentX > populationArea.length-2){
					newPosition.x = currentX - stepLength;
					}
					else{
						newPosition.x = newPosition.x + stepLength;
						}
				break;
				case 2://Идем вверх
				
				if(currentX==0){
					}
					else{
						newPosition.x = newPosition.x - stepLength;
					}
				break;
				case 3: //Направо
				
				if(currentY > populationArea[0].length-2){
					newPosition.y = newPosition.y - stepLength;
					}
					else{
						newPosition.y = newPosition.y + stepLength;
						}
				break;
				case 4://Идем налево
				
				if (currentY == 0){
					}
					else{
						newPosition.y = newPosition.y - stepLength;
						}
				break;
				default://Стоим на месте
				
				}
			
			}catch(err:Error){
				msgString = err.message;
				messenger.message(msgString, modelEvent.ERROR_MARK);
				}	
			return newPosition;
			}
		

		public function getNewState():String{//На основе выбранного алгоритма поведения определяется новое состояние особи
			var newState:String = 'nothing';
			
			try{
				
				}catch(err:Error){
					msgString = err.message;
					messenger.message(msgString, modelEvent.ERROR_MARK);
					}
				return newState;
			}
		
		public function setIndividualNumber(newNumber:int):void{
			individualName = newNumber;
			}
			
		public function clearCell():void{
			//функция полностью платформонезависимая
			previosChessDeskI = newPosition.x;
			previosChessDeskJ = newPosition.y;
			populationArea[previosChessDeskI][previosChessDeskJ].numberOfIndividuals = '';
			populationArea[previosChessDeskI][previosChessDeskJ].individualName = 0;
			
			}
		public function setStepLength(stLength:int = 1):void{
			stepLength = stLength;
			}
	
	}

}
