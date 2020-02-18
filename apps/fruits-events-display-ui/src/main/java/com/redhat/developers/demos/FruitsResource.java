package com.redhat.developers.demos;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZonedDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import javax.inject.Inject;
import javax.validation.Validator;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.jboss.logging.Logger;
import org.reactivestreams.Publisher;

import io.cloudevents.CloudEvent;
import io.cloudevents.v1.*;
import io.cloudevents.v1.http.Unmarshallers;
import io.smallrye.reactive.messaging.annotations.Channel;
import io.smallrye.reactive.messaging.annotations.Emitter;
import io.vertx.core.json.JsonObject;

@Path("/")
public class FruitsResource {

    Logger logger = Logger.getLogger(FruitsResource.class);

    @Inject
    Validator validator;

    @Inject
    @Channel("fruit-events")
    Emitter<String> fruitEventsEmitter;

    @Inject
    @Channel("fruit-events-stream")
    Publisher<String> fruitEvents;

    
    @GET
    @Path("/fruits")
    @Produces(MediaType.SERVER_SENT_EVENTS)
    public Publisher<String> fruitProcessor() {
        return fruitEvents;
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response fruitsHandler(@Context HttpHeaders httpHeaders,  String cloudEventPayload) {
        Map<String, Object> headers = new HashMap<>();
        
        httpHeaders.getRequestHeaders().forEach((k, v) -> {
            headers.put(k, v.get(0));
        });

        logger.info("Headers:"+headers);

        CloudEvent<AttributesImpl, Map> event = Unmarshallers
        .binary(Map.class,validator)
        .withHeaders(() -> headers)
        .withPayload(() -> cloudEventPayload)
        .unmarshal();

        AttributesImpl attrs = event.getAttributes();
        logger.info("Attributes:" + attrs);
        Optional<Map> data = event.getData();
        logger.info("Data:" + data);
        logger.info("Extensions:" + event.getExtensions());

        JsonObject feJson = new JsonObject().put("id", attrs.getId()).put("type", attrs.getType());

        Optional<ZonedDateTime> eventTS = attrs.getTime();

        if (eventTS.isPresent()) {
            LocalTime lt = eventTS.get().toLocalTime();
            feJson.put("time", lt.toString());
        }

        if (data.isPresent()) {
            Map dataValue = data.get();
            logger.info("Data value:" + dataValue);
            feJson.put("name", dataValue.get("name"));
            feJson.put("sugarLevel", ((Map) dataValue.get("nutritions")).get("sugar"));
        }

        fruitEventsEmitter.send(feJson.encodePrettily());

        return Response.ok("{\"ok\": \"TRUE\"}").build();
    }

   
}