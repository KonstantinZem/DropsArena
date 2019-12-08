package konstantinz.community.auxilarity.gui{
	
	import flash.display.Sprite;
	import flash.text.*; 
	import flash.events.Event; 
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.geom.ColorTransform;
	import konstantinz.community.auxilarity.*;
	import konstantinz.community.auxilarity.gui.*;
	
	public class TextWindow extends Sprite{
		
		private const WINDOW_BORDER:int = 10;
		private const SCROLLERW:int = 10;
		private const BUTTON_SIZE:int = 20;
		private const CLOSE_BTN_URL:String = 'pictures/interface/close_btn.png';
		
		private var windowWidth:int;
		private var windowHeight:int;
		private var windowProportions:Number
		private var textAreaWidth:int;
		private var textAreaX:int;
		private var textAreaY:int;
		private var textLinesNumber:int;
		private var buttonX:int
		private var buttonY:int;
		private var scrollerX:int;
		private var scrollerY:int;
		
		private var msgString:String;
		private var messenger:Messenger;
		private var debugeLevel:String;
		private var textArea:TextField;
		private var scroller:Scroller;
		private var closeButton:KzSimpleButton;
		private var windowArea:Sprite
		private var windowErrors:ModelErrors;
		
		public var windowEvent:DispatchEvent;
		
		public function TextWindow(winh:int=100, winw:int=100, msg:String='message text'){
			
			debugeLevel = '3';
			//windowErrors = new ModelErrors();
			msgString = msg;
			
			ARENA::DEBUG{
				if(msgString==null){
					msgString = 'There is no message text';
					messenger.message(msgString, 0);
					}
				}
			
			windowHeight = winh;
			windowWidth = winw;
			countWindowProportion()
			
			createWindowArea();
			createTextArea(msgString);
			createScroller(scrollerY);
			createBitmapCloseButton();
			
			windowEvent = new DispatchEvent();
			
			ARENA::DEBUG{
				messenger = new Messenger(debugeLevel);
				messenger.setMessageMark('Text Window');
				messenger.message('Text Window has loaded', 2);
				}
			
			}
		
		private function countWindowProportion():void{//Исходя из размеров рамки окна, расчитывается положение в окне его других элементов
			windowProportions = windowHeight/windowWidth;
			textAreaWidth = windowWidth - WINDOW_BORDER*2 - SCROLLERW;
			textAreaY = WINDOW_BORDER*2 + BUTTON_SIZE;
			textAreaX = WINDOW_BORDER;
			buttonX = textAreaWidth - WINDOW_BORDER;
			buttonY = WINDOW_BORDER;
			scrollerX = textAreaWidth + WINDOW_BORDER;
			scrollerY = textAreaY;
			}
		
		private function createBitmapCloseButton():void{//Если скачалась иконка кнопки, вставляем иконку в кнопку
			closeButton = new KzSimpleButton();
			closeButton.setButtonSkins(CLOSE_BTN_URL);
			closeButton.height = BUTTON_SIZE;
			closeButton.width = BUTTON_SIZE;
			closeButton.x = buttonX;
			closeButton.y = buttonY;
			
			addChild(closeButton);
			closeButton.addEventListener(MouseEvent.MOUSE_DOWN, destroyWindow);
			}
		
		private function createWindowArea():void{
			windowArea = new Sprite();
			windowArea.graphics.lineStyle(4,0xCCCCCC);
		    windowArea.graphics.beginFill(0xCCCFFF);
			windowArea.graphics.drawRect(0,0,windowWidth,windowHeight + 30);
			
			addChild(windowArea);
			}
		
		private function createTextArea(msgText:String):void{
			textArea = new TextField();
			var textAreaFormat:TextFormat = new TextFormat();
			textAreaFormat.size = 15;
			textAreaFormat.align = TextFormatAlign.JUSTIFY;//Выравнивание по ширине
			
			textArea.defaultTextFormat = textAreaFormat;
			textArea.border = true; 
			textArea.background = true;
			textArea.backgroundColor = 0xFFFFFF;
			textArea.condenseWhite = false;

			textArea.width = textAreaWidth; 
			textArea.height = textAreaWidth*windowProportions; 
			textArea.x = textAreaX; 
			textArea.y = textAreaY;
			textArea.htmlText = msgText;
			
			addChild(textArea);
			}
		
		private function createScroller(ypos:int):void{
					
			scroller = new Scroller(textArea);
			scroller.setScrollerPlacement(scrollerX, scrollerY);
			addChild(scroller);	
			}
			
		private function destroyWindow(event:MouseEvent):void{//По нажатии на кнопку посылаем закрываем окно
			try{
				removeChild(textArea);
				removeChild(windowArea);
				removeChild(closeButton);
				removeChild(scroller);
				windowEvent.done();//Посылаем главной программе 
				}catch(e:Error){
					ARENA::DEBUG{
						messenger.message(e.message, 0);
						}
					}
			}
		
		

	}
}
