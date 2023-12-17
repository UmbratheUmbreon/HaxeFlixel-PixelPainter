package hscript;

@:access(hscript.Interp)
class InterpIterator
{
	public var min:Int;
	
	public var max:Int;
	
	public inline function new(interp:Interp, min:Dynamic, max:Dynamic):Void
	{
		if (min == null)
			interp.error(ECustom("Null should be Int"));
		
		if (max == null)
			interp.error(ECustom("Null should be Int"));
		
		if (!Std.isOfType(min, Int))
			interp.error(ECustom('${Type.getClassName(Type.getClass(min))} should be Int'));
		
		if (!Std.isOfType(max, Int))
			interp.error(ECustom('${Type.getClassName(Type.getClass(min))} should be Int'));
		
		this.min = min;
		
		this.max = max;
	}
	
	public inline function hasNext():Bool
		return min < max;
	
	public inline function next():Int
		return min++;
}