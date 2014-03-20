import x10.util.*;

public class ComDetect 
{

	public static def main(args:Array[String]) 
	{
    	val timer = new Timer();
        var start:Long = timer.milliTime();
    	var min_modularity:double = 0.000001;
    	var com:Community = new Community(args(0), 0, Int.parse(args(1)), Int.parse(args(2)), -1, min_modularity);    

    	var g:Graph = new Graph();
    	var improvement:boolean = true;
    	var mod:double;
        
        mod = com.modularity();
    	
        var new_mod:double; 
        var level:int = 0;
        var verbose:boolean = true;

        do{
            if(verbose)
            {
                Console.OUT.println("-------------------------------------------------------------------------------------------------------------");
                Console.OUT.println("level: " + level );
                Console.OUT.println("start computation");
                Console.OUT.println("network size:" + com.g.nb_nodes + " nodes, " + com.g.nb_links + " links, " + com.g.total_weight + " weight.");
                level++;
            }
 
            var startCompute:Long = timer.milliTime();
            
            improvement = com.one_level( );

            var endCompute:Long = timer.milliTime();
            
            Console.OUT.println("It used "+(endCompute-startCompute)+"ms to Compute");

            new_mod = com.modularity();

            g = com.resetCom(); //the same role as partition2graph in c++ version

            com = new Community(g, -1, min_modularity, com.inside_tmp);
            if (verbose) 
            {
                Console.OUT.println("mod -> new_mod: " + mod + "->" + new_mod);

            }
            mod = new_mod;
            if (level == 1) 
            {
                improvement = true;    
            }

        }while(improvement);
	
        var end:Long = timer.milliTime();
        Console.OUT.println("It used "+(end-start)+"ms all");

    }
}
