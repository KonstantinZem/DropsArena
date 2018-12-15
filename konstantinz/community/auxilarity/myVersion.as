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
		private var buildData:Date;
		private var messenger:Messenger;
		
		function myVersion(vn:String='?', dbgLevel:String='3'):void{
			buildData = new Date();
			versionNunber = vn;
			debugLevel = dbgLevel;
			messenger = new Messenger(debugLevel);
			messenger.setMessageMark('Version');
			versionText();
			msg = 'Population dynamick model. Version ' + vn + ', build' + buildData.fullYear + '\n' + 'created by Konstantin Zemoglyadchuk. \n' + 'konstantinz@bk.ru \n';
			messenger.message(msg, 1);
			}
 
        private function versionText():void{ 
            addChild(myTextBox); 
            myTextBox.htmlText = myText+ versionNunber + '<font color="#999999">; build ' + buildData.fullYear + buildData.month +  buildData.day + '</font>' ;
			myTextBox.autoSize = TextFieldAutoSize.LEFT;
		}
        } 
    }
