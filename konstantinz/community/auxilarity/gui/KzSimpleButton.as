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
	//import flash.geom.ColorTransform;
	import konstantinz.community.auxilarity.*;
	import konstantinz.community.auxilarity.gui.*;

public class KzSimpleButton extends Sprite{
	
	private const BUTTON_SIZE:int = 50;
	private const BUTTON_BORDER_COLOR = 0xFF3333;
	private const BUTTONE_COLOR = 0xFF0000;
	
	private var mainImage_inactive:Bitmap
	private var buttonMask:Sprite
	private var loaders:Array;
	private var inactiveBtn:Sprite
	private var activeBtn:Sprite
	private var pushedBtn:Sprite
	
	public var btnEvent:DispatchEvent;
	
	
	public function KzSimpleButton(){
		btnEvent = new DispatchEvent();
	}
	
	public function setButtonSkins(mainImage:String, secondClickImage:String = 'empty'):void{
		var parsedFileName:Array = mainImage.split('.')
		var fileName:String = parsedFileName[0];
		var fileExtension:String = parsedFileName[1];
		inactiveBtn = new BitmapElement(mainImage,50,50)
		addChild(inactiveBtn)
		activeBtn = new BitmapElement(fileName + '_r.' + fileExtension,50,50)
		addChild(activeBtn)
		pushedBtn = new BitmapElement(fileName + '_p.' + fileExtension,50,50)
		addChild(pushedBtn)
		inactiveBtn.alpha = 1
		activeBtn.alpha = 0
		pushedBtn.alpha = 0
		createClickableArea()
		}
		
	private function createClickableArea(){
		
			buttonMask = new Sprite();
			buttonMask.x = 0;
			buttonMask.y = 0;
			
			buttonMask.graphics.lineStyle(0.1,BUTTON_BORDER_COLOR);
		    buttonMask.graphics.beginFill(BUTTONE_COLOR);
			buttonMask.graphics.drawRect(0,0,BUTTON_SIZE,BUTTON_SIZE);
			addChild(buttonMask);
			buttonMask.height = this.height;//Высота и ширина области на д кнопкой будут раны высоте кнопки заданной в главной программе
			buttonMask.width = this.width;
			buttonMask.alpha = 0//Делаем область над кнопкой прозрачной
			
			buttonMask.addEventListener(MouseEvent.ROLL_OVER, btnMouseRollover);
			buttonMask.addEventListener(MouseEvent.ROLL_OUT, btnMouseRollout);
			buttonMask.addEventListener(MouseEvent.MOUSE_DOWN, btnMouseDown);
			buttonMask.addEventListener(MouseEvent.MOUSE_UP, btnMouseUp);
			
			}
			
	private function btnMouseRollover(e:MouseEvent){
		inactiveBtn.alpha = 0
		activeBtn.alpha = 1
		pushedBtn.alpha = 0
		}
		
	private function btnMouseRollout(e:MouseEvent){
		inactiveBtn.alpha = 1
		activeBtn.alpha = 0
		pushedBtn.alpha = 0
		}
	
	private function btnMouseDown(e:MouseEvent){
		inactiveBtn.alpha = 0
		activeBtn.alpha = 0
		pushedBtn.alpha = 1
		btnEvent.clicking();
		}
	private function btnMouseUp(e:MouseEvent){
		inactiveBtn.alpha = 0
		activeBtn.alpha = 1
		pushedBtn.alpha = 0
		}

}

}
