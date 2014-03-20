import x10.util.*;
import x10.lang.*;
import x10.io.File;
import x10.io.FileReader;

public class Test 
{

	public static def main(args:Array[String]) 
	{
    	val timer = new Timer();
        var size:int = 100;
        //var i:Array[int] = new Array[int](size); 
        var d:ArrayList[double] = new ArrayList[double](size);
        
        var startCompute:Long = timer.milliTime();
            
        var com:Community = new Community(args(0), 0, -1, 0.000001); 

        var endCompute:Long = timer.milliTime();
        Console.OUT.println("It used "+(endCompute-startCompute)+"ms to Convert");
    }
}
