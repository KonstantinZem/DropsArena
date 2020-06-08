package konstantinz.community.auxilarity.gui{
	import flash.display.Sprite;
	
	public class IndividualPoint extends Sprite{
		
		private const BORDERCOLOR:Number = 0x000000;
		private const INDCOLOR:Number = 0xFD2424;
		private const ADULT_COLOR:Number = 0x990000;
		private const COLLISION_COLOR:Number = 0xFFFF00;
		private const SUSPENDET_COLOR:Number = 0x808080; 
		private const STOP_COLOR:Number = 0xFFFFFF;
		private const VECTOR_LENGTH:Number = 5;
		private const VECTOR_COLOR:Number = 0xFD2424;
		
		private var walkindIndY:Sprite;
		private var walkindIndA:Sprite;
		private var collisionInd:Sprite;
		private var suspendInd:Sprite;
		private var hybernationInd:Sprite;
		private var individualMigrationMark:Sprite;
		private var individualMoveVector:Sprite;
		private var indSize:Number = 2;//Размер квадрата особи
		
		public function IndividualPoint():void{
			drWalkingA();
			drWalkingY();
			drColision();
			drSuspend();
			drawHybernate();
			drawMigrationMark();
			drawVectorArror();
		};
		
		private function drWalkingY():void{
			walkindIndY = new Sprite();
			
			walkindIndY.graphics.lineStyle(0.3,BORDERCOLOR);
			walkindIndY.graphics.beginFill(INDCOLOR);
			walkindIndY.graphics.drawRect(0,0,indSize,indSize);
			walkindIndY.graphics.endFill();
			addChild(walkindIndY);
			}
		
		private function drWalkingA():void{
			walkindIndA = new Sprite();
			
			walkindIndA.graphics.lineStyle(0.3,BORDERCOLOR);
			walkindIndA.graphics.beginFill(ADULT_COLOR);
			walkindIndA.graphics.drawRect(0,0,indSize,indSize);
			walkindIndA.graphics.endFill();
			addChild(walkindIndA);
			}
		
		private function drColision():void{
			collisionInd = new Sprite();
			
			collisionInd.graphics.lineStyle(0.3,BORDERCOLOR);
			collisionInd.graphics.beginFill(COLLISION_COLOR);
			collisionInd.graphics.drawRect(0,0,indSize,indSize);
			collisionInd.graphics.endFill();
			collisionInd.visible = false;
			addChild(collisionInd);
			
			}
		private function drSuspend():void{
			suspendInd = new Sprite();
			
			suspendInd.graphics.lineStyle(0.3,BORDERCOLOR);
			suspendInd.graphics.beginFill(SUSPENDET_COLOR);
			suspendInd.graphics.drawRect(0,0,indSize,indSize);
			suspendInd.graphics.endFill();
			suspendInd.visible = false;
			addChild(suspendInd);
			}
		
		private function drawHybernate():void{
			hybernationInd = new Sprite();
			
			hybernationInd.graphics.beginFill(STOP_COLOR);
			hybernationInd.graphics.drawCircle(1, indSize/3,indSize/3);
			hybernationInd.graphics.endFill();
		
			addChild(hybernationInd);
			hybernationInd.scaleX = 1
			hybernationInd.scaleY = 1
			
			};
		
		private function drawMigrationMark():void{
			var lineX:int = 0;
			var lineY:int = 0;
		
			individualMigrationMark = new Sprite();
	
			addChild(individualMigrationMark);
			
			individualMigrationMark.graphics.beginFill(0xffffff); 
			individualMigrationMark.graphics.lineTo (lineX, lineY);
			individualMigrationMark.graphics.lineTo (lineX - 1, lineY + 1);
			individualMigrationMark.graphics.lineTo (lineX - 1, lineY - 1);
			individualMigrationMark.x = walkindIndA.height*2;
			individualMigrationMark.y = walkindIndA.width/2;
			
			individualMigrationMark.visible = false
			}
			
		private function drawVectorArror():void{
			var lineX:int = 3;
			var lineY:int = 0;

			individualMoveVector = new Sprite();
	
			addChild(individualMoveVector);
			
			individualMoveVector.x = walkindIndA.height/2;
			individualMoveVector.y = walkindIndA.width/2;
	
			individualMoveVector.graphics.lineStyle(0.5, VECTOR_COLOR);
			individualMoveVector.graphics.lineTo(lineX, lineY);
			individualMoveVector.graphics.moveTo(lineX, lineY);
			individualMoveVector.graphics.lineTo(lineX - 1, lineY + 1);
			individualMoveVector.graphics.moveTo(lineX, lineY);
			individualMoveVector.graphics.lineTo(lineX - 1, lineY - 1);
		
			individualMoveVector.visible = false;
			}
		
		public function showState(individualState:String):void{
			switch(individualState) { 
			case 'moving_yong': 
				walkindIndY.visible = true;
				walkindIndA.visible = false;
				collisionInd.visible = false;
				suspendInd.visible = false;
				hybernationInd.visible = false;
			break;
			case 'moving_adult':
				walkindIndY.visible = false;
				walkindIndA.visible = true;
				collisionInd.visible = false;
				suspendInd.visible = false;
				hybernationInd.visible = false
			break;
			case 'collision':
				walkindIndY.visible = false;
				walkindIndA.visible = false;
				collisionInd.visible = true;
				suspendInd.visible = false;
				hybernationInd.visible = false
			break;
			case 'suspend':
				walkindIndY.visible = false;
				walkindIndA.visible = false;
				collisionInd.visible = false;
				suspendInd.visible = true;
				hybernationInd.visible = false;
			break;
			case 'hybernate':
				walkindIndY.visible = false;
				walkindIndA.visible = false;
				collisionInd.visible = false;
				suspendInd.visible = false;
				hybernationInd.visible = true;
			break;
			default:
				walkindIndY.visible = true;
				walkindIndA.visible = false;
				collisionInd.visible = false;
				suspendInd.visible = false;
				hybernationInd.visible = false
			break
			}
			
		};
		
		public function markAs(markName:String):void{
			switch(markName) { 
				case 'migration': 
					individualMigrationMark.visible = true;
				break;
				case 'bestConditions':
					individualMoveVector.visible = true;
				break;
				default:
					trace("Wrong mark Name: " + markName);
					hideMarks();
				break
			}
				
		};
		
		public function hideMarks():void{
			individualMigrationMark.visible = false;
			individualMoveVector.visible = false;
			}
	}
}
