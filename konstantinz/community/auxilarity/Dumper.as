package konstantinz.community.auxilarity{

import flash.net.FileReference; 
import konstantinz.community.comStage.*;
import konstantinz.community.auxilarity.*

public class Dumper{
	
	private const HEAD:String = '<html>\n<head><link rel=stylesheet href="dump.css" type="text/css"></head>\n<body>\n';
	private const END:String = '</html>';
	private var msgString:String;
	private var fileData:String;
	private var tableHead:String;
	private var tableBoady:String;
	private var varNames:Array;
	private var stage:CommunityStage;
	private var messenger:Messenger;
	private var modelEvent:ModelEvent;
	
	public function Dumper(commStage:CommunityStage, debugLevel:String){
		stage = commStage;
		modelEvent = new ModelEvent();//Будем брать основные константы от сюда
		messenger = new Messenger(debugLevel);
		messenger.setMessageMark('Dumper');
	}
	
	public function saveDumpFile():void{
		getVarNames();
		tableHead = tHead(stage);
		tableBoady = tBoady(stage);
		fileData = HEAD + '<table>\n' + '<thead><tr>' + tableHead + '</tr></thead>\n<tbody>' + tableBoady + '</tbody></table>\n' + END;
		downloadFile();
	};
	
	private function tHead(stage:CommunityStage):String{
		var tHead:String = '';
		var rowNames:String = getRowsNames(stage);
		var tableLength:int = stage.chessDesk[0].length;
		var tmp:String
		
		for(var i:int = 0; i < tableLength; i++){
			tmp = insertTdTags(rowNames, ';', varNames)
			tHead += tmp;
		}
		return tHead;
		};
	
	private function getVarNames():void{
		var rawNames:String = getRowsNames(stage);
		varNames = new Array;
		varNames = rawNames.split(';');
	};
	
	private function tBoady(stage:CommunityStage):String{

		var body:String='';
		var cellData:String;
		var tableLength:int = stage.chessDesk.length;
		var tableColumnLength:int = stage.chessDesk[0].length;
		
		for(var i:int = 0; i < tableLength; i++){
		
			for(var j:int = 0; j < tableColumnLength; j++){
				cellData = stage.getCellContent(i,j,'only_numbers');
				cellData = insertTdTags(cellData, ';', varNames);
				body += cellData + '</td>\n';
			}
			
			body += '</tr>\n<tr>\n';
		}
		return body;
	};
	
	private function insertTdTags(rawData:String, toReplace:String, classNames:Array):String{
		try{
			if(rawData == null|| classNames == null){
				throw new Error('Argument is null');
			}
			var tmp:Array = new Array();
			var htmlStr:String = '';
			var tegBegin:String = '<td class="';
			var tegEnd:String = '">';
			var tegAll:String = '';
		
			tmp = rawData.split(toReplace);
			tegAll = tegBegin + classNames[0] + tegEnd;
		
			for(var i:int = 0; i < tmp.length; i++){
				htmlStr += tegAll + tmp[i]
				tegAll = '</td>' + tegBegin + classNames[i+1] + tegEnd;
				}
		}catch(e:Error){
			var errorComponrent:String;
			if(rawData == null){
				errorComponrent = 'rawData';
			}else{
				errorComponrent = 'classNames';
			}

			msgString = errorComponrent + ': ' + e.message
			messenger.message(msgString, modelEvent.ERROR_MARK);
		}
			
		return htmlStr;
	};
	
	private function getRowsNames(stage:CommunityStage):String{
		var names:String;
		names = stage.getCellContent(0,0, 'only_names');
		return names;
	};
	
	private function downloadFile():void{
		var fileRef:FileReference = new FileReference();
		fileRef.save(fileData,'dump.htm'); 
		
	};
}
}
