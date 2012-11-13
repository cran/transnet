
import jpsgcs.alun.infect.InfectionSampler;
import jpsgcs.alun.infect.OneUnitSampler;
import jpsgcs.alun.infect.Event;
import jpsgcs.alun.util.InputFormatter;
import jpsgcs.alun.util.Main;
import jpsgcs.alun.util.Monitor;
import java.util.ArrayList;
import java.util.Collection;

public class Infection
{
	public static void main(String[] args)
	{
		try
		{
			Monitor.quiet(false);
			Monitor.show("Startup ");
			
			int repsperday = 1;
			double nsims = Double.MAX_VALUE;
			boolean show = false;
			boolean max = false;

			String[] bargs = Main.strip(args,"-v");
			if (bargs != args)
			{
				show = true;
				args = bargs;
			}

			bargs = Main.strip(args,"-m");
			if (bargs != args)
			{
				max = true;
				args = bargs;
			}

			switch(args.length)
			{
			case 2: repsperday = new Integer(args[1]).intValue();

			case 1: nsims = new Integer(args[0]).intValue();

			case 0: break;

			default:
				System.err.println("Usage: java Infection [n_sims] [intervalsperday] < input > output");
			}

			InputFormatter f = new InputFormatter();

                	ArrayList<Event> c = new ArrayList<Event>();
                	while (f.newLine())
			{
				Event e = Event.read(f,repsperday);
				if (e != null)
                        		c.add(e);
			}

			System.err.println("Read data. Setting up sampler.");
			
			InfectionSampler inf = new OneUnitSampler(c,show,1.0/repsperday);
		
			System.err.println("Parameter values will be output in the following order:");
			for (String s : inf.parNames())
				System.err.print(s+"\t");
			System.err.println();
		
			Monitor.show("Sampling");

			for (int i=1; i<=nsims; i++)
			{
				double[] res = inf.run(max);

				for (int j=0; j<res.length; j++)
				{
					System.out.print("\t"+res[j]);
					if ( (j+1) % inf.nParameters() == 0)
						System.out.println();
				}
				
				System.err.print(".");
				if (i % 100 == 0)
					System.err.println();
			}

			System.err.println();
			Monitor.show("Done    ");
		}
		catch (Exception x)
		{
			x.printStackTrace();
		}
	}
}
