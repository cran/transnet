
import jpsgcs.alun.util.Main;
import jpsgcs.alun.infect.Event;
import jpsgcs.alun.infect.InfSimulator;

public class SimInfection
{
	public static void main(String[] args)
	{
		double transmission = 0.01;
		double importation = 0.1;
		double detection = 0.95;

		double ndays = 100; // Total time in days.
		int capacity = 100;

		double meanstay = 10.0;
		double balance = 0.75;
		double testperpatday = 0.10;

		boolean withinf = false;

		String[] bargs = Main.strip(args,"+inf");
		if (bargs != args)
		{
			args = bargs;
			withinf = true;
		}
		
		bargs = Main.strip(args,"-inf");
		if (bargs != args)
		{
			args = bargs;
			withinf = false;
		}
		
		switch(args.length)
		{
		case 8: testperpatday = new Double(args[7]).doubleValue();

		case 7: balance = new Double(args[6]).doubleValue();

		case 6: meanstay = new Double(args[5]).doubleValue();

		case 5: capacity = new Integer(args[4]).intValue();

		case 4: ndays = new Integer(args[3]).intValue();

		case 3: detection = 1 - new Double(args[2]).doubleValue();
			
		case 2: importation = new Double(args[1]).doubleValue();
		
		case 1: transmission = new Double(args[0]).doubleValue();

		case 0: break;
		
		default:
			System.err.println("Usage: java SimInfection [tranmission rate | 0.01] [imprtation prob | 0.1]"+
				" [false negative prob | 0.05] [days simulated | 100] [number of beds | 100]"+
				" [mean stay | 10.0] [balance | 0.75] [tests per patient per day | 0.1]");
			System.exit(1);
		}

		InfSimulator s = new InfSimulator(transmission,importation,detection,ndays,capacity,meanstay,balance,testperpatday,withinf);

		while (s.hasNext())
		{
			System.out.println(s.nextEvent());
		}
	}
}
