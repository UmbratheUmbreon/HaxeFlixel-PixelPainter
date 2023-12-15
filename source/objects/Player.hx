package objects;

import flixel.FlxG;

import flixel.FlxSprite;

import flixel.util.FlxColor;

class Player extends FlxSprite
{
	public var speed:Float;
	
	public var jumpPower:Float;
	
	var _canJump:Bool;
	
	public function new(?x:Float = 0, ?y:Float = 0, ?width:Int = 10, ?height:Int = 10, ?color:FlxColor = FlxColor.WHITE):Void
	{
		super(x, y);
		
		makeGraphic(width, height, color);
		
		speed = 300;
		
		jumpPower = 240;
		
		_canJump = true;
		
		acceleration.y = 420;
		
		drag.x = 640;
		
		maxVelocity.set(speed, jumpPower);	
	}
	
	override function update(elapsed:Float):Void
	{
		acceleration.x = 0;
		
		if (FlxG.keys.anyPressed([LEFT, A]))
			acceleration.x -= drag.x;
		else if (FlxG.keys.anyPressed([RIGHT, D]))
			acceleration.x += drag.x;

		if (FlxG.keys.anyPressed([UP, W, SPACE]) && _canJump && velocity.y == 0)
			velocity.y = -jumpPower;
		
		super.update(elapsed);
	}
}