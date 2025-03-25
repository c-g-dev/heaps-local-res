import hxd.Res;
import h2d.Bitmap;

class RootFolder extends Bitmap {
    public function new() {
        super();
        this.tile = Res.simplicity.toTile();
    }
}