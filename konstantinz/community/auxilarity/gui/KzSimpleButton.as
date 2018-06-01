package konstantinz.community.auxilarity.gui{
	
	import flash.display.Sprite;
	import flash.display.Bitmap;
    import flash.display.BitmapData;
	import flash.events.Event; 
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.display.Loader;
    import flash.display.LoaderInfo;
	import konstantinz.community.auxilarity.*;
	import konstantinz.community.auxilarity.gui.*;

public class KzSimpleButton extends Sprite{
	
	private const BUTTON_SIZE:int = 50;
	private const BUTTON_BORDER_COLOR:Number = 0xFF3333;
	private const BUTTONE_COLOR:Number = 0xFF0000;
	
	private var mainImage_inactive:Bitmap
	private var buttonMask:Sprite;
	
	//First state buttons
	private var inactiveBtnF:Sprite;
	private var activeBtnF:Sprite;
	private var pushedBtnF:Sprite;
	
	//Second state buttons
	private var inactiveBtnS:Sprite;
	private var activeBtnS:Sprite;
	private var pushedBtnS:Sprite;
	
	private var actionType:String;
	private var msgString:String;
	private var debugLevel:String;
	private var currentState:String;
	private var messanger:Messenger;
	
	public var buttonEvent:DispatchEvent;
	
	public function KzSimpleButton(dbgLevel:String = '1'){
		debugLevel = dbgLevel;
		buttonEvent = new DispatchEvent();
		messanger = new Messenger(debugLevel);
		messanger.setMessageMark('Button');
		currentState = 'first_click';
	}
	
	private function parseFileName(fileName:String):Array{
		var image:Array = new Array;
		var parsedFileName:Array = fileName.split('.');
		
		image['name'] = new Object;
		image['extension'] = new Object;
		
		image['name'] = parsedFileName[0];
		image['extension'] = parsedFileName[1];
		return image;
		}
	
	public function setButtonSkins(mainImage:String, secondClickImage:String = 'empty'):void{
		var img:Array;
		
		img = parseFileName(mainImage);

		actionType = 'one_state';//Говорим, что кнопка будет иметь только одно состояние
		msgString = 'Work as one state button';
		
		inactiveBtnF = new BitmapElement(mainImage,50,50);
		addChild(inactiveBtnF);
		
		activeBtnF = new BitmapElement(img['name'] + '_r.' + img['extension'],50,50);
		addChild(activeBtnF);
		
		pushedBtnF = new BitmapElement(img['name'] + '_p.' + img['extension'],50,50);
		addChild(pushedBtnF);
		
		inactiveBtnF.alpha = 1;
		activeBtnF.alpha = 0;
		pushedBtnF.alpha = 0;
		
		if(secondClickImage != 'empty'){//Если конструктору предана картинка для второго состояния кнопки
			
			img = parseFileName(secondClickImage);
			
			actionType = 'two_states';//Кнопка будет иметь два состояния
			msgString = 'Work as two states button';
			
			inactiveBtnS = new BitmapElement(secondClickImage,50,50);
			addChild(inactiveBtnS);
		
			activeBtnS = new BitmapElement(img['name'] + '_r.' + img['extension'],50,50);
			addChild(activeBtnS);
		
			pushedBtnS = new BitmapElement(img['name'] + '_p.' + img['extension'],50,50);
			addChild(pushedBtnS);
		
			inactiveBtnS.alpha = 0;
			activeBtnS.alpha = 0;
			pushedBtnS.alpha = 0;
			}
		
		createClickableArea();
		messanger.message(msgString, 2);
		}
		
	private function createClickableArea():void{
		
			buttonMask = new Sprite();
			buttonMask.x = 0;
			buttonMask.y = 0;
			
			buttonMask.graphics.lineStyle(0.1,BUTTON_BORDER_COLOR);
		    buttonMask.graphics.beginFill(BUTTONE_COLOR);
			buttonMask.graphics.drawRect(0,0,BUTTON_SIZE,BUTTON_SIZE);
			addChild(buttonMask);
			buttonMask.height = this.height;//Высота и ширина области на д кнопкой будут раны высоте кнопки заданной в главной программе
			buttonMask.width = this.width;
			buttonMask.alpha = 0;//Делаем область над кнопкой прозрачной
			
			buttonMask.addEventListener(MouseEvent.ROLL_OVER, btnMouseRollover);
			buttonMask.addEventListener(MouseEvent.ROLL_OUT, btnMouseRollout);
			buttonMask.addEventListener(MouseEvent.MOUSE_DOWN, btnMouseDown);
			buttonMask.addEventListener(MouseEvent.MOUSE_UP, btnMouseUp);
			
			}
			
	private function btnMouseRollover(e:MouseEvent):void{
		if(actionType == 'one_state'){
			inactiveBtnF.alpha = 0;
			activeBtnF.alpha = 1;
			pushedBtnF.alpha = 0;
			}else{
				switch(currentState){
					case 'first_click':
						inactiveBtnF.alpha = 0;
						activeBtnF.alpha = 1;
						pushedBtnF.alpha = 0;
				
						inactiveBtnS.alpha = 0;
						activeBtnS.alpha = 0;
						pushedBtnS.alpha = 0;
					break;
					case 'second_click':
						inactiveBtnF.alpha = 0;
						activeBtnF.alpha = 0;
						pushedBtnF.alpha = 0;
						
						inactiveBtnS.alpha = 0;
						activeBtnS.alpha = 1;
						pushedBtnS.alpha = 0;
					break;
					}
				}
		}
		
	private function btnMouseRollout(e:MouseEvent):void{
		if(actionType == 'one_state'){
			inactiveBtnF.alpha = 1;
			activeBtnF.alpha = 0;
			pushedBtnF.alpha = 0;
			}else{
				switch(currentState){
					case 'first_click':
						inactiveBtnF.alpha = 1;
						activeBtnF.alpha = 0;
						pushedBtnF.alpha = 0;
				
						inactiveBtnS.alpha = 0;
						activeBtnS.alpha = 0;
						pushedBtnS.alpha = 0;
					break;
					case 'second_click':
						inactiveBtnF.alpha = 0;
						activeBtnF.alpha = 0;
						pushedBtnF.alpha = 0;
				
						inactiveBtnS.alpha = 1;
						activeBtnS.alpha = 0;
						pushedBtnS.alpha = 0;
					break;
				}
			}
		}
	
	private function btnMouseDown(e:MouseEvent):void{
		
		
		if(actionType=='two_states'){//Если у кнопки есть два состояния
			if(currentState=='first_click'){
				currentState = 'second_click';
				}else{
					currentState='first_click';
					}
		
		if(actionType == 'one_state'){
			inactiveBtnF.alpha = 0;
			activeBtnF.alpha = 0;
			pushedBtnF.alpha = 1;
			
			buttonEvent.clicking('single_click');//Посылаем сообщение об нажатии
			}else{
				switch(currentState){
					case 'first_click':
						inactiveBtnF.alpha = 0;
						activeBtnF.alpha = 0;
						pushedBtnF.alpha = 0;
						buttonEvent.clicking('second_click');
				
						inactiveBtnS.alpha = 0;
						activeBtnS.alpha = 0;
						pushedBtnS.alpha = 1;
					break;
					case 'second_click':
						inactiveBtnF.alpha = 0;
						activeBtnF.alpha = 0;
						pushedBtnF.alpha = 1;
				
						inactiveBtnS.alpha = 0;
						activeBtnS.alpha = 0;
						pushedBtnS.alpha = 0;
						buttonEvent.clicking('first_click');
					break;
				}
			}
		}
		
		messanger.message(currentState, 3);//Говорим, в каком сотоянии находится кнопка
		}
	private function btnMouseUp(e:MouseEvent):void{
		if(actionType == 'one_state'){
			inactiveBtnF.alpha = 1;
			activeBtnF.alpha = 0;
			pushedBtnF.alpha = 0;
			}else{
				switch(currentState){
					case 'first_click':
						inactiveBtnF.alpha = 0;
						activeBtnF.alpha = 1;
						pushedBtnF.alpha = 0;
				
						inactiveBtnS.alpha = 0;
						activeBtnS.alpha = 0;
						pushedBtnS.alpha = 0;
					break;
					case 'second_click':
						inactiveBtnF.alpha = 0;
						activeBtnF.alpha = 0;
						pushedBtnF.alpha = 0;
				
						inactiveBtnS.alpha = 0;
						activeBtnS.alpha = 1;
						pushedBtnS.alpha = 0;
					break;
				}
			}
		}

}

}
