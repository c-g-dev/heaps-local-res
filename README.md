# Heaps Local Resources

Split up your Heaps.io resources so they don't all have to be dumped into the same /res folder at the root of the project.

- Have multiple /res folders. 
- Have /res folders scoped to individual packages so that resouces can colocate with their relevant code.


Example structure:

```
/res
/src
    /subfolder
        /res
        EncapsulatedComponent.hx
    GlobalComponent.hx
```

```haxe

class EncapsulatedComponent extends Bitmap {
    public function new() {
        super();
        var localRes = LocalRes.here(); //macro function loads resources in this modules directory
        this.tile = localRes.res("sometile.png").toTile(); //call .res(<filename>) to get the resource from the /res folder in this class file's direcoty
    }
}

```