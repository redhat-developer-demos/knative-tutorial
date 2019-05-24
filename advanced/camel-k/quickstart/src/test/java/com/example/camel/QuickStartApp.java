package com.example.camel;

import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.impl.SimpleRegistry;

/**
 * A Camel Application
 */
public class QuickStartApp {


//    public static void main(String... args) throws Exception {
//        Main main = new Main();
//        PropertiesComponent pc = new PropertiesComponent();
//        pc.setLocation("application-local.properties");
//        main.bind("properties",pc);
//        main.addRouteBuilder(new QuickStartRoute());
//        main.run(args);
//    }

	public static void main(String[] args) throws Exception {

		SimpleRegistry registry = new SimpleRegistry();
		DefaultCamelContext context = new DefaultCamelContext(registry);

		try {
			context.disableJMX();
			context.addRoutes(new DummyRoute());
			context.start();
			Thread.sleep(Integer.MAX_VALUE);
		} finally {
			context.stop();
		}

	}


}

