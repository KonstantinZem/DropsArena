//Цель этого класса - вынести из класса Individual все платформозависимые функции графики
package konstantinz.community.comStage{
	
import flash.display.Sprite;
import flash.geom.ColorTransform;

public class IndividualGraphicInterface extends Sprite{
	
	private const BORDERCOLOR:Number = 0x000000;
	private const INDCOLOR:Number = 0x990000;
	private const COLLISIONCOLOR:Number = 0xFFFF00;
	private const STOPEDCOLOR:Number = 0x808080; 
	private var indSize:int;//Размер квадрата особи
	
	public var individualBody:Sprite;
	
	public function IndividualGraphicInterface(){
		indSize = 5;
		}
	
	public function setIndividualSize(newSize:int):void{
		indSize = newSize;
		}
		
	public function drawIndividual():void{//Рисует особь в виде цветного квадрата
		//Функция напрямую завязана на графике
		individualBody = new Sprite();
		individualBody.graphics.lineStyle(1,BORDERCOLOR);
		individualBody.graphics.beginFill(INDCOLOR);
		individualBody.graphics.drawRect(0,0,indSize,indSize);
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
