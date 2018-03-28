﻿// Author: Konstantin Zemoglyadchuk konstantinz@bk.ru
// Copyright (C) 2017 Konstantin Zemoglyadchuk
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

package{
    
    import flash.display.Sprite
	import flash.events.TimerEvent; 
	import flash.events.Event; 
	import flash.utils.Timer;
	import konstantinz.community.comStage.*
	import konstantinz.community.auxilarity.*
   
    public class main extends Sprite{
		
		private var stgHeight:int;
		private var stgWidth:int;
		
		private var versionText:Sprite
		private var debugLevel:String;
		private var msgStreeng:String;
		
		public var configuration:ConfigurationContainer;
		public var commStage:*
		public var plugins:Sprite;
		public var individuals:Array;
		public var model:Sprite

		public function main(){
			
			stgHeight = parent.stage.stageHeight;
			stgWidth = parent.stage.stageWidth;
			configuration = new ConfigurationContainer();
			configuration.addEventListener(ConfigurationContainer.LOADED, init);//
			configuration.addEventListener(ConfigurationContainer.LOADING_ERROR, init)//Если не найдем конфигурационного файла, все равно загружаем программу дальше
			
			model = new Sprite();
			this.addChild(model)
        }
        

		private function init(e:Event):void{
			var initPosition:String;//Каким образом будут добавлятся первые особи
			var intX:int = 0//Первоначальная координата по x
			var intY:int = 0//Первоначальная координата по y
			debugLevel = configuration.getOption('main.debugLevel'); //Нужно ли отображать отладочную информацию
			
			versionText = new myVersion('0.41',debugLevel)
			
			initPosition = configuration.getOption('main.initPosition')
			model.addChild(versionText)
			
			versionText.x = 10
			versionText.y = 0

			commStage = new CommunityStage(stgHeight+10,stgWidth+20,configuration);
			model.addChild(commStage);
			commStage.x = 10
			commStage.y = 20
			commStage.scaleX = 0.9
			commStage.scaleY = 0.9
			individuals = new Array();
						
			switch(initPosition){//Помещаем первых особей по разным схемам, согласно конфигу
				case 'left-top':
					intX = 0;
					intY = 0;
					addInitIndividuals(intX,intY);
				break;
				
				case 'left-bottom':
					intX = commStage.chessDesk.length-1;
					intY = 0;
					addInitIndividuals(intX,intY);
				break;
				
				case 'right-top':
					intX = 0;
					intY = commStage.chessDesk[1].length-1;
					addInitIndividuals(intX,intY);
				break;
				
				case 'right-bottom':
					intX = commStage.chessDesk.length-1;
					intY = commStage.chessDesk[0].length-1;
					trace(intX + ' ' + intY)
					addInitIndividuals(intX,intY);
				break;
				
				case 'center':
					intX = commStage.chessDesk.length/2;
					intY = commStage.chessDesk[0].length/2;
					addInitIndividuals(intX,intY);
				break;
				
				case 'random':
					rndAddInitIndividuals();
				break;
				
				default:
					addInitIndividuals(0,0);
				}
			
			
			
			if(configuration.getOption('main.pluginEnable')=='true'){
				plugins = new PluginLoader(configuration)
				model.addChild(plugins);
				msgStreeng = 'Plugins are anebled'
				
			}else{
				msgStreeng = 'Plugins are disabled'
				}
			configuration.removeEventListener(ConfigurationContainer.LOADED, init);
			debugMsg(msgStreeng)
		}
		
		private function addInitIndividuals(indX:int, indY:int):void{//Добавляем первых особей
			
			for (var i:int = 0; i< int(configuration.getOption('main.indQuntaty')); i++){
				individuals[i] = new Individual(this,commStage.chessDesk,configuration,i,indX,indY);
				
				commStage.addChild(individuals[i])
				individuals[i].IndividualEvent.addEventListener(ModelEvent.MATURING, addNewIndividuals);
			}
			
			}
			
		private function rndAddInitIndividuals():void{//Добавляем первых особей в случайных позициях
			
			var indXRnd : int
			var indYRnd : int
			
			var chessDeskLengthX:int = commStage.chessDesk.length - 1
			var chessDeskLengthY:int = commStage.chessDesk[1].length - 1
			
			for (var i:int = 0; i< int(configuration.getOption('main.indQuntaty')); i++){
				indXRnd = Math.round(Math.random() * chessDeskLengthX)
				indYRnd = Math.round(Math.random() * chessDeskLengthY)
				
				individuals[i] = new Individual(this,commStage.chessDesk,configuration,i,indXRnd,indYRnd);
				
				commStage.addChild(individuals[i])
				individuals[i].IndividualEvent.addEventListener(ModelEvent.MATURING, addNewIndividuals);
			}
			
			}
		
		private function addNewIndividuals(e:Event):void {

			var startPos:int = this.individuals.length;
			var stopPos:int = startPos + int(configuration.getOption('main.offspringsQuant'));
				
				for(var i:int = startPos;i<stopPos;i++){
					var newX:int = e.target.currentChessDeskI;
					var newY:int = e.target.currentChessDeskJ;
					individuals[i] = new Individual(this,commStage.chessDesk, configuration, i,newX,newY);
					commStage.addChild(individuals[i])
					individuals[i].IndividualEvent.addEventListener(ModelEvent.MATURING, addNewIndividuals);
				}
		}
		
		private function debugMsg(msg:String):void{
			if(debugLevel=='true'){
				trace(msg);
			}
			}

    }
}