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
	import flash.geom.ColorTransform;
	import konstantinz.community.auxilarity.*;

public class SimpleButton extends Sprite{
	
	private const BUTTON_SIZE:int = 20;
	private const BUTTON_BORDER_COLOR = 0xFF3333;
	private const BUTTONE_COLOR = 0xFF0000;
	
	private var mainImage_inactive:Bitmap
	private var buttonMask:Sprite

	public function SimpleButton(){
		trace('Button')
	createBasicButton()
	}
	
	public function setButtonSkins(mainImage:String, secondClickImage:String = 'empty'):void{
		
		}
		
	private function createBasicButton(){
			buttonMask = new Sprite();
			trace(buttonMask)
			buttonMask.x = 0;
			buttonMask.y = 0;
			buttonMask.height = 20
			buttonMask.width = 20
			buttonMask.addEventListener(MouseEvent.MOUSE_ROLL, onMouseRollover);
			
			buttonMask.graphics.lineStyle(0.1,BUTTON_BORDER_COLOR);
		    buttonMask.graphics.beginFill(BUTTONE_COLOR);
			buttonMask.graphics.drawRect(0,0,BUTTON_SIZE,BUTTON_SIZE);
			
			this.addChild(buttonMask);
			}
			
	private function onMouseRollover(e:MouseEvent){
		trace('____')
		}

}

}
