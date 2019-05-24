package com.example.camel;

import org.apache.camel.component.properties.PropertiesComponent;
import org.apache.camel.main.Main;

/**
 * A Camel Application
 */
public class DownloadSplitCamelApp {

  public static void main(String... args) throws Exception {
    Main main = new Main();
    PropertiesComponent pc = new PropertiesComponent();
    pc.setLocation("application-local.properties");
    main.bind("properties", pc);
    main.addRouteBuilder(new DownloadAndSplit());
    main.run(args);
  }

}

