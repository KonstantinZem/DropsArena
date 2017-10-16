// Author: Konstantin Zemoglyadchuk konstantinz@bk.ru
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
		
		public var options:OptionsContainer;
		public var commStage:*
		public var plugins:Sprite;
		public var individuals:Array;
		public var model:Sprite

		public function main(){
			
			stgHeight = parent.stage.stageHeight;
			stgWidth = parent.stage.stageWidth;
			options = new OptionsContainer();
			options.addEventListener(OptionsContainer.LOADED, init);//
			options.addEventListener(OptionsContainer.LOADING_ERROR, init)//Если не найдем конфигурационного файла, все равно загружаем программу дальше
			model = new Sprite();
			this.addChild(model)
        }
        
        private function addNewIndividuals(e:Event):void {

			var startPos:int = this.individuals.length;
			var stopPos:int = startPos + options.offspringsQuant;
				
				for(var i:int = startPos;i<stopPos;i++){
					var newX:int = e.target.currentChessDeskI;
					var newY:int = e.target.currentChessDeskJ;
					individuals[i] = new Individual(this,commStage.chessDesk,options,i,newX,newY);
					commStage.addChild(individuals[i])
					individuals[i].IndividualEvent.addEventListener(ModelEvent.MATURING, addNewIndividuals);
				}
		}

		private function init(e:Event):void{
			versionText = new myVersion('0.37',options.debugLevel)
			model.addChild(versionText)
			
			versionText.x = 10
			versionText.y = 0

			commStage = new CommunityStage(stgHeight+10,stgWidth+20,options);
			model.addChild(commStage);
			commStage.x = 10
			commStage.y = 20
			commStage.scaleX = 0.9
			commStage.scaleY = 0.9
			individuals = new Array();

			for (var i:int = 0; i<options.indQuntaty; i++){
				individuals[i] = new Individual(this,commStage.chessDesk,options,i);
				commStage.addChild(individuals[i])
				individuals[i].IndividualEvent.addEventListener(ModelEvent.MATURING, addNewIndividuals);
			}
			
			plugins = new PluginLoader(options)
			model.addChild(plugins);
			options.removeEventListener(OptionsContainer.LOADED, init);
		}

    }
}
