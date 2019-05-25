package com.redhat.developer.demos;

import org.eclipse.microprofile.config.inject.ConfigProperty;

import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;

@Path("/")
public class GreeterResource {

  @Inject
  GreetingService greetingService;

  @Inject
  @ConfigProperty(name = "MESSAGE_PREFIX", defaultValue = "Hi")
  String messagePrefix;

  @GET
  @Produces(MediaType.TEXT_PLAIN)
  @Path("/")
  public String greet() {
    return greetingService.greet(messagePrefix);
  }

  @POST
  @Consumes(MediaType.APPLICATION_JSON)
  @Produces(MediaType.TEXT_PLAIN)
  @Path("/")
  public String eventGreet(String cloudEventJson) {
    return greetingService.eventGreet(cloudEventJson);
  }

  @GET
  @Produces(MediaType.TEXT_PLAIN)
  @Path("/healthz")
  public String health() {
    return "OK";
  }
}
