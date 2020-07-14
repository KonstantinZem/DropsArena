package konstantinz.community.comStage.behaviour{

import konstantinz.community.auxilarity.*

public class BestConditionsWalker extends DirectionalMotionBehaviour{
	
	public function BestConditionsWalker(configSource:ConfigurationContainer, dbgLevel:String){
		walkingDistance = distanceFromConfig(configSource, 'viewDistance');
		debugLevel = dbgLevel;
		behaviourName = 'BestConditionsWalker';
		state = RESET_STATE;
		}
		
		public function setViewDistance(newViewDistance:int):void{
			walkingDistance = newViewDistance;
			}
		
		public function reset():void{//В случае, если модель поведения была прервана и особь не успела сделать нужное количество шагов
			stepsToTarget = walkingDistance;//Счетчик шагов обнуляется
			state = RESET_STATE;//Текущая линия поведения сбрасывается
			};
		
		override protected function onStepUp(currentY:int, currentX:int):void{//Идем вверх

			if(currentY < walkingDistance){
				stepsToTarget = countStepsToTarget(0, walkingDistance);
				}else{
					if(populationArea[currentY - stepsToTarget][currentX].speedDeleyA > currentPlaceQuality){//Если в поле зрения находится уасток с лучшими условиями чем в текущем
						stepsToTarget = countStepsToTarget(stepsToTarget, walkingDistance);
						newPosition.y = currentY - stepLength;
						}else{
							stepsToTarget = countStepsToTarget(0, walkingDistance);//Если не увидели подходящих условий, сбрасываем поведение
							newPosition.y = currentY - stepLength;
							}
					}
			}
		
		override protected function onStepDown(currentY:int, currentX:int):void{//Идем вниз
			if(currentY > bottomCorner - walkingDistance){//Если особь подошла к нижнему краю сцены ближе чем расстояние на которм она ищет хорошие условия
				stepsToTarget = countStepsToTarget(0, walkingDistance);//Переключаем ее поведение на предвижение в случайных направлениях
				}else{
					if(populationArea[currentY + stepsToTarget][currentX].speedDeleyA > currentPlaceQuality){//Если в поле зрения находится участок с лучшими условиями
						stepsToTarget = countStepsToTarget(stepsToTarget, walkingDistance);//Идем к нему никуда не сворачивая
						newPosition.y = currentY + stepLength;
						}else{//А если условия в поле зрения ни отличаются от текущих
							stepsToTarget = countStepsToTarget(0, walkingDistance);
							newPosition.y = currentY + stepLength;//Просто делаем шаг вниз
							}
					}
			}
		
		override protected function onStepLeft(currentY:int, currentX:int):void{//Идем влево
			
			if(currentX < walkingDistance){
				stepsToTarget = countStepsToTarget(0, walkingDistance);
				}else{
					if(populationArea[currentY][currentX - stepsToTarget].speedDeleyA > currentPlaceQuality){//Если в клетке левее условия среды лучше
						 
						stepsToTarget = countStepsToTarget(stepsToTarget, walkingDistance);
						newPosition.x = currentX - stepLength;
						}else{
							stepsToTarget = countStepsToTarget(0, walkingDistance);
							newPosition.x = currentX  - stepLength;
							}
					}
			}
	
		override protected function onStepRight(currentY:int, currentX:int):void{//Идем вправо
			if(currentX + stepsToTarget >= rightCorner - BORDERS_APPROACHING_LIMIT){//Если особь дошла до края сцены
				stepsToTarget = countStepsToTarget(0, walkingDistance);//Сбрасываем линию поведению
				}else{
					if(populationArea[currentY][currentX + stepsToTarget].speedDeleyA > currentPlaceQuality){
						stepsToTarget = countStepsToTarget(stepsToTarget, walkingDistance);
						newPosition.x = currentX + stepLength;
						}else{
							stepsToTarget = countStepsToTarget(0, walkingDistance);
							newPosition.x = currentX + stepLength;
							}
					}
			}
		
		override protected function onStay(currentY:int, currentX:int):void{
			newPosition.x = currentX;
			newPosition.y = currentY;
			stepsToTarget = countStepsToTarget(0, walkingDistance);
			}
		
		override protected function onBeginChoisingPosition(currentY:int, currentX:int):void{
			try{
				newPosition.x = currentX;
				newPosition.y = currentY;
			
				if(currentX < 0|| currentY < 0){
					throw new Error('Cordinate less then zero');
					}
				currentPlaceQuality = getPlaceQuality(currentY, currentX);
	
				}catch(e:Error){
					ARENA::DEBUG{
						msgString = 'Individual ' + individualName + ': onBeginChoisingPosition(): ' + e.message;
						messenger.message(msgString, modelEvent.ERROR_MARK);
						}
					}
			}

	}
}
