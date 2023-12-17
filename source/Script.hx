package;

import hscript.*;

class Script
{
	public static var global(default, null):Array<Script> = new Array<Script>();
	
	public var interp(default, null):Interp;
	
	public var parser(default, null):Parser;
	
	@:noCompletion
	var _destroyed(default, null):Bool;
	
	public function new():Void
	{
		global.push(this);
	}
	
	public function doString(s:String, ?preset:Bool = true):Dynamic
	{
		if (_destroyed)
			return null;
		
		interp = new Interp();
		
		parser = new Parser();
		
		if (preset)
			this.preset();
		
		return interp.execute(parser.parseString(s));
	}
	
	public function doFile(file:String, ?preset:Bool = true):Dynamic
	{
		if (_destroyed)
			return null;
		
		#if sys
			if (sys.FileSystem.exists(file))
				return doString(sys.io.File.getContent(file), preset);
			else
				throw "Script.doFile: The file " + file + " doesn't exist!";
		#end
		
		throw "Script.doFile: This function isn't supported on this platform!";
	}
	
	public function call(key:String, args:Array<Dynamic>):Dynamic
	{
		if (_destroyed)
			return null;
		
		if (interp.variables.exists(key))
		{
			if (Reflect.isFunction(interp.variables.get(key)))
				return Reflect.callMethod(this, interp.variables.get(key), args);
			else
				throw "Script.call: The key " + key + " isn't a function!";
		}
		else
			throw "Script.call: The key " + key + " doesn't exist!";
	}
	
	function preset():Void
	{
		if (_destroyed)
			return;
		
		interp.imports.set("Bool", Bool);
		interp.imports.set("Int", Int);
		interp.imports.set("Float", Float);
		interp.imports.set("String", String);
		interp.imports.set("Dynamic", Dynamic);
		interp.imports.set("Array", Array);
		
		interp.imports.set("Math", Math);
		
		interp.imports.set("Json", haxe.Json);
		
		#if sys
			interp.imports.set("FileSystem", sys.FileSystem);
			interp.imports.set("File", sys.io.File);
		#end
		
		interp.imports.set("Interp", Interp);
		interp.imports.set("Parser", Parser);
		
		interp.imports.set("Script", Script);
		
		interp.variables.set("this", this);
		
		parser.allowJSON = true;
		
		parser.allowTypes = true;
		
		parser.allowMetadata = true;
	}
	
	public function destroy():Void
	{
		if (_destroyed)
			return;
		
		interp = null;
		
		parser = null;
		
		if (global.contains(this))
			global.remove(this);
		
		_destroyed = true;
	}
}