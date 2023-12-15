package;

class Main extends openfl.display.Sprite
{
	public function new()
	{
		super();
		
		addChild(new flixel.FlxGame(0, 0, PlayState));
	}
}
