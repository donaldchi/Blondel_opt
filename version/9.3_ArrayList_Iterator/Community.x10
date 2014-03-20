import x10.util.*;
import x10.util.ArrayList;

public class Community {

	var g:Graph;
	var size:int;
	
	var neigh_weight:Array[double];
	var neigh_pos:Array[int];
	var neigh_last:int;
	
	var n2c:Array[int];
	var inside:Array[double];
	var inside_tmp:Array[double];
	var tot:Array[double];

	var nb_pass:int;
	var min_modularity:double;

	var totc:double;
	var degc:double;
	var m2:double;
	var dnc:double;

	var q:double = 0.0;
	var i:int = 0; //using for iterating in for loops

	public def this(){  }
	
	public def this(gc:Graph, passTimes:int, precision:double, inside_tmp:Array[double])
	{  //using when reset graph, precision == minm(in c++ version)
		g = gc;
		size = g.nb_nodes-1;

		neigh_weight = new Array[double](size+1,-1.0);
		neigh_pos = new Array[int](size);
		neigh_last = 0;

		n2c = new Array[int](size+1);
		inside = new Array[double](size+1);
		tot = new Array[double](size+1);

		for ( i=0; i <= size; i++) {
			n2c(i) = i;
			tot(i) = g.weighted_degree(i);
			inside(i) = inside_tmp(i);
		}

		nb_pass = passTimes;
		min_modularity = precision;
		m2 = g.total_weight;

	}

	public def this( filename:String, type_file:int, maxNode:int, edgeNum:double, passTimes:int, precision:double) 
	{ //if passTimes = -1, it will run until be stopped Naturally， or else run the setted passTimes   
		g = new Graph(filename, type_file, maxNode, edgeNum);
		size = g.nb_nodes;


		neigh_weight = new Array[double](size+1,-1.0);
		neigh_pos = new Array[int](size);
		neigh_last = 0;

		n2c = new Array[int](size+1);
		inside = new Array[double](size+1);
		tot = new Array[double](size+1);

		for ( i=0; i <= size; i++) {
			
			n2c(i) = i;
			tot(i) = g.weighted_degree(i);
			inside(i) = g.nb_selfloops(i);
		}
		nb_pass = passTimes;
		min_modularity = precision;
		m2 = g.total_weight;

	}

	public def modularity()
	{

		q = 0.0;
		for (i=0; i <= size; i++) {
			if(tot(i)>0)
				q += inside(i)/m2 - (tot(i)/m2)*(tot(i)/m2);
		}

		return q;
	}

	public def neigh_comm( node:int )
	{

		for ( i=0; i<neigh_last; i++) 
		{
			neigh_weight(neigh_pos(i)) = -1.0;
		}
		neigh_last = 0;

		var p:Pair[Iterator[int],Iterator[double]] = g.neighbors(node);            

		neigh_pos(0)=n2c(node);

		neigh_weight(neigh_pos(0)) = 0;
		neigh_last = 1;

		var neigh:int;
		var neigh_comm:int;
		var neigh_w:double;

		while(p.first.hasNext()){
			
			neigh = 0;
			neigh_comm = 0;
			neigh_w = 0.0;

			neigh = p.first.next();
			neigh_comm = n2c(neigh);
			neigh_w = (g.weights.size()==0)?1.0:p.second.next();
			
			if (neigh!=node) 
			{
				if (neigh_weight(neigh_comm)==-1.0) 
				{
					neigh_weight(neigh_comm) = 0.0;
					neigh_pos(neigh_last++) = neigh_comm;
				}
				neigh_weight(neigh_comm) += neigh_w;
			}			
		}        
	}

	public def remove( node:int, comm:int, dnodecomm:double)
	{
		//AssertionError("Node`s ID not correct!!",(node < size));
		tot(comm) -= g.weighted_degree(node);
		inside(comm) -= 2*dnodecomm + g.nb_selfloops(node);
		n2c(node) = -1;
	}

	public def insert( node:int, comm:int, dnodecomm:double)
	{
		//AssertionError("Node`s ID not correct!!",(node < size));
		tot(comm) += g.weighted_degree(node);
		inside(comm) += 2*dnodecomm + g.nb_selfloops(node);
		n2c(node) = comm;
	}

	public def modularity_gain( node:int, comm:int, dnodecomm:double, w_degree:double)
	{
		//AssertionError("Node`s ID not correct!!",(node < size));
		//if (node == comm) return 0.0;
		totc = 0.0;
		degc = 0.0;
		dnc = 0.0; 
		
		totc = tot(comm);
		degc = w_degree;
		dnc = dnodecomm;
		return (dnc - totc*degc/m2);
	}

