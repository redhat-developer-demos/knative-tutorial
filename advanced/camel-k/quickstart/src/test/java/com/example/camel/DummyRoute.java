package com.example.camel;

import org.apache.camel.Body;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.language.XPath;
import org.apache.camel.test.AvailablePortFinder;

public class DummyRoute extends RouteBuilder {

	@Override
	public void configure() throws Exception {


		int port = AvailablePortFinder.getNextAvailable();

		fromF("netty4-http:http://localhost:%d/test", port)
				.convertBodyTo(String.class)
				.to("direct:info");

		from("direct:info")
				.log("Processing Body ${body}")
				.setHeader("dummy").method(this, "normalizeHeader")
				.to("log:info");
	}


	public String normalizeHeader(@XPath(value = "/cartoon/@title") String title) {
		log.info("Cartoon Title:{}", title);
		final String normalized =  title.replaceAll("\\s+", "").toLowerCase() + ".xml";
		log.info("Normalized Title:{}", normalized);
		return normalized;
	}
}
