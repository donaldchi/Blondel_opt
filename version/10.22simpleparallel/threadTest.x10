import x10.util.*;
import x10.compiler.*;


public class threadTest 
{
    var A:Array[double]; 
    var B:Array[double];
    var C:Array[double]; 
    public def this()
    {
        A = new Array[double](100000);
        B = new Array[double](100000);
        C = new Array[double](100000, 0);
    }
    public  def sum(start:int, end:int)
    {
        //var sum:double;
        for (var i:int=start; i<end; i++) {
            C(i) = A(i) + B(i);
        }
        //return sum;
    }
   public static def main(args:Array[String]) 
   {

        var test:threadTest = new threadTest();
        var t:Timer = new Timer();
        var start_t:Long = t.nanoTime();
        for (var i:int=0; i<100000; i++) 
        {
            test.A(i) = 10.5;
            test.B(i) = 17.6;
        }

        var nprocs:int = Int.parse(args(0));
        var band:int = 100000/nprocs;
        val num:int = nprocs-1;
        finish{
            for (var i:int=0; i<nprocs; i++) {
                val threadId:int = i;
                val startIndex:int = i*band;
                val endIndex:int = (i+1)*band;
                async{
                    if (threadId!=num) {
                        test.sum(startIndex, endIndex);           
                    }
                    else
                        test.sum(startIndex, 100000);        
                }
            }
        }
        
        
        var sum:double=0.0;
        for (var i:int=0; i<test.C.size; i++) {
            sum += test.C(i);
        }
        var end_t:Long = t.nanoTime();
        Console.OUT.println("sum = " + sum);
        Console.OUT.println("Time = " + (end_t - start_t) + " ns ");
   }
}
