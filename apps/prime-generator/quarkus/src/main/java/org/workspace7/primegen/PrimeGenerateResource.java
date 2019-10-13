package org.workspace7.primegen;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import static java.util.concurrent.TimeUnit.SECONDS;

@Path("/")
public class PrimeGenerateResource {

  private static final Logger LOGGER = LoggerFactory.getLogger(PrimeGenerateResource.class);


  @Inject
  PrimeService primeService;

  @GET
  @Produces(MediaType.TEXT_PLAIN)
  @Path("/")
  public Response getPrimes(@QueryParam("upto") int upto, @QueryParam("sleep") int sleepInSeconds,
      @QueryParam("memload") int memLoad) {

    LOGGER.info("Query Parameters Upto {} Sleep in seconds {} Memory Load {} ", upto,
        sleepInSeconds, memLoad);

    if (sleepInSeconds != 0) {
      sleepInSeconds(sleepInSeconds);
    }

    if (memLoad != 0) {
      loadMemory(memLoad);
    }

    if (upto <= 1) {
      return Response.serverError()
          .entity(String.format("Value should be greater than 1 but recevied %d", upto)).build();
    }

    int bigPrime = primeService.biggestPrime(upto);

    return Response.ok(bigPrime).build();
  }

  @GET
  @Produces(MediaType.TEXT_PLAIN)
  @Path("/healthz")
  public Response hello() {
    return Response.ok().build();
  }

  /**
   * @param size
   */
  private void loadMemory(int size) {
    byte[] b = new byte[size];
    b[0] = 1;
    b[b.length - 1] = 1;
    LOGGER.info("Allocated memory {} mb", size);
  }

  /**
   * @param seconds
   */
  private void sleepInSeconds(int seconds) {
    try {
      SECONDS.sleep(seconds);
      LOGGER.info("Slept for {} seconds", seconds);
    } catch (InterruptedException e) {

    }
  }
}
