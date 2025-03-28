package heaps.localres;

#if !macro
import hxd.res.Resource;
import hxd.fs.LoadedBitmap;
import hxd.fs.FileEntry;
#end
import haxe.macro.Context;
import haxe.io.Bytes;
import haxe.io.Path;
#if macro
import sys.io.File;
import sys.FileSystem;
#end

class LocalRes
{

    public static macro function here() : ExprOf<LocalRes>
    {
        #if macro
        var resPath = Context.resolvePath(Path.directory(Context.getLocalModule().split(".").join("/") + ".hx") + "/res");
        if (!FileSystem.isDirectory(resPath))
        {
            Context.error("res directory not found", Context.currentPos());
            return macro null;
        }
        var files = FileSystem.readDirectory(resPath);
        for (file in files)
        {
            var fullPath = resPath + "/" + file;
            trace("adding " + fullPath);
            Context.addResource(fullPath, File.getBytes(fullPath));
        }
        return macro @:privateAccess new LocalRes($v{resPath});
        #end
        return macro null;
    }
    

    #if !macro

    static var cachedResources : Map<String, hxd.res.Resource> = [];

    var prepend : String;

    function new(prepend:String)
    {
        this.prepend = prepend;
    }
	
	public function exists(name:String) : Bool
    {
        return haxe.Resource.listNames().contains(getResourceName(name));
    }

    public static function scoped(path:String) : LocalRes
    {
        return new LocalRes(path + "/res");
    }

    function getResourceName(name:String) : String
    {
        return this.prepend + "/" + name;
    }

    public function res(name:String) : hxd.res.Any
    {   
        var res = resolveRes(name);
        return hxd.res.Any.fromBytes("", res.entry.getBytes());
	}

	function resolveRes(name:String) : hxd.res.Resource
	{
        var qName = getResourceName(name);
        if (!cachedResources.exists(qName))
        {
            cachedResources[qName] = new Resource(new ComponentEmbeddedFileEntry(qName));
        }
		return cachedResources[qName];
	}
	#end
}

#if !macro

class ComponentEmbeddedFileEntry extends FileEntry
{
    var data : String;
    var bytes : haxe.io.Bytes;

    public function new(data)
    {
        this.name = data;
        this.data = data;
    }

    function init()
    {
        if (bytes == null) {
            bytes = haxe.Resource.getBytes(data);
            if (bytes == null) throw "Missing resource " + data;
        }
    }

    override function getBytes() : haxe.io.Bytes
    {
        if (bytes == null)
            init();
        return bytes;
    }

    override function readBytes(out:haxe.io.Bytes, outPos:Int, pos:Int, len:Int) : Int
    {
        if (bytes == null)
            init();
        if (pos + len > bytes.length)
            len = bytes.length - pos;
        if (len < 0) len = 0;
        out.blit(outPos, bytes, pos, len);
        return len;
    }

    override function load(?onReady:Void -> Void) : Void
    {
        #if js
        if (onReady != null) haxe.Timer.delay(onReady, 1);
        #end
    }

    override function loadBitmap(onLoaded:LoadedBitmap -> Void) : Void
    {
        #if js
        
        var rawData = null;
        for (res in @:privateAccess haxe.Resource.content)
            if (res.name == data)
            {
                rawData = res.data;
                break;
            }
        if (rawData == null) throw "Missing resource " + data;
        var image = new js.html.Image();
        image.onload = function(_)
        {
            onLoaded(new LoadedBitmap(image));
        };
        var extra = "";
        var bytes = (rawData.length * 6) >> 3;
        for (i in 0...(3-(bytes*4)%3)%3)
            extra += "=";
        image.src = "data:image/" + extension + ";base64," + rawData + extra;
        #else
        throw "TODO";
        #end
    }

    override function get_isDirectory()
    {
        return false;
    }

    override function exists(name:String)
    {
        return false;
    }

    override function get_size()
    {
        init();
        return bytes.length;
    }
}
#end