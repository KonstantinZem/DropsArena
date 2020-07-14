package konstantinz.community.comStage.behaviour{
//Суперкласс, от которого наследуются модели поведения, связанные с направленным движением -- миграция и переход в зону с лучшими условиями
import flash.events.Event; 
import konstantinz.community.auxilarity.*

public class DirectionalMotionBehaviour extends BaseMotionBehaviour{
	
	protected var walkingDistance:int;//Расстояние в шагах, которое особь должна пройти не сворачивая
	protected var stepsToTarget:int;//Количество шагов, которое осталось пройти особи до участка с нужными условиями 
	
	public function DirectionalMotionBehaviour():void{
		walkingDistance = 1;
		stepsToTarget = 0;
		};
	
	public function setWalkingDistance(newDistance:int):void{
			walkingDistance = newDistance;
			}
	
	protected function distanceFromConfig(configSource:ConfigurationContainer, optionName:String):int{//Единый для классов наследников инерфейс получения количества шагов, которое нужно сделать не меняя направления
		var distanceFromConfig:int;
		distanceFromConfig = int(configSource.getOption('main.behaviourSwitching.' + optionName));
		
		if(distanceFromConfig < 1){//Если в конфигурационном файле не указана дистанция
			distanceFromConfig = 1;//Ставим дистанцию по умолчанию
			}
		return distanceFromConfig;
		}
		
	protected function countStepsToTarget(leftSteps:int, viewDst:int = 1):int{//Ведет счет пройденным шагам и в конце отменяет линию поведения

			if(leftSteps > 1){//Если заданная дистанция еще не пройдена
				leftSteps--;//После каждого хода уменьшаем счетчик оставшихся шагов
				}else{
					leftSteps = viewDst;//А если пройдена
					state = RESET_STATE;//Снимаем линию поведения "Направленное движение"
					}
				return leftSteps;
			};
	
	};

}
