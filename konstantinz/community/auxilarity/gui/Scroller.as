package konstantinz.community.auxilarity.gui{

import flash.geom.Rectangle;
import flash.geom.ColorTransform;
import flash.display.Sprite;
import flash.display.Graphics;
import flash.text.*; 
import flash.events.MouseEvent;
import flash.events.FocusEvent;
import konstantinz.community.auxilarity.*;

public class Scroller extends Sprite{

private const SCROLLERH:int = 50;
private const SCROLLERW:int = 10;
private const SCROLLE_COLOR:Number = 0x66CCCC;
private const SCROLLE_COLOR_ON_FOCUS:Number = 0x0099FF;
private const SCRBODE_COLOR:Number = 0x0000FF;
private const SCRBODER:int = 1;

private var scButtonPict:Graphics
private var scStripPicture:Graphics;
private var scStrip:Sprite;
private var scButton:Sprite;
private var scButtonX:int;
private var scButtonY:int;
private var scButtonHeight:int;
private var scrolledTextArea:TextField;

public var scrollEvent:DispatchEvent;

function Scroller(scrText:TextField){
	scrolledTextArea = scrText;
	scButtonHeight = (scrolledTextArea.height/scrolledTextArea.textHeight)*100
	scButtonX = 0;
	scButtonY = 0;
	scButton = new Sprite()
	scStrip = new Sprite()
	scButtonPict = scButton.graphics;
	scStripPicture = scStrip.graphics;
	drawScButton()
	drawScStrip()
	scStrip.x = 0
	scStrip.y = 0
	scButton.x = scStrip.x
	scButton.y = 0;
	addChild(scStrip)
	addChild(scButton)
	scrollEvent = new DispatchEvent();
	}

private function drawScButton(){
	scButtonPict.lineStyle(SCRBODER, SCRBODE_COLOR, 0.5);
	scButtonPict.beginFill(SCROLLE_COLOR, 0.5);
	scButtonPict.drawRoundRect(scButtonX,scButtonY,SCROLLERW,scButtonHeight,10);
	scButtonPict.endFill();
	
	addEventListener(MouseEvent.MOUSE_DOWN, initScroll);
	addEventListener(MouseEvent.MOUSE_UP, stopScroll);
	addEventListener(MouseEvent.ROLL_OVER, onRollIn);
	addEventListener(MouseEvent.ROLL_OUT, onRollOut);

	}
private function drawScStrip(){
	scStripPicture.lineStyle();
	scStripPicture.beginFill(0x0000FF, 0.2);
	scStripPicture.drawRect(scButtonX,scButtonY,SCROLLERW,scrolledTextArea.height);
	scStripPicture.endFill()
	}

private function dragScroller(event:MouseEvent){
	if(scStrip.mouseY < scStrip.height - scButton.height){
		scButton.y = scStrip.mouseY;//Помещам ползунок скроллера в точку нд скроллбаром, где сейчас находится мышь
		scrollEvent.scrolling();
		scrolledTextArea.scrollV = Math.round(((scButton.y - scStrip.y)/scrolledTextArea.height)*scrolledTextArea.maxScrollV);
		}
	}
private function initScroll(event:MouseEvent){
	addEventListener(MouseEvent.MOUSE_MOVE, dragScroller);
	}
private function stopScroll(event:MouseEvent){
	removeEventListener(MouseEvent.MOUSE_MOVE, dragScroller);
	}

private function onRollIn(event:MouseEvent){
	var ct:ColorTransform = new ColorTransform();
	ct.color = SCROLLE_COLOR_ON_FOCUS;
	scButton.transform.colorTransform = ct
	}

private function onRollOut(event:MouseEvent){
	var ct:ColorTransform = new ColorTransform();
	ct.color = SCROLLE_COLOR;
	scButton.transform.colorTransform = ct;
	removeEventListener(MouseEvent.MOUSE_MOVE, dragScroller);
	}

public function setScrollerPlacement(scrx:int=0,scry:int=0){
	this.x = scrx;
	this.y = scry;
	}

}
}
