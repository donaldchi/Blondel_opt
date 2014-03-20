import x10.io.File;
import x10.lang.Error;
import x10.util.*;
import x10.util.ArrayList;
import x10.util.List; 
import x10.lang.*;
import x10.compiler.*;

public class Graph {
    var total_weight:double;
    var nb_nodes:int;
    var nb_links:double;
    var degrees:ArrayList[int];
    var links:ArrayList[int];
    var weights:ArrayList[double];

    public def this()
    {
        links = new ArrayList[int]();
        weights = new ArrayList[double]();
        links.clear();
        weights.clear(); 
    }

    public  def this(var filename:String,var type_file:int,var maxNode:int,var edgeNum:double)
    {  
        nb_nodes = maxNode;

        degrees = new ArrayList[int]();
        links = new ArrayList[int]();
        weights = new ArrayList[double]();

        degrees.clear();
        links.clear();
        weights.clear();
        nb_links = edgeNum;

        val finput = new File(filename);
        var keys:Array[String];
        var num:Int = 0; //iterate the edges num from the same src node
        var frontID:String;
        frontID="0";
        
        for(line in finput.lines())
        {
            keys = line.split(" ");
            if(frontID.equals(keys(0)))
                {
                    num = num + 1;
                }
            else
                {   
                    if(degrees.size() != 0)
                        degrees.add( num + degrees.getLast());
                    else
                        degrees.add( num );
                    num = 1;
                    frontID = keys(0);
                }
            links.add(int.parse(keys(1)));
            if(type_file != 0)
                weights.add(double.parse(keys(2)));
            
        }
        if(degrees.size() != 0)
            degrees.add( num + degrees.getLast());
        else
            degrees.add( num );

        for (var i:int = 0; i <= nb_nodes; i++) {
           total_weight += weighted_degree(i);
        }    
    }

    @NonEscaping final def weighted_degree( node:int ) 
    {
    //return sum of src node`s linked edge`s weight or the num of linked nodes
    //   val ae = new  AssertionError("Node`s ID not correct!!",(node < nb_nodes));
        
        if(weights.size()==0)
        {
            return Double.implicit_operator_as(nb_neighbors(node)); //it will use lots of time to convert//            
        }
        else
        {
            var res:double = 0.0;
            var p:Pair[Iterator[int],Iterator[double]] = neighbors(node);
            while(p.second.hasNext())
                res += p.second.next();
            return res;   
        }        
    }

    @NonEscaping final def nb_neighbors( node:int)
    {
        //return the num of the linked node`s from this node
        //AssertionError("Node`s ID not correct!!",(node < nb_nodes));
        if( node == 0 ) 
            return degrees.get(0);
        else 
            return degrees.get( node ) - degrees.get( node-1 );
    }

    @NonEscaping final def nb_selfloops( node:int )
    {
        //AssertionError("Node`s ID not correct!!",(node < nb_nodes));
        var p:Pair[Iterator[int],Iterator[double]] = neighbors(node);
        while(p.first.hasNext())
        {
            if (p.first.next()==node) {
                if (weights.size()!=0)
                    return p.second.next();
                else
                    return 1.0;
            }
        }
        return 0.0;
    }

    @NonEscaping final def neighbors( node:int)
    {
        //AssertionError("Node`s ID not correct!!",(node < nb_nodes));
        var set:Pair[Iterator[int],Iterator[double]];
            
        if( node == 0 )
            {
                var start:int = 0;
                var end:int = degrees.get(node);
                return set = new Pair[Iterator[int],Iterator[double]](links.subList(start, end).iterator(),weights.subList(start, end).iterator());
            }
        else if ( weights.size()!=0 ) 
            {
                var start:int = degrees.get(node-1);
                var end:int = degrees.get(node);
                return set = new Pair[Iterator[int],Iterator[double]](links.subList(start, end).iterator(), weights.subList(start, end).iterator()); 
            }
        else
            {
                var start:int = degrees.get(node-1);
                var end:int = degrees.get(node);
                return set = new Pair[Iterator[int],Iterator[double]](links.subList(start, end).iterator(), weights.subList(start, end).iterator());
            }

    }
    
    public static def main(args: Array[String]) {
        val timer = new Timer();
        var start:Long = timer.milliTime();
        var fileName:String = "../../Data/BlondelMethod/arxiv.txt";
        val g = new Graph(fileName,0,9376,48214);
        
        var end:Long = timer.milliTime();
        Console.OUT.println("It used "+(end-start)+"ms");
    }
}