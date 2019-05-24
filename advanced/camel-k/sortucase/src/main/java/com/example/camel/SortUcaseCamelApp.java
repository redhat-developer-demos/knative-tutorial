package com.example.camel;

import org.apache.camel.component.properties.PropertiesComponent;
import org.apache.camel.main.Main;

/**
 * A Camel Application
 */
public class SortUcaseCamelApp {

  public static void main(String... args) throws Exception {
    Main main = new Main();
    PropertiesComponent pc = new PropertiesComponent();
    pc.setLocation("application.properties");
    main.bind("properties", pc);
    main.addRouteBuilder(new SortAndUpperCase());
    main.run(args);
  }

}

