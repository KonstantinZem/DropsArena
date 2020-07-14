//Цель этого класса - вынести из класса Individual все платформозависимые функции графики
//Здесь нет обращения к ComunityStage, а только к коррдинатам спрайтов
package konstantinz.community.auxilarity.gui{
	
import flash.display.Sprite;
import flash.events.MouseEvent;
import konstantinz.community.comStage.*;
import konstantinz.community.auxilarity.*;

public class IndividualGraphicInterface extends Sprite{
	
	private var indSize:Number;//Размер квадрата особи
	private var growthRange:Number;//Прирост особи за один шаг
	private var remainedGrowth:int
	private var indAge:String;
	private var indState:String
	private var cellXNumb:int;
	private var cellYNumb:int;
	private var indNumber:int;
	
	ARENA::DEBUG{
		private var msgString:String;
		private var messenger:Messenger;
		private var modelEvent:ModelEvent;
		}
	
	private var individualMoveVector:Sprite;
	private var individualMigrationMark:Sprite;
	private var individualPoint:Sprite;
	private var hybernateIndividualPoint:Sprite;
	private var previousStepDistance:int;
	private var currentScale:Number;
	private var currentState:IndividualState;
	
	private var ip:IndividualPoint;
	
	public var individualBody:Sprite;
	
	public function IndividualGraphicInterface(minSize:int, maxSize:int=0, stepToAdulting:int=1, debugLevel:String = '3'){
		
		ARENA::DEBUG{
			modelEvent = new ModelEvent();//Будем брать основные константы от сюда
			messenger = new Messenger(debugLevel);
			messenger.setMessageMark('Individual GUI');
			}
		
		growthRange = 0;
		indSize = 5;
		indNumber = 0;
		remainedGrowth = stepToAdulting;
		if(maxSize > 0){//Если задан максимальный размер особи, 
			indSize = minSize;//То для начала делаем особь маленькой
			if(stepToAdulting > 0){//Если заданно количество шагов, то вычисляем прирост
				growthRange = ((maxSize - minSize)/stepToAdulting);
				}
			}else{
				indSize = minSize;
				}
		}
	
	public function pname(newNumber:int = -1):int{
		
		indNumber = newNumber;
		
		return indNumber;
		};
		
	public function drawIndividual():void{//Рисует особь в виде цветного квадрата
		//Функция напрямую завязана на графике
		individualBody = new Sprite();

		ip = new IndividualPoint();
		individualBody.addChild(ip);
		ip.addEventListener(MouseEvent.CLICK, onMouseClick);
		ip.scaleX = 4
		ip.scaleY = 4
		
		}
	
	public function setState(currenteIndividualState:IndividualState):void{
		currentState = currenteIndividualState;
		}
	
	public function doStep():void{
		
		indAge = currentState.age;
		individualBody.x = currentState.currentX;
		individualBody.y = currentState.currentY;
	
		if(growthRange > 0 && remainedGrowth > 0){//Если особь вообще должна расти, контролируем чтобы особь не росла по достижении половозрелости
			remainedGrowth--;
			if(currentState.movement != 'stop'){//Особь в состоянии гибирнации не должна расти
				currentScale = ip.scaleX + growthRange;
				ip.scaleX = currentScale;
				ip.scaleY = currentScale;
				}
			}
		
		markIndividual(currentState.movement);
		showAdditionMarks(currentState);
		
		}
		
	public function age(newAge:int):void{
		
		try{
		if(!ip){
			throw new Error('Individual point not exist');
			}
		if(newAge > 0){
			ip.scaleX = growthRange*newAge;
			ip.scaleY = growthRange*newAge;
		
			}else{
				throw new Error('New individual age is less or equial zerro');
				}
			}catch(e:Error){
				ARENA::DEBUG{
					msgString = e.message;
					messenger.message(msgString, modelEvent.ERROR_MARK);
					}
				}
		}
	
	public function markIndividual(individualState:String):void{//Отмечает цветом особей в различном состоянии
		indState = individualState;
				
		switch(individualState) { 
			case 'collision': 
				ip.showState('collision');
			break; 
					
			case 'moving':
				if(indAge == 'young'){//Помечаем молодую и взрослую особей разными цветами для наглядности
					ip.showState('moving_yong');
						}else{
							ip.showState('moving_adult');
							}
			break; 
					
		    case 'suspend':
				ip.showState('suspend');
				ip.hideMarks();
			break;
			case 'stop':
				ip.showState('hybernate');
				ip.hideMarks();
			break;
			case 'dead'://Мертвых особей делаем невидимыми
				ip.hideMarks();
				individualBody.visible = false;
			break;
			default: 
				ip.showState('moving_yong');
				ip.hideMarks();
				
				ARENA::DEBUG{
					msgString = 'Wrong statement code';
					messenger.message(msgString, modelEvent.ERROR_MARK);
					}
			break;
				}
		}
	
	private function drawControlPoint(figure:Sprite):void{
		var controlPoint:Sprite = new Sprite();
		figure.addChild(controlPoint);
		controlPoint.graphics.beginFill(0xffffff);
		controlPoint.graphics.drawCircle(figure.x, figure.y, .8);
		};
	
	private function showAdditionMarks(currenteIndividualState:IndividualState):void{
		try{
			
			if(currenteIndividualState.movement == 'moving'){
				switch(currenteIndividualState.behaviour){
					case "BestConditionsWalker":
						showMark('bestConditions', currenteIndividualState);
					break;
					case "MigrationBehaviour":
						showMark('migration', currenteIndividualState);
					break;
					case 'RandomWalker':
						ip.hideMarks();
					break;
					default:
						ip.hideMarks();
						throw new Error('Uncnow individual behaviour name');
					break;
					}
				}
					
			}catch(e:Error){
				ARENA::DEBUG{
					msgString = e.message + ': ' + currenteIndividualState.behaviour;
					messenger.message(msgString, modelEvent.ERROR_MARK);
					}
				}
		}
	
	private function showMark(markName:String, currenteIndividualState:IndividualState):void{
		
		switch(currenteIndividualState.direction){
			case 0: //Стоим наместе
				ip.hideMarks();
				individualBody.rotation = 0;
			break;
			case 3://Вниз
				ip.markAs(markName);
				individualBody.rotation = 90;
			break;
			case 4://Вверх
				ip.markAs(markName);
				individualBody.rotation = -90;
			break;
			case 1: //Направо
				ip.markAs(markName);
				individualBody.rotation = 0;
			break;
			case 2://Вверх
				ip.markAs(markName);
				individualBody.rotation = 180;
			break;
			case 5:
				ip.hideMarks();
				individualBody.rotation = 0;
			break;
			}
		}
	
	private function onMouseClick(event:MouseEvent):void{
		ARENA::DEBUG{
			msgString = 'Individual: ' + indNumber + '; Age: ' + indAge + '; Statement:' + indState + '; behaviour: ' +  currentState.behaviour + '; x:' + currentState.cellX + '; y:' + currentState.cellY;
			messenger.message(msgString)
			}
		};
	
	}
}
