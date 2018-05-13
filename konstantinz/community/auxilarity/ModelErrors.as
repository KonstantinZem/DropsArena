package konstantinz.community.auxilarity{
	public class ModelErrors{
		public var unstableWarning:String = 'The program can work unstably'//Когда есть угроза нестабильной работы программы 
		public var tooSmall:String = 'The value of the variable is too small.';
		public var varIsIncorrect:String = 'Value of variable is incorrect or undefined in config file'
		public var defaultValue:String = 'Variable will leave in default value'
		public var varNotSet:String = 'Variable can not be set'
		public var paramError:String = 'One or more parameters are undefined ore incorrect';
		public var fileNotFound:String = 'File not found'
		public var idUndefined:String = 'The name of object (id) is undefined'
		public var pluginStartAlong:String = 'Plugin start along, but must loaded by comunity main program'
		public var indExemplarNotExist:String = 'Trying to operate with non exist individual exemplar'
		
		function ModelErrors(){}
		
		}
	}
