import x10.util.*;

public class ComDetect 
{
    var filename:String;
    var maxNode:int;
    var edgeNum:int;

    var it_random:int = 0; //0: randomly iterate, non-zero: sequencially iterate 
    var precision:double = 0.000001; //min_modularity.   
    var type_file:int = 0; // 0: unweighted, 1: weighted
    var passTimes:int = -1;  // -1: detect until be stopped itself, else detect decided times. 

    public  def checkArgs(args:Array[String])
    {
        Console.OUT.println("Check args!");
        if(args.size < 3)
            Console.OUT.println("Not enough Parameter. Input filename, node`s number, edge`s number at least!!");
        filename = args(0);
        maxNode = Int.parse(args(1));
        edgeNum = Int.parse(args(2));

        if(args.size > 3)
        {
            it_random = Int.parse(args(3));
            
            if(args.size > 4)
            {
                precision = Double.parse(args(4));
                
                if(args.size > 5)
                {
                    type_file = Int.parse(args(5));
                    
                    if (args.size > 7) {
                        passTimes = Int.parse(args(6));  
                    }                    
                }               
            }
        }
    }

	public static def main(args:Array[String]) 
	{
    	val timer = new Timer();
        var start:Long = timer.milliTime();
 
        var cd:ComDetect = new ComDetect(); 
        cd.checkArgs(args);

    	var com:Community = new Community(cd.filename, cd.type_file, cd.maxNode, cd.edgeNum, cd.passTimes, cd.precision);    

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

            var startReset:Long = timer.milliTime();
            g = com.resetCom(); //the same role as partition2graph in c++ version
            com = new Community(g, -1, cd.precision, com.inside_tmp);
            var endReset:Long = timer.milliTime();
            Console.OUT.println("It used "+(endReset-startReset)+"ms to Reset");

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
