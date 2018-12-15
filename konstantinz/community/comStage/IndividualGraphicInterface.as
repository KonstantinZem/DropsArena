//Цель этого класса - вынести из класса Individual все платформозависимые функции графики
package konstantinz.community.comStage{
	
import flash.display.Sprite;
import flash.geom.ColorTransform;

public class IndividualGraphicInterface extends Sprite{
	
	private const BORDERCOLOR:Number = 0x000000;
	private const INDCOLOR:Number = 0xFD2424;
	private const ADULTCOLOR:Number = 0x990000;
	private const COLLISIONCOLOR:Number = 0xFFFF00;
	private const STOPEDCOLOR:Number = 0x808080; 
	private const SCALE_COEFFICIENT:int = 4;
	private var indSize:Number;//Размер квадрата особи
	private var growthRange:Number;//Прирост особи за один шаг
	private var remaningSteps:int
	private var indAge:String;
	
	public var individualBody:Sprite;
	
	public function IndividualGraphicInterface(minSize:int, maxSize:int=0, stepsQantaty:int=1){
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
		individualBody.graphics.lineStyle(1,BORDERCOLOR);
		individualBody.graphics.beginFill(INDCOLOR);
		individualBody.graphics.drawRect(0,0,indSize,indSize);
		}
	
	public function dotStep(newX:int, newY:int, statement:String, age = 'young'):void{
		indAge = age;
		individualBody.x = newX;
		individualBody.y = newY;
		
		if(growthRange > 0 && remaningSteps > 0){
			remaningSteps--;
			individualBody.scaleX = individualBody.scaleX = individualBody.scaleX + growthRange;
			individualBody.scaleY = individualBody.scaleY = individualBody.scaleY + growthRange;
			}
		markIndividual(statement);
		}
	
	public function markIndividual(individualState:String):void{//Отмечает цветом особей в различном состоянии
		var ct:ColorTransform = new ColorTransform();
			
		switch(individualState) { 
			case 'collision': 
				ct.color = COLLISIONCOLOR;
				individualBody.transform.colorTransform = ct;
			break; 
					
			case 'moving':
				if(indAge == 'young'){//Помечаем молодую и взрослую особей разными цветами для наглядности
				ct.color = INDCOLOR;
				}else{
					ct.color = ADULTCOLOR;
					}
				individualBody.transform.colorTransform = ct;
			break; 
					
		    case 'suspend':
				ct.color = STOPEDCOLOR;
				individualBody.transform.colorTransform = ct;
			break;
			case 'dead'://Мертвых особей делаем невидимыми, уменьшая их размер до нуля
					individualBody.scaleX = 0;
					individualBody.scaleY = 0;
			break;
			default: 
				ct.color = INDCOLOR;
				individualBody.transform.colorTransform = ct;
				trace ('wrong statement code')
			break;
				}
		}
	
	private function resetColor(){
		var ct:ColorTransform = new ColorTransform();
		ct.color = INDCOLOR;
		individualBody.transform.colorTransform = ct;
		}
		
	
	}
}
