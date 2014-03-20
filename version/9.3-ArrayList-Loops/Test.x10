import x10.util.*;
import x10.lang.*;

public class Test 
{

	public static def main(Array[String]) 
	{
    	val timer = new Timer();
        var size:int = 100;
        //var i:Array[int] = new Array[int](size); 
        var d:ArrayList[double] = new ArrayList[double](size);
        
        var startCompute:Long = timer.milliTime();
        for (var index:int=0; index<size; index++) 
        {
                d(index) = 3.0;
            
        }

        var dd:Array[double] = d.toArray();
        for (var i:int = 0; i<dd.size; i++) {
            Console.OUT.println("dd("+i+")= " + dd(i));
        }

        var endCompute:Long = timer.milliTime();
        Console.OUT.println("It used "+(endCompute-startCompute)+"ms to Convert");
    }
}
