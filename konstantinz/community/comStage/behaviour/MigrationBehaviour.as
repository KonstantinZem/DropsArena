package konstantinz.community.comStage.behaviour{
	import konstantinz.community.auxilarity.*
	import konstantinz.community.comStage.*

public class MigrationBehaviour extends DirectionalMotionBehaviour{

	private var collisionCounter:int//счетчик встреченных особей 
	private var collisionsThreshold:int//максимальное число встреч после которого включается эта линия поведения
	private var collisionsExpectionLimit:int//Максимальное количество шагов, после которого счетчик шагов сбрасывается
	private var previosStepsNumber:int//Число пройденных шагов
	private var currentStepsNumber:int;
	private var stepDispetcher:StepDispatcher;
	
	public function MigrationBehaviour(configSource:ConfigurationContainer, dbgLevel:String){
		
		ARENA::DEBUG{
			messenger.setDebugLevel (dbgLevel);
			}

		behaviourName = 'RandomWalker';//По умолчанию, чтобы не беспокоить BehaviourSwitcher, даем знак что нужно прсто двигаться в случайных направлениях
		state = RESET_STATE;
		
		walkingDistance = distanceFromConfig(configSource, 'migrationDistance');
		
		collisionsThreshold = int(configSource.getOption('main.behaviourSwitching.collisionsThreshold'));//После какого количества встреч начать мигрировать
		
		if(collisionsThreshold == 0){
			collisionsThreshold = 10;
			}
		
		collisionsExpectionLimit = int(configSource.getOption('main.behaviourSwitching.collisionsExpectionLimit'));//Как долго ждать встречи, прежде чем сбросить поведение
		};
	
	public function setSuspender(newSuspender:StepDispatcher):void{
		stepDispetcher = newSuspender;
		currentStepsNumber = stepDispetcher.getStepsNumber();
		};
	
	public function collision():void{//Эта линия поведения начинается со встречи двух особей
		if(state != HOLD_STATE){//Если особь в данный момент не мигрирует и встретила другую особь
			collisionCounter++;//Увеличиваем счетчик встреч
			
			//tryToResetStepCounter();//Проверяем не слишком ли мы редко встречаем других особей

			if(collisionCounter > collisionsThreshold){//Если набралось достаточно встерч
				state = HOLD_STATE;//Даем знак, начала линии поведения, чтобы никто не прерывал его пока особь не выходит нужное количество шагов
			
				behaviourName = 'MigrationBehaviour';//Говорим, что нужно включать миграцию
				indDirection = getMovieDirection();//Выбираем направление движения
				
				ARENA::DEBUG{
					msgString = 'Individual ' + individualName + ' begins to migrate';
					messenger.message(msgString, modelEvent.INFO_MARK);
					}
					collisionCounter = 0;
				}
				tryToResetStepCounter();//Проверяем не слишком ли мы редко встречаем других особей
			}
		};
		
		private function tryToResetStepCounter():void{//Счетчик встреч будет обнуляться, если нужное количество встречь не набралось за определенное количество шагов
			previosStepsNumber = currentStepsNumber;//Сохраняем номер текущего шага
			currentStepsNumber = stepDispetcher.getStepsNumber();
	
			if(deltaSteps() > collisionsExpectionLimit){//Если особь не встретила других особей в течении определенного времени
				
				ARENA::DEBUG{
					msgString = 'Individual ' + individualName + ' has reset step counter after ' + deltaSteps() + ' steps.';
					messenger.message(msgString, modelEvent.DEBUG_MARK);
					}
				
				collisionCounter = 0;//Обнуляем счетчик шагов
				}
			};
		
		private function deltaSteps():int{//Проверяет сколько шагов прошло с момента последней встерч с другой особью
			var delta:int = previosStepsNumber - currentStepsNumber;//Потому что stepDispectcher ведет обратный отсчет
		
			if(delta < 0){
				delta = 0;
				}
			return delta;
			};
		
		private function resetAllCounters():void{
			previosStepsNumber = currentStepsNumber;
			currentStepsNumber = stepDispetcher.getStepsNumber();
			collisionCounter = 0;
			directionAlreadyChoised = false;
			}
		
		override protected function onStepUp(currentY:int, currentX:int):void{//Идем вверх
			if (currentY <= BORDERS_APPROACHING_LIMIT){//Если выходим за верхнюю границу поля
				stepsToTarget = countStepsToTarget(0, walkingDistance);
				}else{
					newPosition.y = newPosition.y - stepLength;
					stepsToTarget = countStepsToTarget(stepsToTarget, walkingDistance);//Уменьшаем счетчик оставшихся часов
					}
			}
		
		override protected function onStepDown(currentY:int, currentX:int):void{//Идем вниз
			if(currentY > bottomCorner - BORDERS_APPROACHING_LIMIT){//Если вышли за пределы сцены, сбраываем поведение
				stepsToTarget = countStepsToTarget(0, walkingDistance);//Сбрасываем текущую линию поведения
				}else{
					newPosition.y = currentY + stepLength;
					stepsToTarget = countStepsToTarget(stepsToTarget, walkingDistance);//Уменьшаем счетчик оставшихся часов
					}
			}
		
		override protected function onStepRight(currentY:int, currentX:int):void{
			if(currentX > rightCorner - BORDERS_APPROACHING_LIMIT){//Если особь дошла до правого края сцены
				stepsToTarget = countStepsToTarget(0, walkingDistance);//Сбрасываем текущую линию поведения
				}else{//Если впереди нет препятсвий
					newPosition.x = currentX + stepLength;
					stepsToTarget = countStepsToTarget(stepsToTarget, walkingDistance);//Уменьшаем на 1 количество оставшихся шагов
					}
		}
		
		override protected function onStepLeft(currentY:int, currentX:int):void{//Идем влево
			if(currentX <= stepLength + BORDERS_APPROACHING_LIMIT){//Если можем выйти за пределы поля
				stepsToTarget = countStepsToTarget(0, walkingDistance);//Сбрасываем текущую линию поведения
				}else{
					newPosition.x = currentX - stepLength;
					stepsToTarget = countStepsToTarget(stepsToTarget, walkingDistance);//Уменьшаем счетчик оставшихся часов
					}
			}
		
		override protected function onStay(currentY:int, currentX:int):void{
			newPosition.x = currentX;
			newPosition.y = currentY;
			stepsToTarget = countStepsToTarget(0, walkingDistance);
			};
	}
}
