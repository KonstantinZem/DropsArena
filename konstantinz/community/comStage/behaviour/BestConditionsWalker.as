package konstantinz.community.comStage.behaviour{

public class BestConditionsWalker extends BaseMotionBehaviour{
	
	private var viewDistance:int = 5;//Растояние в клетках на на котором особь будет искать зону с лучшими условиями
	
	public function BestConditionsWalker(){
	
		}
	override public function getNewPosition(currentX:int, currentY:int):Array{//Класс на основе выбранного алгоритма поведения определяет новую позицию особи
			
			var newPosition:Array = new Array();
			
			currentPlaceQuality = populationArea[currentX][currentY].speedDeleyA;
			
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
					
					if((currentX - viewDistance) > 0 && populationArea[currentX - viewDistance][currentY].speedDeleyA > currentPlaceQuality){
						newPosition.x = currentX - viewDistance;
						}else{
							newPosition.x = currentX - stepLength;
							}
					
					}
					else{
						if((currentX - viewDistance) < (populationArea.length -2) && populationArea[currentX + viewDistance][currentY].speedDeleyA > currentPlaceQuality){
							newPosition.x = currentX + viewDistance;
							}else{
								newPosition.x = newPosition.x + stepLength;
								}
						}
				break;
				case 2://Идем вверх
				
				if(currentX==0){
					}
					else{
						if((currentX - viewDistance) > 0 && populationArea[currentX - viewDistance][currentY].speedDeleyA > currentPlaceQuality){
						newPosition.x = currentX - viewDistance;
						}else{
							newPosition.x = currentX - stepLength;
							}
					}
				break;
				case 3: //Направо
				
				if(currentY > super.populationArea[0].length-2){
					if((currentY - viewDistance) > 0 && populationArea[currentX][currentY - viewDistance].speedDeleyA > currentPlaceQuality){
						newPosition.y = currentY - viewDistance;
						}else{
							newPosition.y = newPosition.y - stepLength;
							}
					}
					else{
						if((currentY + viewDistance)< (populationArea[0].length - 2) && populationArea[currentX][currentY + viewDistance].speedDeleyA > currentPlaceQuality){
						newPosition.y = currentY + viewDistance;
						}else{
							newPosition.y = newPosition.y + stepLength;
							}
						}
				break;
				case 4://Идем налево
				
				if (currentY == 0){
					}
					else{
						if((currentY - viewDistance) > 0 && populationArea[currentX][currentY - viewDistance].speedDeleyA > currentPlaceQuality){
						newPosition.y = currentY - viewDistance;
						}else{
							newPosition.y = newPosition.y - stepLength;
							}
						}
				break;
				default://Стоим на месте
				
				}
			
			}catch(err:Error){
				msgString = err.message;
				messenger.message(msgString, modelEvent.ERROR_MARK);
				}	
			//trace('new x:' + newPosition.x + ', y:' + newPosition.y)
			return newPosition;
			}
		
		public function setViewDistance(newViewDistance:int):void{
			viewDistance = newViewDistance;
			}

	}
}
