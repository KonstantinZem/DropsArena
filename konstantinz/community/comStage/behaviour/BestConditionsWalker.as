package konstantinz.community.comStage.behaviour{

public class BestConditionsWalker extends BaseMotionBehaviour{
	
	private var viewDistance:int = 0;//Растояние в клетках на на котором особь будет искать зону с лучшими условиями
	private var stepsToTarget:int = 0;
	
	public function BestConditionsWalker(dbgLevel:String){
		debugLevel = dbgLevel;
		behaviourName = 'BestConditionsWalker';
		state = RESET_STATE;
		}
		
		private function leftOfStepsToTarget(leftSteps:int, viewDst:int = 1):int{

			if(leftSteps > 1){
				leftSteps--;
				}else{
					leftSteps = viewDst;
					}
				
				return leftSteps;
			};
		
		public function setViewDistance(newViewDistance:int):void{
			viewDistance = newViewDistance;
			}
		
		public function reset():void{//В случае, если модель поведения была прервана и особь не успела сделать нужное количество шагов
			if(stepsToTarget != viewDistance){
				stepsToTarget = viewDistance;//Счетчик шагов обнуляется
				state = RESET_STATE;
				}
			};
		
		override protected function onStepUp(currentX:int, currentY:int):void{//Идем вверх
			if (currentY - viewDistance < stepLength){//Если особь дошла до верхнего края сцены
				newPosition.y = currentY + stepLength;
				stepsToTarget = leftOfStepsToTarget(0, viewDistance);
				}else{
					if(populationArea[currentX][currentY - stepsToTarget].speedDeleyA > currentPlaceQuality){
						stepsToTarget = leftOfStepsToTarget(stepsToTarget, viewDistance);
						newPosition.y = currentY - stepLength;
						}else{
							stepsToTarget = leftOfStepsToTarget(0, viewDistance);
							newPosition.y = currentY - stepLength;
							}
					}
			}
		
		override protected function onStepDown(currentX:int, currentY:int):void{//Идем вниз
			if((currentY + stepsToTarget) > populationArea[0].length - 2){//Если особь дошла до нижнего края сцены
				newPosition.y = currentY - stepLength;
				stepsToTarget = leftOfStepsToTarget(0, viewDistance);
				}else{
					if(populationArea[currentX][currentY + stepsToTarget].speedDeleyA > currentPlaceQuality){
						stepsToTarget = leftOfStepsToTarget(stepsToTarget, viewDistance);
						newPosition.y = currentY + stepLength;
						}else{
							stepsToTarget = leftOfStepsToTarget(0, viewDistance);
							newPosition.y = currentY + stepLength;
							}
					}
			}
		
		override protected function onStepLeft(currentX:int, currentY:int):void{//Идем влево
			if(currentX - viewDistance < stepLength){//Если особь дошла до левого края сцены
				newPosition.x = currentX + stepLength;//Делаем шаг вправо
				stepsToTarget = leftOfStepsToTarget(0, viewDistance);//Сбрасываем линию поведению
				}else{
					if(populationArea[currentX - stepsToTarget][currentY].speedDeleyA > currentPlaceQuality){//Если в клетке левее условия среды лучше
						stepsToTarget = leftOfStepsToTarget(stepsToTarget, viewDistance);
						newPosition.x = currentX - stepLength;
						}else{
							stepsToTarget = leftOfStepsToTarget(0, viewDistance);
							newPosition.x = currentX - stepLength;
							}
					}
		}
	
		override protected function onStepRight(currentX:int, currentY:int):void{//Идем вправо
			if(currentX + stepsToTarget > populationArea.length - 2){//Если особь дошла до края сцены
				newPosition.x = currentX - stepLength;//Делаем шаг влево
				stepsToTarget = leftOfStepsToTarget(0, viewDistance);//Сбрасываем линию поведению
				}else{
					if(populationArea[currentX + stepsToTarget][currentY].speedDeleyA > currentPlaceQuality){
						stepsToTarget = leftOfStepsToTarget(stepsToTarget, viewDistance);
						newPosition.x = currentX + stepLength;
						}else{
							stepsToTarget = leftOfStepsToTarget(0, viewDistance);
							newPosition.x = currentX + stepLength;
							}
					}
			}
		
		override protected function onStay(currentX:int, currentY:int):void{
			newPosition.x = currentX;
			newPosition.y = currentY;
			stepsToTarget = leftOfStepsToTarget(0, viewDistance);
			}
		
		override protected function onBeginChoisingPosition(currentX:int, currentY:int):void{
			newPosition.x = currentX;
			newPosition.y = currentY;
			currentPlaceQuality = getPlaceQuality(currentX, currentY);
			}
			
		override protected function onEndChoisingPosition():void{
			if(stepsToTarget == viewDistance){//Если после очередого шага, количество оставшихся не уменьшилось
				state = RESET_STATE;//Значит особь двигвлась в случайном направлении
				}
			if(stepsToTarget < 0){
				throw new Error('Step to target les then zero');
				}
		};

	}
}