	public def one_level( )
	{
		//Console.OUT.println("in one_level");
		//val timer = new Timer();

		var improvement:boolean = false;
		var nb_moves:int;
		var nb_pass_done:int = 0;

		var new_mod:double = modularity();
		/*var startCompute:Long = timer.milliTime();
            
        var new_mod:double = modularity();

        var endCompute:Long = timer.milliTime();
		Console.OUT.println("It used "+(endCompute-startCompute)+"ms to Compute modularity");*/
		

		var cur_mod:double = new_mod;
		var random_order:Array[int] = new Array[int](size+1);
		var r:Random = new Random();

		for ( i = 0; i<=size; i++) {
			random_order(i) = i;
		}

/*		var rand_pos:int;
		var tmp:int;

		for ( i = 0; i<=size; i++) {
			rand_pos = r.nextInt( size );
			tmp = random_order(i);
			random_order(i) = random_order(rand_pos);
			random_order(rand_pos) =tmp;
		}*/

		var node:int;
		var node_comm:int;
		var w_degree:double;
		var best_comm:int;
		var best_nblinks:double = 0.0;
		var best_increase:double = 0.0;
		var increase:double = 0.0;


		do
		{ //Console.OUT.println("nb_pass_done = " + nb_pass_done);
			cur_mod = new_mod;
			nb_moves = 0;
			nb_pass_done++;

			//var startCompute:Long = timer.milliTime();
			
			for (var node_tmp:int=0; node_tmp<=size;  node_tmp++) {
				node = random_order(node_tmp);
				node_comm = n2c(node);
				w_degree = g.weighted_degree(node);
				
				//var startCompute1:Long = timer.milliTime();
				neigh_comm(node);
				//var endCompute1:Long = timer.milliTime();
				//Console.OUT.println("It used "+(endCompute1-startCompute1)+"ms to preDeal");

				//var startCompute2:Long = timer.milliTime();
				remove(node, node_comm, neigh_weight(node_comm));
				//var endCompute2:Long = timer.milliTime();
				//Console.OUT.println("It used "+(endCompute2-startCompute2)+"ms to remove");

 				best_comm = node_comm;
 				best_nblinks = 0.0;
 				best_increase = 0.0;

 				//var startCompute3:Long = timer.milliTime();
 				for ( i=0; i<neigh_last; i++) {
 					increase = modularity_gain(node, neigh_pos(i), neigh_weight(neigh_pos(i)), w_degree);

 					if ((increase > best_increase)) {
 						best_comm = neigh_pos(i);
 						best_nblinks = neigh_weight(neigh_pos(i));
 						best_increase = increase;
 					}	
 				}
 				//var endCompute3:Long = timer.milliTime();
				//Console.OUT.println("It used "+(endCompute3-startCompute3)+"ms to select");

 				//var startCompute4:Long = timer.milliTime();
 				insert(node, best_comm, best_nblinks);
 				//var endCompute4:Long = timer.milliTime();
				//Console.OUT.println("It used "+(endCompute4-startCompute4)+"ms to insert");

 				if (best_comm!=node_comm) {
 					nb_moves++;
 				}
			}
			//var endCompute:Long = timer.milliTime();
			//Console.OUT.println("It used "+(endCompute-startCompute)+"ms to one phase");



			new_mod = modularity();
			if (nb_moves>0) {
				improvement = true;
			}
			
		}while(nb_moves>0 && (new_mod-cur_mod)>min_modularity);

		return improvement;
	}

	public def resetCom()
	{
		var node:int;

		var renumber:Array[int] = new Array[int](size+1, -1);
		
		for (node=0; node<=size; node++) {
			renumber(n2c(node)) = 0;
		}

		var finalCount:int = 0;

		for (i=0; i<=size; i++) {
			if (renumber(i)!=-1) {
				renumber(i)=finalCount;
				finalCount++;
			}
		}
		//Compute communities
		var comm_nodes:Array[ArrayList[int]] = new Array[ArrayList[int]](finalCount);
		inside_tmp = new Array[double](finalCount);

		for ( i = 0; i<finalCount; i++) {
			comm_nodes(i) = new ArrayList[int]();
			inside_tmp(i) = 0.0;
		}

		
		var inside_w:double = 0.0;

		for (node=0; node<=size; node++) 
		{
			//Console.OUT.println("match: " + renumber(n2c(node)) + "-");
			comm_nodes(renumber(n2c(node))).add(node);
			inside_tmp(renumber(n2c(node))) += inside(node);
		}

		for ( i = 0; i<finalCount; i++) {
			inside_w += inside_tmp(i);
		}
		
		var g2:Graph = new Graph();
		g2.nb_nodes = comm_nodes.size;
		g2.degrees = new Array[int](comm_nodes.size+1);

		var comm_deg:int = comm_nodes.size;

		for (var comm:int=0; comm<comm_deg; comm++) 
		{
			var m:HashMap[int, double] = new HashMap[int, double]();
			var comm_size:int = comm_nodes(comm).size();

			for ( node = 0; node<comm_size; node++) 
			{
				
				var p:Pair[Iterator[int],Iterator[double]] = g.neighbors(comm_nodes(comm)(node));
				
				while(p.first.hasNext())
				{

					var neigh:int = p.first.next();
					var neigh_comm:int = renumber(n2c(neigh));
					var neigh_weight:double = (g.weights.size()==0)?1.0:p.second.next();
					
					if(!m.containsKey(neigh_comm))
					{
						m.put(neigh_comm, neigh_weight);
					}
					else
					{
						var vbWeight:Box[double] = m.get(neigh_comm);
						neigh_weight = neigh_weight + vbWeight.value;
						m.remove(neigh_comm);
						m.put(neigh_comm, neigh_weight);
					}
				}
								
			}

			g2.degrees(comm) = (comm==0)?m.size():g2.degrees(comm-1)+m.size();
			g2.nb_links += m.size();

			var set:Set[int] = m.keySet();
			var it:Iterator[int] = set.iterator();
			while(it.hasNext())
			{
				var id:int = it.next();
				var weight:Box[double] = m.get(id);
				g2.total_weight += weight.value;
				g2.links.add(id);
				g2.weights.add(weight.value);
			}
			
		}

		//Console.OUT.println(" g2.total_weight, g2.degrees(comm), g2.nb_links, g2.nb_nodes" + g2.total_weight + ", " + g2.degrees(comm_deg-1) + ", " + g2.nb_links + ", " + g2.nb_nodes);
		return g2;
		
	}

	public static def main(Array[String]) {
        
      Console.OUT.println("Hello world");
    }

}