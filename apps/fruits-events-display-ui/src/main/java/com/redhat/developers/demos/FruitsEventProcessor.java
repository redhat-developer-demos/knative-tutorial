package com.redhat.developers.demos;

import javax.enterprise.context.ApplicationScoped;

import org.eclipse.microprofile.reactive.messaging.Incoming;
import org.eclipse.microprofile.reactive.messaging.Outgoing;
import org.jboss.logging.Logger;

import io.smallrye.reactive.messaging.annotations.Broadcast;

/**
 * FruitsEventProcessor
 */
@ApplicationScoped
public class FruitsEventProcessor {

    Logger logger = Logger.getLogger(FruitsEventProcessor.class);
    
    @Incoming("fruit-events")
    @Outgoing("fruit-events-stream")
    @Broadcast
    public String processFruitEvent(String feJson ) {
        logger.info("SSE Data:" + feJson);
        return feJson;
    }
    
}