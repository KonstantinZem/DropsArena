package konstantinz.community.comStage.behaviour{

public class BestConditionsWalker extends BaseMotionBehaviour{
	
	private var viewDistance:int = 5;//Растояние в клетках на которое простирается взгляд особи
	
	public function BestConditionsWalker(){
		
		}
	override public function getNewPosition(currentX:int, currentY:int):Array{//Класс на основе выбранного алгоритма поведения определяет новую позицию особи
			var newPosition:Array = new Array();
			
			currentPlaceQuality = populationArea[currentX][currentY].speedDeleyA;
			
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
					
					if((currentX - viewDistance) > 0 && populationArea[currentX - viewDistance][currentY].speedDeleyA > currentPlaceQuality){
						newPosition['x'] = currentX - viewDistance;
						}else{
							newPosition['x'] = currentX--;
							}
					
					}
					else{
						if((currentX - viewDistance) < (populationArea.length -2) && populationArea[currentX + viewDistance][currentY].speedDeleyA > currentPlaceQuality){
						newPosition[0] = currentX + viewDistance;
						}else{
							newPosition['x']++;
							}
						}
				break;
				case 2://Идем вверх
				
				if(currentX==0){
					}
					else{
						if((currentX - viewDistance) > 0 && populationArea[currentX - viewDistance][currentY].speedDeleyA > currentPlaceQuality){
						newPosition['x'] = currentX - viewDistance;
						}else{
							newPosition['x'] = currentX--;
							}
					}
				break;
				case 3: //Направо
				
				if(currentY > super.populationArea[0].length-2){
					if((currentY - viewDistance) > 0 && populationArea[currentX][currentY - viewDistance].speedDeleyA > currentPlaceQuality){
						newPosition['y'] = currentY - viewDistance;
						}else{
							newPosition['y']--;
							}
					}
					else{
						if((currentY + viewDistance)< (populationArea[0].length - 2) && populationArea[currentX][currentY + viewDistance].speedDeleyA > currentPlaceQuality){
						newPosition['y'] = currentY + viewDistance;
						}else{
							newPosition['y']++;;
							}
						}
				break;
				case 4://Идем налево
				
				if (currentY == 0){
					}
					else{
						if((currentY - viewDistance) > 0 && populationArea[currentX][currentY - viewDistance].speedDeleyA > currentPlaceQuality){
						newPosition['y'] = currentY - viewDistance;
						}else{
							newPosition['y']--;
							}
						}
				break;
				default://Стоим на месте
				
				}
			
			}catch(err:Error){
				msgString = err.message;
				messenger.message(msgString, super.ERROR_MARK);
				}	
			return newPosition;
			}
		
		public function setViewDistance(newViewDistance:int):void{
			viewDistance = newViewDistance
			}

}
}
