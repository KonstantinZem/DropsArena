package konstantinz.community.comStage.behaviour{
	import konstantinz.community.auxilarity.*
	import konstantinz.community.comStage.*

public class MigrationBehaviour extends BaseMotionBehaviour{

	private var migrationDistance:int;
	private var collisionCounter:int//счетчик встреченных особей 
	private var collisionsThreshold:int//максимальное число встреч -  (задается из настроек) 
	private var collisionsExpectionLimit:int//Максимальное количество шагов, после которого счетчик шагов сбрасывается
	private var previosStepsNumber:int//Число пройденных шагов
	private var currentStepsNumber:int;
	private var stepDispetcher:StepDispatcher;
	
	public function MigrationBehaviour(configSource:ConfigurationContainer, dbgLevel:String){
		var newDistance:int;
		debugLevel = dbgLevel;
		messenger.setDebugLevel (debugLevel);
		behaviourName = 'MigrationBehaviour';
		state = RESET_STATE;
		
		newDistance = int(configSource.getOption('main.behaviourSwitching.migrationDistance'));
		if(newDistance > 0){//Если в конфигурационном файле указана дистанция
			migrationDistance = newDistance;
			}else{
				migrationDistance = 1;
				}
		
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
		if(state == RESET_STATE){//Если особь в данный момент не мигрирует
			collisionCounter++;//Если мы когото встретили, увеличиваем счетчик встреч
			behaviourName = 'RandomWalker';//Пока идет проверка, чтобы не беспокоить BehaviourSwitcher, даем знак что нужно прсто двигаться в случайных направлениях
			tryToResetStepCounter();//Проверяем не слишком ли мы редко встречаем других особей

		if(collisionCounter > collisionsThreshold){//Если набралось достаточно встерч
			state = HOLD_STATE;
			behaviourName = 'MigrationBehaviour';//Говорим, что нужно включать миграцию
			resetAllCounters();
			indDirection = getMovieDirection();
			
			ARENA::DEBUG{
				msgString = 'Individual ' + individualName + ' begins to migrate';
				messenger.message(msgString, modelEvent.INFO_MARK);
				}
				}else{
					state == RESET_STATE
					}
			}
		};
		
		private function tryToResetStepCounter():void{//Счетчик встреч будет обнуляться, если нужное количество встречь не набралось за определенное количество шагов
			previosStepsNumber = currentStepsNumber;
			currentStepsNumber = stepDispetcher.getStepsNumber();
	
			if(deltaSteps() > collisionsExpectionLimit){
				
				ARENA::DEBUG{
					msgString = 'Individual ' + individualName + ' has reset step counter after ' + deltaSteps() + ' steps.';
					messenger.message(msgString, modelEvent.DEBUG_MARK);
					}
				
				collisionCounter = 0;
				}
			};
		
		private function deltaSteps():int{
			var delta:int = previosStepsNumber - currentStepsNumber;//Потому что stepDispectcher ведет обратный отсчет
			if(delta < 0){
				delta = 0;
				}
			return delta;
			};
		
		private function resetAllCounters():void{
			currentStepsNumber = 0;
			previosStepsNumber = 0;
			collisionCounter = 0;
			}
		
		override protected function onStepUp(currentX:int, currentY:int):void{
			if (currentY > 0){
				newPosition.y = newPosition.y - stepLength;
				}
			}
		
		override protected function onStepDown(currentX:int, currentY:int):void{
			if(currentY > populationArea[0].length-2){
				newPosition.y = newPosition.y - stepLength;
				state = RESET_STATE;
				}else{
					newPosition.y = newPosition.y + stepLength;
					}
			}
		
		override protected function onStepRight(currentX:int, currentY:int):void{
			if(currentX > populationArea.length-2){//Если особь дошла до правого края сцены
				newPosition.x = currentX - stepLength;//Делаем шаг назад
				state = RESET_STATE;
				}else{
					newPosition.x = newPosition.x + stepLength;
					}
		}
		
		override protected function onStepLeft(currentX:int, currentY:int):void{
			if(currentX > 0){
				newPosition.x = newPosition.x - stepLength;
				}
		}
		
		override protected function onStay(currentX:int, currentY:int):void{
			newPosition.x = currentX;
			newPosition.y = currentY;
			};
		
		override protected function onEndChoisingPosition():void{
			previosStepsNumber++;
				
			if(deltaSteps() == migrationDistance){//Если мы прошли заданное количество шагов
				state = RESET_STATE;
					
				ARENA::DEBUG{
					msgString = 'Individual ' + individualName + ' end to migrate after ' + deltaSteps() + ' steps';
					messenger.message(msgString, modelEvent.INFO_MARK);
					}

				resetAllCounters();
				}
		};
	
	}
}
