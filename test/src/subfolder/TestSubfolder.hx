package subfolder;

import heaps.localres.LocalRes;
import h2d.Bitmap;

class TestSubfolder extends Bitmap {
    public function new() {
        super();
        var localRes = LocalRes.here();
        this.tile = localRes.res("monhun.png").toTile();
    }
}