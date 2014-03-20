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
    
    var degrees:Array[int];
    var links:ArrayList[int];
    var weights:ArrayList[double];

    var startIndex:int; //for iterating links and weights
    var deg:int;

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

        //degrees = new ArrayList[int]();
        degrees = new Array[int](nb_nodes+1);
        links = new ArrayList[int]();
        weights = new ArrayList[double]();

        //degrees.clear();
        links.clear();
        weights.clear();
        nb_links = edgeNum;

        val finput = new File(filename);
        var keys:Array[String];
        var num:Int = 0; //iterate the edges num from the same src node
        var frontID:String = "0";
        var index:int = 0;
        
        for(line in finput.lines())
        {
            keys = line.split(" ");
            if(frontID.equals(keys(0)))
                {
                    num = num + 1;
                }
            else
                {   
                    if( index != 0 )
                        degrees(index) = ( num + degrees(index-1));
                    else
                        degrees(index) = ( num );
                    num = 1;
                    frontID = keys(0);
                    index++;
                }
            links.add(int.parse(keys(1)));
            if(type_file != 0)
                weights.add(double.parse(keys(2)));   
        }
        if(degrees.size != 0)
            degrees(index) = ( num + degrees(index-1));
        else
            degrees(index) = ( num );

        for (var i:int = 0; i <= nb_nodes; i++) {
           total_weight += weighted_degree(i);
        }    
    }

    @Inline @NonEscaping final def weighted_degree( node:int ) 
    {
    //return sum of src node`s linked edge`s weight or the num of linked nodes
    //   val ae = new  AssertionError("Node`s ID not correct!!",(node < nb_nodes));
        
        var res:double = 0.0;

        if(weights.size()==0)
        {
            res = nb_neighbors(node); //it will use lots of time to convert//            
            
        }
        else
        {            
            if (node == 0) 
                startIndex = 0;
            else
                startIndex = degrees(node-1);
            deg = degrees(node);

            for (var i:int = startIndex; i<deg; i++) {
                res += weights(i);
            }      
        }   

        return res;     
    }

     @Inline @NonEscaping final def  nb_neighbors( node:int)
    {
        //return the num of the linked node`s from this node
        //AssertionError("Node`s ID not correct!!",(node < nb_nodes));
        if( node == 0 ) 
            return degrees(0);
        else 
            return degrees( node ) - degrees( node-1 );
    }

    @Inline @NonEscaping final def nb_selfloops( node:int )
    {
        //AssertionError("Node`s ID not correct!!",(node < nb_nodes));
        
        if (node == 0) 
            startIndex = 0;
        else
            startIndex = degrees(node-1);
        deg = degrees(node);
        for (var i:int = startIndex; i<deg; i++)
        {
            if (links(i) == node) {
                if (weights.size()!=0)
                    return weights(i);
                else
                    return 1.0;
            }
        }
        return 0.0;
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