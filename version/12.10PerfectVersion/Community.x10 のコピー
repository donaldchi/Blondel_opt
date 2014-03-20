import x10.util.*;
import x10.util.ArrayList;
import x10.compiler.*;
import x10.util.concurrent.Lock;

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

	//for iterating links and weights
	var startIndex:int = 0; 
	var deg:int = 0;

	//used to compute neighbor
	var neigh:int;
	var neigh_comm:int;
	var neigh_w:double;

	//using in one_level part
	var improvement:boolean = false;
	var nb_moves:int = 0;
	var nb_pass_done:int = 0;
	var new_mod:double = 0.0;
	var cur_mod:double = 0.0;
	var r:Random ;
	var rand_pos:int;
	var tmp:int;
	var node:int;
	var node_comm:int;
	var w_degree:double;
	var best_comm:int;
	var best_nblinks:double = 0.0;
	var best_increase:double = 0.0;
	var increase:double = 0.0;
	//using in reset part
	var renumber:Array[int];
	var finalCount:int = 0;

	var uComList:Array[int];
	var isComUse:boolean = false;
	var loc:Lock = new Lock();
	var tNums:int; //thread numbers;

	

	public def this(){  }

	public def this(filename:String, type_file:int, passTimes:int, precision:double, threadNums:int)
	{
		Console.OUT.println("in Community constructor with binary file");
		g = new Graph(filename, null, type_file);

		tNums = threadNums;
		
		size = g.nb_nodes;
		neigh_weight = new Array[double](size+1,-1.0);
		neigh_pos = new Array[int](size);
		neigh_last = 0;

		n2c = new Array[int](size+1);
		inside = new Array[double](size+1);
		tot = new Array[double](size+1);
		uComList = new Array[int](size+1, -1);

		for ( i=0; i <= size; i++) {
			
			n2c(i) = i;
			tot(i) = g.weighted_degree(i);
			inside(i) = g.nb_selfloops(i);
			uComList(i) = -1;
		}
		nb_pass = passTimes;
		min_modularity = precision;
		m2 = g.total_weight;
	}
	
	public def this(gc:Graph, passTimes:int, precision:double, inside_tmp:Array[double], threadNums:int)
	{  //using when reset graph, precision == minm(in c++ version)
		g = gc;
		size = g.nb_nodes-1;

		tNums = threadNums;

		neigh_weight = new Array[double](size+1,-1.0);
		neigh_pos = new Array[int](size);
		neigh_last = 0;

		n2c = new Array[int](size+1);
		inside = new Array[double](size+1);
		tot = new Array[double](size+1);
		uComList = new Array[int](size+1, -1);

		for ( i=0; i <= size; i++) {
			n2c(i) = i;
			tot(i) = g.weighted_degree(i);
			inside(i) = inside_tmp(i);
			uComList(i) = -1;
		}

		nb_pass = passTimes;
		min_modularity = precision;
		m2 = g.total_weight;
	}

	public def this( filename:String, type_file:int, maxNode:int, edgeNum:int, passTimes:int, precision:double, threadNums:int) 
	{ //if passTimes = -1, it will run until be stopped Naturally， or else run the setted passTimes   
		g = new Graph(filename, type_file, maxNode, edgeNum);
		size = g.nb_nodes;

		tNums = threadNums;


		neigh_weight = new Array[double](size+1,-1.0);
		neigh_pos = new Array[int](size);
		neigh_last = 0;

		n2c = new Array[int](size+1);
		inside = new Array[double](size+1);
		tot = new Array[double](size+1);
		uComList = new Array[int](size+1, -1);

		for ( i=0; i <= size; i++) {
			
			n2c(i) = i;
			tot(i) = g.weighted_degree(i);
			inside(i) = g.nb_selfloops(i);
			uComList(i) = -1;
		}
		nb_pass = passTimes;
		min_modularity = precision;
		m2 = g.total_weight;

	}

	public def modularity()
	{

		q = 0.0;

		var out:double = 0.0;

		for (i=0; i <= size; i++) {
			if(tot(i)>0)
			{
				out = 0.0;
				out = tot(i) - inside(i);
				//q += inside(i)/m2 - (out/m2)*(out/m2);
				q += inside(i)/m2 - (tot(i)/m2)*(tot(i)/m2);
			}	
		}

		return q;
	}

	@Inline public def neigh_comm( node:int)
	{
		
		for ( i=0; i<neigh_last; i++) 
		{
			neigh_weight(neigh_pos(i)) = -1.0;
		}
		neigh_last = 0;

		//var p:Pair[Iterator[int],Iterator[double]] = g.neighbors(node);            

		neigh_pos(0)=n2c(node);

		neigh_weight(neigh_pos(0)) = 0;
		neigh_last = 1;
		
		if (node == 0) 
	        startIndex = 0;
	    else
	        startIndex = g.degrees(node-1);
	    deg = g.degrees(node);
	    for ( i = startIndex; i<deg; i++)
	    {
			neigh = 0;
			neigh_comm = 0;
			neigh_w = 0.0;

			neigh = g.links(i);
			neigh_comm = n2c(neigh);
			neigh_w = (g.weights.size()==0)?1.0:g.weights(i);
			
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

	@Inline public def remove( node:int, comm:int, dnodecomm:double)
	{
		//AssertionError("Node`s ID not correct!!",(node < size));
		tot(comm) -= g.weighted_degree(node);
		inside(comm) -= 2*dnodecomm + g.nb_selfloops(node);
		n2c(node) = -1;
	}

	@Inline public def insert( node:int, comm:int, dnodecomm:double)
	{
		//AssertionError("Node`s ID not correct!!",(node < size));
		tot(comm) += g.weighted_degree(node);
		inside(comm) += 2*dnodecomm + g.nb_selfloops(node);
		n2c(node) = comm;
	}

	@Inline public def modularity_gain( node:int, comm:int, dnodecomm:double, w_degree:double)
	{
		//AssertionError("Node`s ID not correct!!",(node < size));
		//if (node == comm) return 0.0;
		totc = tot(comm);
		degc = w_degree;
		dnc = dnodecomm;
		return (dnc - totc*degc/m2);
	}



	public def one_level( level:int )
	{
		improvement = false;
		nb_moves = 0;
		nb_pass_done = 0;

		new_mod = modularity();

		cur_mod = new_mod;
		var random_order:Array[int] = new Array[int](size+1);
		r = new Random();

		for ( i = 0; i<=size; i++) {
			random_order(i) = i;
		}
		
		for ( i = 0; i<=size; i++) {
			rand_pos = r.nextInt( size );
			tmp = random_order(i);
			random_order(i) = random_order(rand_pos);
			random_order(rand_pos) =tmp;
		}

		do
		{ //Console.OUT.println("nb_pass_done = " + nb_pass_done);
			cur_mod = new_mod;
			nb_moves = 0;
			nb_pass_done++;
			
			//coreCompute(0, size, random_order);
			//var sub_size:int=100;
			//if (size<100) {
			//var sub_size:int = size/2;
			//}
			//var threadNum:int = tNums;
			var band:int = size / tNums;

			//Console.OUT.println("level="+level);
			if (level != 1 || tNums == 1) 
			{
				coreCompute_s(0, size+1, random_order, 0);		
			}
			else{
				finish{
					for (var i:int = 0; i < tNums; i++) {
						val index:int = i;
						val from:int = index*band; 
						val to:int = (index+1)*band;
						async{
							if (index == (tNums-1)) {
								coreCompute(from, size+1, random_order, index);
							}
							else coreCompute(from, to, random_order, index);
						}
					}
				}
			}
		
			new_mod = modularity();
			if (nb_moves>0) {
				improvement = true;
			}
			
		}while(nb_moves>0 && (new_mod-cur_mod)>min_modularity);

		return improvement;
	}
@Inline public def coreCompute_s(startIndex:int, endIndex:int, random_order:Array[int], id:int)
	{	
		Console.OUT.println("use single compute");
		//Console.OUT.println("id = " + id + "start");

		for (var node_tmp:int=startIndex; node_tmp<endIndex; node_tmp++) 
		{	

			//node = node_tmp;
			node = random_order(node_tmp);
			
			node_comm = n2c(node);
			w_degree = g.weighted_degree(node);
			
			neigh_comm(node);

			remove(node, node_comm, neigh_weight(node_comm));

			best_comm = node_comm;
			best_nblinks = 0.0;
			best_increase = 0.0;

			for (   i=0; i<neigh_last; i++) {
				increase = modularity_gain(node, neigh_pos(i), neigh_weight(neigh_pos(i)), w_degree);

				if (increase > best_increase) {
					best_comm = neigh_pos(i);
					best_nblinks = neigh_weight(neigh_pos(i));
					best_increase = increase;
				}
			}
				 
			insert(node, best_comm, best_nblinks);
				
			if (best_comm!=node_comm) {
				nb_moves++;
			}
		}

		//Console.OUT.println("id = " + id + "end!!");	
	}
@Inline public def coreCompute(startIndex:int, endIndex:int, random_order:Array[int], id:int)
	{	
		//Console.OUT.println("id = " + id + "start");
		Console.OUT.println("use double compute");
		var increase:double = 0.0;
		var best_comm:int = 0;
		var best_increase:double = 0.0;
		var best_nblinks:double = 0.0;
		var neigh_last:int = 0;
		//var size:int = endIndex - startIndex+1;
		var neigh_pos:Array[int] = new Array[int](size+1, 0);
		var neigh_weight:Array[double] = new Array[double](size+1, -1.0);
		var start:int;
		var deg:int;
		var node:int;
		var node_comm:int;
		var i:int;

		var isUsable:boolean = true;

		for (var node_tmp:int=startIndex; node_tmp<endIndex; node_tmp++) 
		{	

			node = random_order(node_tmp);
			//node = node_tmp;
			node_comm = n2c(node);

			//Console.OUT.println("node = " + node + " id = " + id);

			var w_degree:double = g.weighted_degree(node);
				
				//neigh_weight.fill(-1.0);
				for ( i = 0; i<neigh_last; i++) 
				{
					neigh_weight(neigh_pos(i)) = -1.0;	
				}
				neigh_last = 0;
				
				
				var neigh:int;
				var neigh_comm:int;
				var neigh_w:double;
				//var p:Pair[Iterator[int],Iterator[double]] = g.neighbors(node);            
				//Console.OUT.println("-----------");
				neigh_pos(0)=n2c(node);

				neigh_weight(neigh_pos(0)) = 0;
				neigh_last = 1;
				

				start = (node==0)?0:g.degrees(node-1);
				/*if (node == 0) 
			        start = 0;
			    else
			        start = g.degrees(node-1);*/
			    deg = g.degrees(node);


			    //Console.OUT.println("before thread  " + id + "  lock!!");
			    loc.lock();
			    for ( i = start; i<deg; i++) 
			    {
					neigh = 0;
					neigh_comm = 0;
					neigh = g.links(i);
					neigh_comm = n2c(neigh);
					//Console.OUT.println("out isComUse, neigh= " + neigh + ", neigh_comm" + neigh_comm + ", node_comm= " + node_comm + ", thread= " + id + ", node= " + node);
					if (neigh_comm ==-1 || uComList(neigh_comm)!=-1) {
						//Console.OUT.println("in isComUse, neigh= " + neigh + ", neigh_comm= " + neigh_comm + ", node_comm= " + node_comm  + ", thread= " + id +  ", node = " + node);
						isComUse = true;
						break;
					}
			    }
			    if (!isComUse) {
			    	uComList(node_comm) = node_comm;
			    	for ( i = start; i<deg; i++) 
				    {
				    	neigh = 0;
						neigh_comm = 0;
						neigh_w = 0.0;
						neigh = g.links(i);
						neigh_comm = n2c(neigh);
						uComList(neigh_comm) = neigh_comm;
				    }

			    }
			    loc.unlock();
			    //Console.OUT.println("after thread " + id + "lock!!");

			    if (isComUse) {
					isComUse = false;
					continue;
				}

			    for (  i = start; i<deg; i++)
			    {
					neigh = 0;
					neigh_comm = 0;
					neigh_w = 0.0;

					neigh = g.links(i);

/*						if (neigh > endIndex || neigh < startIndex) 
					{
						isUsable = false;
						break;
					}*/
					//{
						neigh_comm = n2c(neigh);
						neigh_w = (g.weights.size()==0)?1.0:g.weights(i);
						
						if (neigh!=node) 
						{
							if (neigh_weight(neigh_comm)==-1.0) 
							{
								neigh_weight(neigh_comm) = 0.0;
								neigh_pos(neigh_last++) = neigh_comm;
							}
							neigh_weight(neigh_comm) += neigh_w;
						}		
					//}
			    }
				/*if (!isUsable) {
					isUsable = true;
					continue;
				}*/
			//Console.OUT.println("node_comm=" + node_comm);

			remove(node, node_comm, neigh_weight(node_comm));

			best_comm = node_comm;
			best_nblinks = 0.0;
			best_increase = 0.0;

			for (   i=0; i<neigh_last; i++) {

				increase = modularity_gain(node, neigh_pos(i), neigh_weight(neigh_pos(i)), w_degree);

				if (increase > best_increase) {
					
					if( i!=0 && best_comm != node_comm && best_increase!=0.0) uComList(best_comm) = -1;
					
					best_comm = neigh_pos(i);
					best_nblinks = neigh_weight(neigh_pos(i));
					best_increase = increase;
				}
				if (neigh_pos(i)!=node_comm && neigh_pos(i)!=best_comm) 
				{
					uComList(neigh_pos(i)) = -1;					
				}
			}

			//if (node_comm != best_comm && n2c(best_comm)!=-1) {
								 
			insert(node, best_comm, best_nblinks);
			
			uComList(node_comm) = -1;
			uComList(best_comm) = -1;
			//}
			if (best_comm!=node_comm) {
				nb_moves++;
			}

			/*uComList(node_comm) = -1;
			for (   i=0; i<neigh_last; i++) 
			{
				uComList(neigh_pos(i)) = -1;
			}*/

			//Console.OUT.println("end");
		}

		//Console.OUT.println("id = " + id + "end!!");	
	}

	/*public def setValueParallel(data:Array[int], start:int, end:int)
	{
		for (var i:int=0; i<end; ) {
			
		}

	}*/
	public def resetCom()
	{
		renumber = new Array[int](size+1, -1);
		
		for (node=0; node<=size; node++) {
			renumber(n2c(node)) = 0;
		}

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
		var set:Set[int];
		var it:Iterator[int];
		for (var comm:int=0; comm<comm_deg; comm++) 
		{
			var m:HashMap[int, double] = new HashMap[int, double]();
			var comm_size:int = comm_nodes(comm).size();

			for ( node = 0; node<comm_size; node++) 
			{
				
				if (comm_nodes(comm)(node) == 0) 
		            startIndex = 0;
		        else
		            startIndex = g.degrees(comm_nodes(comm)(node)-1);
		        deg = g.degrees(comm_nodes(comm)(node));
		        for ( i = startIndex; i<deg; i++)
		        {
					neigh = g.links(i);
					neigh_comm = renumber(n2c(neigh));
					neigh_w = (g.weights.size()==0)?1.0:g.weights(i);
					
					if(!m.containsKey(neigh_comm))
					{
						m.put(neigh_comm, neigh_w);
					}
					else
					{
						var vbWeight:Box[double] = m.get(neigh_comm);
						neigh_w = neigh_w + vbWeight.value;
						m.remove(neigh_comm);
						m.put(neigh_comm, neigh_w);
					}
		        }								
			}

			g2.degrees(comm) = (comm==0)?m.size():g2.degrees(comm-1)+m.size();
			g2.nb_links += m.size();

			set = m.keySet();
			it = set.iterator();
			var weight:Box[double];
			while(it.hasNext())
			{
				node = it.next();
				weight = m.get(node);
				g2.total_weight += weight.value;
				g2.links.add(node);
				g2.weights.add(weight.value);
			}
			
		}

		return g2;		
	}

	public def Shell( d:Array[int])
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
                        d(l+h(i)) = d(l);
                    d(l+h(i)) =temp;                
                }    
            }
            i--;
        }
        return d;
    }

	public static def main(Array[String]) {
        
      Console.OUT.println("Hello world");
    }

}