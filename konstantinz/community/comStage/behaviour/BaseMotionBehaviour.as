package konstantinz.community.comStage.behaviour{
	
	import konstantinz.community.auxilarity.*

	public class BaseMotionBehaviour implements MotionBehaviour{
		
		private const ERROR_MARK:int = 0;//Сообщение об ошибке помечаются в messanger помечаеся цифрой 0
		
		private var debugeLevel:String;
		
		protected var currentPlaceQuality:int;
		protected var populationArea:Array;
		protected var msgString:String;
		
		public var messenger:Messenger;
		
		function BaseMotionBehaviour(dbgLevel:String='3'){
			debugeLevel = dbgLevel;
			messenger = new Messenger();
			messenger.setDebugLevel (debugeLevel);
			messenger.setMessageMark('Behaviour');
			
			}
		public function setPopulationArea(area:Array):void{//передает классу ссылку на массив координат внутри класса CommunityStage А еще лучше передавать это через конструктор
			try{
			
			if(area.length == 0){
				throw new Error('Population area array is empty');
				}
				populationArea = area;
			}catch(err:Error){
				msgString = err.message;
				messenger.message(msgString, ERROR_MARK);
				}
			} 
		
		public function getPlaceQuality(currentX:int, currentY:int):int{
			currentPlaceQuality = populationArea[currentX][currentY].speedDeleyA;
			return currentPlaceQuality;
			}
	
		public function getNewPosition(currentX:int, currentY:int):Array{//Класс на основе выбранного алгоритма поведения определяет новую позицию особи
			
			var newPosition:Array = new Array();
			newPosition['x'] = currentX;
			newPosition['y'] = currentY;
			
			var indDirection:int = 0;
			
			try{
				indDirection = Math.round(Math.random()*8);
			
			
			switch(indDirection){
				case 0: //Стоим наместе
				
				
				break;
				case 1://Идем вниз
				
				if(currentX > populationArea.length-2){
					newPosition['x'] = currentX--;
					}
					else{
						newPosition['x']++;
						}
				break;
				case 2://Идем вверх
				
				if(currentX==0){
					}
					else{
						newPosition['x']--;
					}
				break;
				case 3: //Направо
				
				if(currentY > populationArea[0].length-2){
					newPosition['y']--;
					}
					else{
						newPosition['y']++;
						}
				break;
				case 4://Идем налево
				
				if (currentY == 0){
					}
					else{
						newPosition['y']--;
						}
				break;
				default://Стоим на месте
				
				}
			
			}catch(err:Error){
				msgString = err.message;
				messenger.message(msgString, ERROR_MARK);
				}	
			return newPosition;
			}
		

		public function getNewState():String{//На основе выбранного алгоритма поведения определяется новое состояние особи
			var newState:String = 'nothing'
			try{
				
				}catch(err:Error){
					msgString = err.message;
					messenger.message(msgString, ERROR_MARK);
					}
				return newState;
			}
	
	}

}
