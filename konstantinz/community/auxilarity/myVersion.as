package konstantinz.community.auxilarity{ 
    import flash.display.Sprite; 
    import flash.text.*; 
 
    public class myVersion extends Sprite {
		/*Вынес это в отдельный класс, чтобы не захломлять
		основной код программы второстепенными вещами*/
        private var myTextBox:TextField = new TextField(); 
        private var myText:String = "<b>Drops' Arena: version</b>: ";
		private var versionNunber:String;
		private var debugLevel:String;
		private var msg:String;
		private var messenger:Messenger;
		
		function myVersion(vn:String='?', dbgLevel:String='3'):void{
			versionNunber = vn;
			debugLevel = dbgLevel;
			messenger = new Messenger(debugLevel);
			messenger.setMessageMark('Version');
			versionText();
			msg = 'Population dynamick model. Version ' + vn + '\n' + 'created by Konstantin Zemoglyadchuk. \n' + 'konstantinz@bk.ru \n';
			messenger.message(msg, 1);
			}
 
        private function versionText():void{ 
            addChild(myTextBox); 
            myTextBox.htmlText = myText+ versionNunber;
			myTextBox.autoSize = TextFieldAutoSize.LEFT;
		}
        } 
    }
