import hxd.Res;
import hxd.App;

class Main extends App
{
    override function init()
    {
        s2d.addChild(new subfolder.TestSubfolder());
        s2d.addChild(new RootFolder());
    }

    static function main()
    {
        hxd.Res.initEmbed();
        new Main();
    }
}