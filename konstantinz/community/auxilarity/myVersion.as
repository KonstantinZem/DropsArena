package konstantinz.community.auxilarity{ 
    import flash.display.Sprite; 
    import flash.text.*; 
 
    public class myVersion extends Sprite {
		/*Вынес это в отдельный класс, чтобы не захломлять
		основной код программы второстепенными вещами*/
        private var myTextBox:TextField = new TextField(); 
        private var myText:String = "<b>version</b>: ";
		private var versionNunber:String;
		private var  debugLevel:Boolean;
		private var msg:String;
		
		function myVersion(vn:String='?', dbgLevel:Boolean=false){
			this.versionNunber = vn;
			this.debugLevel = dbgLevel;
			versionText();
			msg = '\n Population dynamick model. Version ' + vn + '\n' + 'created by Konstantin Zemoglyadchuk. \n' + 'konstantinz@bk.ru \n'
			debugMsg(msg)
			}
 
        private function versionText():void{ 
            addChild(myTextBox); 
            myTextBox.htmlText = myText+ versionNunber;
        } 
		private function debugMsg(msg:String):void{
				if(debugLevel){
					trace(msg);
				}
    } 
}
}