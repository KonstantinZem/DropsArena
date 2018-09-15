//Цель этого класса - вынести из класса Individual все платформозависимые функции графики
package konstantinz.community.comStage{
	
import flash.display.Sprite;
import flash.geom.ColorTransform;

public class IndividualGraphicInterface extends Sprite{
	
	private const BORDERCOLOR:Number = 0x000000;
	private const INDCOLOR:Number = 0x990000;
	private const COLLISIONCOLOR:Number = 0xFFFF00;
	private const STOPEDCOLOR:Number = 0x808080; 
	private var indSize:Number;//Размер квадрата особи
	private var growthRange:Number;//Прирост особи за один шаг
	
	public var individualBody:Sprite;
	
	public function IndividualGraphicInterface(minSize:int, maxSize:int=0, stepsQantaty:int=1){
		growthRange = 0;
		indSize = 5;
		if(maxSize > 0){
			indSize = minSize;
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
	
	public function nextStep(newX:int, newY:int, growth:String = 'young'):void{
		
		individualBody.x = newX;
		individualBody.y = newY;
		if(growthRange > 0 && growth == 'young'){
			individualBody.scaleX = individualBody.scaleX = individualBody.scaleX + growthRange;
			individualBody.scaleY = individualBody.scaleY = individualBody.scaleY + growthRange;
			}
		}
	
	public function markIndividual(individualState:String):void{//Отмечает цветом особей в различном состоянии
		var ct:ColorTransform = new ColorTransform();
			
		switch(individualState) { 
			case 'collision': 
				ct.color = COLLISIONCOLOR;
				individualBody.transform.colorTransform = ct;
			break; 
					
			case 'nothing':
				ct.color = INDCOLOR;
				individualBody.transform.colorTransform = ct;
			break; 
					
		    case 'stoped':
				ct.color = STOPEDCOLOR;
				individualBody.transform.colorTransform = ct;
			break;
					
			default: 
				ct.color = INDCOLOR;
				individualBody.transform.colorTransform = ct;
				}
		}
		
	
	}
}
