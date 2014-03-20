import x10.util.*;
import x10.lang.*;

public class Test 
{

	public static def main(Array[String]) 
	{
    	val timer = new Timer();
        var size:int = 100;
        //var i:Array[int] = new Array[int](size); 
        var d:Array[double] = new Array[double](size);
        var dd:Array[double] = new Array[double](size);
        var startCompute:Long = timer.milliTime();
        for (var index:int=0; index<size; index++) 
        {
                d(index) = 3.0;
            
        }    
        var endCompute:Long = timer.milliTime();
        Console.OUT.println("It used "+(endCompute-startCompute)+"ms to Convert");

        var startCompute1:Long = timer.milliTime();
        for (var index:int=0; index<size; index++) 
        {
                dd(index) = 3;
        }    
        var endCompute1:Long = timer.milliTime();
        Console.OUT.println("It used "+(endCompute1-startCompute1)+"ms to Convert from int to double");

        var startCompute2:Long = timer.milliTime();
        var ite:Iterable[double];
        ite = d.values();
        var it:Iterator[double];
        it = ite.iterator();
        while(it.hasNext())
        {
            Console.OUT.println("it.next() = " + it.next());
        }


        var endCompute2:Long = timer.milliTime();
        Console.OUT.println("It used "+(endCompute2-startCompute2)+"ms to Convert from int to double");

        d.size


    }
}
