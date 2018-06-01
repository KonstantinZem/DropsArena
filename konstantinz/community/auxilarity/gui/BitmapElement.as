package konstantinz.community.auxilarity.gui{
	
	import flash.display.Sprite;
	import flash.display.Bitmap;
    import flash.display.BitmapData;
	import flash.events.Event; 
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.display.Loader;
    import flash.display.LoaderInfo;
	import konstantinz.community.auxilarity.*;
	
	public class BitmapElement extends Sprite{
		private const BUTTON_BORDER_COLOR:Number = 0xFF3333;
		private const BUTTONE_COLOR:Number = 0xFF0000;
		
		private var imageLoader:Loader;
		private var btnIcon:Bitmap;
		private var bmp:Bitmap;
		private var elementHeight:Number;
		private var elementWidth:Number;
		private var msgString:String;
		private var debugeLevel:String;
		private var loadedImageName:String;
		private var BitmampErrors:ModelErrors;
		private var messenger:Messenger;
	
	public function BitmapElement(imageName:String,elH:Number,elW:Number):void{
		loadedImageName = imageName
		BitmampErrors = new ModelErrors();
		debugeLevel = '3';
		messenger = new Messenger(debugeLevel);
		elementHeight = elH;
		elementWidth = elW;
		imageLoader = new Loader();
		imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplite);
		imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
		imageLoader.load(new URLRequest(imageName));
		}
	
	private function onComplite(e:Event):void{
		bmp = imageLoader.content as Bitmap;
		btnIcon = new Bitmap(bmp.bitmapData);
		addChild(btnIcon)
		btnIcon.height = elementHeight
		btnIcon.width = elementWidth
		}
		
	private function onError(e:IOErrorEvent):void{//Если картинка не скачалась, рисуем кнопку в виде простого квадрата
		this.graphics.lineStyle(0.1,BUTTON_BORDER_COLOR);
		this.graphics.drawRect(0,0,elementHeight,elementWidth);
		msgString = 'Picture: ' + loadedImageName + '. ' + BitmampErrors.fileNotFound;
		messenger.message(msgString, 0);
		}
	
	}
}
