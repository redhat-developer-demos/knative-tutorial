package com.redhat.developers;

import java.util.Map;
import java.util.logging.Logger;

import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;

@Path("/")
public class LoggerResource {

    private static final Logger LOGGER = Logger.getLogger("eventing-hello");

    @GET
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    @Path("/")
    public String servingEndpoint() {
        LOGGER.info("ExampleResource's @GET method invoked.");
        outputEnv();
        return "{\"hello\":\"world\"}";
    }

    @POST
    @Path("/")
    public Response eventingEndpoint(@Context HttpHeaders httpHeaders,
            String cloudEventJSON) {
        LOGGER.info("ExampleResource's @POST method invoked.");

        outputEnv();


        LOGGER.info("ce-id=" + httpHeaders.getHeaderString("ce-id"));
        LOGGER.info(
                "ce-source=" + httpHeaders.getHeaderString("ce-source"));
        LOGGER.info("ce-specversion="
                + httpHeaders.getHeaderString("ce-specversion"));
        LOGGER.info("ce-time=" + httpHeaders.getHeaderString("ce-time"));
        LOGGER.info("ce-type=" + httpHeaders.getHeaderString("ce-type"));
        LOGGER.info(
                "content-type=" + httpHeaders.getHeaderString("content-type"));
        LOGGER.info("content-length="
                + httpHeaders.getHeaderString("content-length"));

        LOGGER.info("POST:" + cloudEventJSON);

        return Response.status(Status.OK)
                .build();
    }

    private void outputEnv() {
        Map<String, String> env = System.getenv();
        for (String envName : env.keySet()) {
            System.out.format("%s=%s%n", envName, env.get(envName));
        }
    }
}
