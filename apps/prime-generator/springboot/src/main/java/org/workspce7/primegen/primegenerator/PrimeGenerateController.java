package org.workspce7.primegen.primegenerator;

import static java.util.concurrent.TimeUnit.SECONDS;
import java.util.Optional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class PrimeGenerateController {

  private static final Logger LOGGER = LoggerFactory.getLogger(PrimeGenerateController.class);


  @Autowired
  PrimeService primeService;

  @GetMapping("/")
  public ResponseEntity<String> getPrimes(@RequestParam("upto") int upto,
      @RequestParam(name = "sleep", required = false) Optional<Integer> sleepInSeconds,
      @RequestParam(name = "memload", required = false) Optional<Integer> memLoad) {

    LOGGER.info("Query Parameters Upto {} Sleep in seconds {} Memory Load {} ", upto,
        sleepInSeconds, memLoad);

    if (sleepInSeconds.isPresent()) {
      sleepInSeconds(sleepInSeconds.get());
    }

    if (memLoad.isPresent()) {
      loadMemory(memLoad.get());
    }

    if (upto <= 1) {
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(String.format("Value should be greater than 1 but recevied %d", upto));
    }

    int bigPrime = primeService.biggestPrime(upto);

    return ResponseEntity.ok().body(String.valueOf(bigPrime));
  }

  @GetMapping("/healthz")
  public ResponseEntity<String> healthz() {
    return ResponseEntity.ok().body("OK");
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
