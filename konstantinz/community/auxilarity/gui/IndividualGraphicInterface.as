//Цель этого класса - вынести из класса Individual все платформозависимые функции графики
package konstantinz.community.auxilarity.gui{
	
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.events.MouseEvent;
import konstantinz.community.comStage.*;
import konstantinz.community.auxilarity.*

public class IndividualGraphicInterface extends Sprite{
	
	private const BORDERCOLOR:Number = 0x000000;
	private const INDCOLOR:Number = 0xFD2424;
	private const ADULT_COLOR:Number = 0x990000;
	private const COLLISION_COLOR:Number = 0xFFFF00;
	private const SUSPENDET_COLOR:Number = 0x808080; 
	private const STOP_COLOR:Number = 0xFFFFFF;
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
	private var individualMigrationMark:Sprite;
	private var individualPoint:Sprite;
	private var hybernateIndividualPoint:Sprite;
	private var previousStepDistance:int;
	private var currentScale:Number;
	private var currentState:IndividualState;
	
	public var individualBody:Sprite;
	
	
	public function IndividualGraphicInterface(minSize:int, maxSize:int=0, stepsQantaty:int=1, debugLevel:String = '3'){
		modelEvent = new ModelEvent();//Будем брать основные константы от сюда
		messenger = new Messenger(debugLevel);
		messenger.setMessageMark('Individual GUI');
		growthRange = 0;
		indSize = 5;
		remaningSteps = stepsQantaty/SCALE_COEFFICIENT;
		if(maxSize > 0){//Если задан максимальный размер особи, 
			indSize = minSize;//То для начала делаем особь маленькой
			if(stepsQantaty > 0){//Если заданно количество шагов, то вычисляем прирост
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
		individualBody.addEventListener(MouseEvent.CLICK, onMouseClick);
		hybernateIndividualPoint = new Sprite();
		
		individualPoint.graphics.lineStyle(1,BORDERCOLOR);
		individualPoint.graphics.beginFill(INDCOLOR);
		individualPoint.graphics.drawRect(0,0,indSize,indSize);
		hybernateIndividualPoint.graphics.beginFill(STOP_COLOR);
		hybernateIndividualPoint.graphics.drawCircle(8, indSize,indSize);
		hybernateIndividualPoint.graphics.endFill();
		
		individualBody.addChild(individualPoint);
		individualBody.addChild(hybernateIndividualPoint);
		drawVectorArror();
		drawMigrationMark();
		//drawControlPoint(individualBody);
		//drawControlPoint(individualMigrationMark);
		}
	
	public function dotStep(currenteIndividualState:IndividualState):void{
			
		currentState = currenteIndividualState;
		individualMoveVector.graphics.lineStyle(1, VECTOR_COLOR);
		indAge = currenteIndividualState.age;
		individualBody.x = currenteIndividualState.currentX;
		individualBody.y = currenteIndividualState.currentY;
		
		if(growthRange > 0 && remaningSteps > 0){
			remaningSteps--;
			if(currenteIndividualState.statement != 'stop'){
				currentScale = individualPoint.scaleX + growthRange;
				individualPoint.scaleX = currentScale;
				individualPoint.scaleY = currentScale;
				}
			
			markIndividual(currenteIndividualState.statement);
			showAdditionMarks(currenteIndividualState);
			}
		
		}
		
	public function age(newAge:int):void{
		
		try{
		if(!individualPoint){
			throw new Error('Individual point not exist');
			}
		if(newAge > 0){
			individualPoint.scaleX = growthRange*newAge;
			individualPoint.scaleY = growthRange*newAge;
		
			}else{
				throw new Error('New individual age is less or equial zerro');
				}
			}catch(e:Error){
				msgString = e.message;
				messenger.message(msgString, modelEvent.ERROR_MARK);
				}
		}
	
	public function markIndividual(individualState:String):void{//Отмечает цветом особей в различном состоянии
		var ct:ColorTransform = new ColorTransform();
			
		switch(individualState) { 
			case 'collision': 
				ct.color = COLLISION_COLOR;
				individualPoint.transform.colorTransform = ct;
			break; 
					
			case 'moving':
				if(indAge == 'young'){//Помечаем молодую и взрослую особей разными цветами для наглядности
				ct.color = INDCOLOR;
				}else{
					ct.color = ADULT_COLOR;
					}
				individualPoint.transform.colorTransform = ct;
				individualPoint.scaleX = currentScale;
				individualPoint.scaleY = currentScale;
				individualPoint.visible = true;
				hybernateIndividualPoint.visible = false;
			break; 
					
		    case 'suspend':
				ct.color = SUSPENDET_COLOR;
				individualPoint.transform.colorTransform = ct;
			break;
			case 'stop':
				ct.color = STOP_COLOR;
				individualPoint.transform.colorTransform = ct;
				individualPoint.visible = false;
				hybernateIndividualPoint.visible = true;
			break;
			case 'dead'://Мертвых особей делаем невидимыми, уменьшая их размер до нуля
				individualPoint.visible = false;
				hybernateIndividualPoint.visible = false;
			break;
			default: 
				ct.color = INDCOLOR;
				individualPoint.transform.colorTransform = ct;
				msgString = 'Wrong statement code';
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
				individualBody.setChildIndex(individualMoveVector, 0);
				individualMoveVector.x = individualBody.height/2;
				individualMoveVector.y = individualBody.width/2;
				}else{
					throw new Error('individualBody not exist');
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
	private function drawMigrationMark():void{
		var lineX:int = 0;
		var lineY:int = 0;
		try{
			individualMigrationMark = new Sprite();
	
			if(individualBody){//А то вдруг функцию вызовут до появления individualBody
				individualBody.addChild(individualMigrationMark);
				individualMigrationMark.x = individualBody.height/2;
				individualMigrationMark.y = individualBody.width/2;
				}else{
					throw new Error('individualBody not exist');
					}
			individualMigrationMark.graphics.beginFill(0xffffff); 
			individualMigrationMark.graphics.lineTo (lineX, lineY);
			individualMigrationMark.graphics.lineTo (lineX - (0.2*VECTOR_LENGTH), lineY + (0.2*VECTOR_LENGTH));
			individualMigrationMark.graphics.lineTo (lineX - (0.2*VECTOR_LENGTH), lineY - (0.2*VECTOR_LENGTH));
			
		}catch(e:Error){
			msgString = e.message;
			messenger.message(msgString, modelEvent.ERROR_MARK);
			individualBody = new Sprite();
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
		
			if(currenteIndividualState.statement == 'moving'){
				switch(currenteIndividualState.behaviour){
					case "BestConditionsWalker":
						showMark(individualMoveVector, currenteIndividualState);
					break;
					case "MigrationBehaviour":
						showMark(individualMigrationMark, currenteIndividualState);
					break;
					case 'RandomWalker':
						hideMark(individualMigrationMark);
						hideMark(individualMoveVector);
					break;
					default:
						hideMark(individualMigrationMark);
						hideMark(individualMoveVector);
						throw new Error('Uncnow individual behaviour name');
					break;
					}
				}else{
					hideMark(individualMigrationMark);
					hideMark(individualMoveVector);
				}
			}catch(e:Error){
				trace(e.message + ': ' + currenteIndividualState.behaviour)
				}
		}
	
	private function showMark(individualMark:Sprite, currenteIndividualState:IndividualState):void{
		
		individualMark.scaleX = individualPoint.scaleX/2.5;
		individualMark.scaleY = individualPoint.scaleY/2.5;
		individualMark.x = individualPoint.x;
		individualMark.y = individualPoint.y;
		//Изначально вектор смотрит вправо
		
		switch(currenteIndividualState.direction){
			case 0: //Стоим наместе
				hideMark(individualMark);
			break;
			case 3://Направо
				individualMark.rotation = 0;
				individualMark.y = individualPoint.y + individualPoint.height/2 -2;
				individualMark.x = individualPoint.x + individualPoint.width;
			break;
			case 4://Налево
				individualMark.rotation = 180;
				individualMark.y = individualPoint.y + individualPoint.height/2 -2;
				individualMark.x = individualPoint.x - individualPoint.width/2;
			break;
			case 1: //Вниз
				individualMark.rotation = 90;
				individualMark.x = individualPoint.x + individualPoint.width/2 -2;
				individualMark.y = individualPoint.y + individualPoint.height;
			break;
			case 2://Вверх
				individualMark.rotation = -90;
				individualMark.x = individualPoint.x + individualPoint.width/2 -2;
				individualMark.y = individualPoint.y - individualPoint.height/2;
			break;
			}

		}
	
	private function hideMark(individualMark:Sprite):void{
		individualMark.scaleX = 0;
		individualMark.scaleY = 0;
		}
	
	private function onMouseClick(event:MouseEvent):void{
		trace('x=' + individualBody.x + ';' + 'y=' + individualBody.y)
	};
	
	}
}
