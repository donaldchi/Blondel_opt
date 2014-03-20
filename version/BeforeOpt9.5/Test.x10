import x10.util.*;
import x10.lang.*;
import x10.io.File;
import x10.io.FileReader;

public class Test 
{

    public def swap(var i:int, var j:int)
    {
        var tmp:int;
        tmp = i;
        i = j;
        j = tmp;
    }

    public def ShellSort( d:Array[int])
    {
        var num:int = d.size;
        var h:Array[int] = new Array[int](20);
        h(0) = 1;
        var i:int = 1;
        var j:int;
        var k:int;
        var l:int;
        var temp:int;
        for (; h(i-1)<num; i++) {
            h(i) = h(i-1)*3+1;
        }
        i-=2;
        while(i>=0)
        {
            for (j=0; j<h(i); j++) 
            {
                for (k=j+h(i); k<d.size; k+=h(i)) 
                {
                    temp = d(k);
                    for (l = k-h(i); l>=0&&temp<d(l); l-=h(i))
                    {
                        d(l+h(i)) = d(l);
                    }    
                    d(l+h(i)) =temp;                
                }    
            }
            i--;
        }
        return d;
    }

    public def BublleSort(d:Array[int])
    {
        var tmp:int;
        for ( var i:int=0; i<(d.size-1); i++) 
        {
            for ( var j:int=0; j<(d.size-1-i); j++) 
            {
                    if (d(j)>d(j+1)) {
                        tmp = d(j);
                        d(j) = d(j+1);
                        d(j+1) = tmp;
                        Console.OUT.println(j);
                        //swap(d(j), d(j+1));
                    }
            }    
        }
        return d;
    }

    public def SelectSort( d:Array[int])
    {
        var i:int;
        var j:int;
        var k:int;
        var temp:int;
        var index:int;;
        
        for(i=0;i<d.size;i++)
        {
            k=i;
            for(j=i+1;j<d.size;j++)
            {
                if(d(j)<d(k))
                    k=j;
            }
            temp=d(k);
            d(k)=d(i);
            d(i)=temp;
        }

        return d;
    }



	public static def main(args:Array[String]) 
	{
    	val timer = new Timer();
        var size:int = 100;
        //var i:Array[int] = new Array[int](size); 
        var d:Array[int] = new Array[int](size);
        var test:Test = new Test();
        var r:Random = new Random();
        
        Console.OUT.println("Before Sort:");
        for (var i:int=0; i<size; i++) 
        {
            d(i) = size - i;
            //d(i) = r.nextInt(size);
           // Console.OUT.println(d(i));    
        }

        var startCompute:Long = timer.milliTime();
            
    
        //d = test.Shell(d);
        //d = test.BublleSort(d);
        //d = test.SelectSort(d); 

        //Console.OUT.println("After Sort:");
        /*for (var i:int=0; i<size; i++) 
        {
            Console.OUT.println(d(i));
        }*/

        var endCompute:Long = timer.milliTime();
        Console.OUT.println("It used "+(endCompute-startCompute)+"ms to Convert");
    }
}
