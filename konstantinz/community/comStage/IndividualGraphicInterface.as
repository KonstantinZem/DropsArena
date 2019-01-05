//Цель этого класса - вынести из класса Individual все платформозависимые функции графики
package konstantinz.community.comStage{
	
import flash.display.Sprite;
import flash.geom.ColorTransform;
import konstantinz.community.auxilarity.*

public class IndividualGraphicInterface extends Sprite{
	
	private const BORDERCOLOR:Number = 0x000000;
	private const INDCOLOR:Number = 0xFD2424;
	private const ADULTCOLOR:Number = 0x990000;
	private const COLLISIONCOLOR:Number = 0xFFFF00;
	private const STOPEDCOLOR:Number = 0x808080; 
	private const SCALE_COEFFICIENT:int = 4;
	private const VECTOR_LENGTH:int = 15;
	private const VECTOR_COLOR:Number = 0xFD2424;
	
	private var indSize:Number;//Размер квадрата особи
	private var growthRange:Number;//Прирост особи за один шаг
	private var remaningSteps:int
	private var indAge:String;
	private var msgString:String;
	private var messenger:Messenger;
	private var modelEvent:ModelEvent;
	private var individualMoveVector:Sprite;
	private var individualPoint:Sprite;
	private var stepNumber:int;
	private var previousStepDistance:int;
	
	public var individualBody:Sprite;
	
	
	public function IndividualGraphicInterface(minSize:int, maxSize:int=0, stepsQantaty:int=1, debugLevel:String = '3'){
		modelEvent = new ModelEvent();//Будем брать основные константы от сюда
		messenger = new Messenger(debugLevel);
		messenger.setMessageMark('Individual GUI');
		stepNumber = 0;
		growthRange = 0;
		indSize = 5;
		remaningSteps = stepsQantaty/SCALE_COEFFICIENT;
		if(maxSize > 0){//Если задан максимальный размер особи, 
			indSize = minSize;//То для начала делаем особь маленькой
			if(stepsQantaty > 1){//Если заданно количество шагов, то вычисляем прирост
				growthRange = ((maxSize - minSize)/stepsQantaty)/minSize;
				}
			}else{
				indSize = minSize;
				}
		}
		
	public function drawIndividual():void{//Рисует особь в виде цветного квадрата
		//Функция напрямую завязана на графике
		individualBody = new Sprite();
		individualPoint = new Sprite();
		
		individualPoint.graphics.lineStyle(1,BORDERCOLOR);
		individualPoint.graphics.beginFill(INDCOLOR);
		individualPoint.graphics.drawRect(0,0,indSize,indSize);
		
		individualBody.addChild(individualPoint);
		drawVectorArror();
		}
	
	public function dotStep(currenteIndividualState:Array):void{
		individualMoveVector.graphics.lineStyle(1, VECTOR_COLOR);
		indAge = currenteIndividualState.age;
		individualBody.x = currenteIndividualState.currentX;
		individualBody.y = currenteIndividualState.currentY;
		
		if(growthRange > 0 && remaningSteps > 0){
			remaningSteps--;
			individualPoint.scaleX = individualPoint.scaleX + growthRange;
			individualPoint.scaleY = individualPoint.scaleY + growthRange;
			}
		
		markIndividual(currenteIndividualState.statement);
		showAdditionMarks(currenteIndividualState);
		
		}
	
	public function markIndividual(individualState:String):void{//Отмечает цветом особей в различном состоянии
		var ct:ColorTransform = new ColorTransform();
			
		switch(individualState) { 
			case 'collision': 
				ct.color = COLLISIONCOLOR;
				individualPoint.transform.colorTransform = ct;
			break; 
					
			case 'moving':
				if(indAge == 'young'){//Помечаем молодую и взрослую особей разными цветами для наглядности
				ct.color = INDCOLOR;
				}else{
					ct.color = ADULTCOLOR;
					}
				individualPoint.transform.colorTransform = ct;
			break; 
					
		    case 'suspend':
				ct.color = STOPEDCOLOR;
				individualPoint.transform.colorTransform = ct;
				//individualMoveVector.graphics.clear();
			break;
			case 'dead'://Мертвых особей делаем невидимыми, уменьшая их размер до нуля
					individualPoint.scaleX = 0;
					individualPoint.scaleY = 0;
			break;
			default: 
				ct.color = INDCOLOR;
				individualPoint.transform.colorTransform = ct;
				msgString = 'wrong statement code';
				messenger.message(msgString, modelEvent.ERROR_MARK);
			break;
				}
		}
	
	private function resetColor():void{
		var ct:ColorTransform = new ColorTransform();
		ct.color = INDCOLOR;
		individualPoint.transform.colorTransform = ct;
		}
	
	private function drawVectorArror():void{
		var lineX:int = VECTOR_LENGTH;
		var lineY:int = 0;
		try{
			individualMoveVector = new Sprite();
	
			if(individualBody){//А то вдруг функцию вызовут до появления individualBody
				individualBody.addChild(individualMoveVector);
				individualMoveVector.x = individualBody.height/2;
				individualMoveVector.y = individualBody.width/2;
				}else{
					throw new Error('individualBody not exist')
					}
			individualMoveVector.graphics.lineStyle(1, VECTOR_COLOR);
			individualMoveVector.graphics.lineTo(lineX, lineY);
			individualMoveVector.graphics.moveTo(lineX, lineY);
			individualMoveVector.graphics.lineTo(lineX - (0.2*VECTOR_LENGTH), lineY + (0.2*VECTOR_LENGTH));
			individualMoveVector.graphics.moveTo(lineX, lineY);
			individualMoveVector.graphics.lineTo(lineX - (0.2*VECTOR_LENGTH), lineY - (0.2*VECTOR_LENGTH));
			
		}catch(e:Error){
			msgString = e.message;
			messenger.message(msgString, modelEvent.ERROR_MARK);
			individualBody = new Sprite();
			}
		}
	
	private function showAdditionMarks(currenteIndividualState:Array):void{
		if(currenteIndividualState.statement == 'moving' && currenteIndividualState.behaviour == "BestConditionsWalker" && stepDistanceHasChanged(currenteIndividualState) == 'true'){//Стрека показывается только у живой особи когда она сделала длинный шаг согласно модели поведения BestConditionWalker
			showVector(currenteIndividualState);
			}else{
				hideVector();
				}
		}
	private function hideVector():void{
		if(individualMoveVector.scaleX > 0){
			individualMoveVector.scaleX = 0;
			individualMoveVector.scaleY = 0;
			}
			}
	
	private function showVector(currenteIndividualState:Array):void{
		individualMoveVector.scaleX = 0.5;
		individualMoveVector.scaleY = 0.5;
		//Изначально вектор смотрит вправо
		
		if(currenteIndividualState.currentY != currenteIndividualState.previousY){//Если сделали шаг по вертекали
			if(currenteIndividualState.currentY < currenteIndividualState.previousY){//Если сделали вверх
				individualMoveVector.rotation = -90;
				}else{
					individualMoveVector.rotation = 90;
					}
			}

		if(currenteIndividualState.currentX != currenteIndividualState.previousX){//Если сделали шаг по горизонтали
			if(currenteIndividualState.currentX < currenteIndividualState.previousX){//Если это шаг влево
				individualMoveVector.rotation = 180;
				}else{
					individualMoveVector.rotation = 0;
					}
			}
		
		if((currenteIndividualState.currentX - individualMoveVector.width) < 0 || (currenteIndividualState.currentY - individualMoveVector.height) < 0){//Чтобы линии вектров не вылазели за пределы chessDesk
			individualMoveVector.scaleX = 0;
			individualMoveVector.scaleY = 0;
			}
		}
	
	private function stepDistanceHasChanged(currenteIndividualState:Array):String{
		var result:String = 'false'
		if(previousStepDistance != Math.abs(currenteIndividualState.currentY) - Math.abs(currenteIndividualState.previousY)){
			previousStepDistance = Math.abs(currenteIndividualState.currentY) - Math.abs(currenteIndividualState.previousY);
			result = 'true';
			}
		if(previousStepDistance != Math.abs(currenteIndividualState.currentX) - Math.abs(currenteIndividualState.previousX)){
			previousStepDistance = Math.abs(currenteIndividualState.currentX) - Math.abs(currenteIndividualState.previousX);
			result = 'true';
			}
		return result;
		}
		
	
	}
}
