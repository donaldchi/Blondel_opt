import x10.util.*;


public class Convert 
{
    var do_renumber:boolean = false;
    var infile:String = null;
    var outfile:String = null;
    var outfile_w:String = null;
    var type_file:int = 0; //0:unweighted graph data, non-zero:weighted graph data
    var maxNode:int = 0;

	public static def main(args:Array[String]) 
	{
    	
        Console.OUT.println("Start Convert!!");
        var con:Convert = new Convert();
        con.infile = args(0);
        con.outfile = args(1);

        con.outfile_w = args(1).substring(0, args(1).indexOf(".bin"))+"_w.bin";
        con.maxNode = Int.parse(args(2));
        if (args.size>3 && args(3) == "-r") {
            con.do_renumber = true;
        }
        if (args.size>4 && args(4) == "-w") {
            con.type_file = 1;
        }
        var g:Graph = new Graph(con.infile, con.type_file, con.maxNode);

        /*if (do_renumber) {
            g.renumber(type_file);
        }*/
        g.display_binary(con.outfile, con.outfile_w, con.type_file);
    }
}
