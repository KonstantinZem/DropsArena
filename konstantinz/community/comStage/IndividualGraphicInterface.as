﻿//Цель этого класса - вынести из класса Individual все платформозависимые функции графики
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
	private const VECTOR_COLOR:Number = 0x666666;
	
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
		individualMoveVector = new Sprite();
		individualPoint = new Sprite();
		
		individualPoint.graphics.lineStyle(1,BORDERCOLOR);
		individualPoint.graphics.beginFill(INDCOLOR);
		individualPoint.graphics.drawRect(0,0,indSize,indSize);
		
		individualBody.addChild(individualPoint);
		individualBody.addChild(individualMoveVector);
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
				individualMoveVector.graphics.clear();
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
	
	private function showAdditionMarks(currenteIndividualState:Array):void{
		if(currenteIndividualState.behaviour == "BestConditionsWalker" && stepDistanceHasChanged(currenteIndividualState) == 'true'){
			showVector(currenteIndividualState);
			}else{
				individualMoveVector.graphics.clear();
				}
		}
	
	private function showVector(currenteIndividualState:Array):void{
		var lineX:int = 0;
		var lineY:int = 0;
		
		if(currenteIndividualState.currentY != currenteIndividualState.previousY){
			if(currenteIndividualState.currentY < currenteIndividualState.previousY){//+
				lineY = VECTOR_LENGTH*(-1);
				}else{
					lineY = VECTOR_LENGTH;
					}
			}

		if(currenteIndividualState.currentX != currenteIndividualState.previousX){
			if(currenteIndividualState.currentX < currenteIndividualState.previousX){
				lineX = VECTOR_LENGTH*(-1);
				lineY = 0;
				}else{
					lineX = VECTOR_LENGTH;
					lineY = 0
					}
			}

		if(stepNumber > 0){
			individualMoveVector.graphics.clear();
			stepNumber = 0;
			}else{
				stepNumber = 1;
				individualMoveVector.graphics.lineTo(lineX, lineY);
				}
				if((currenteIndividualState.currentX - individualMoveVector.width) < 0 || (currenteIndividualState.currentY - individualMoveVector.height) < 0){//Чтобы линии вектров не вылазели за пределы chessDesk
					individualMoveVector.graphics.clear();
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
