package org.workspce7.primegen.primegenerator;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Service;

/**
 * PrimeService Generate biggest prime number based on
 * https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes
 */
@Service
public class PrimeService {

  /**
   * 
   * @param within
   * @return
   */
  public Integer biggestPrime(int within) {
    double sqrtN = Math.sqrt(within);

    // Prime booleans
    boolean[] isPrime = new boolean[within];

    for (int i = 2; i < within; i++) {
      isPrime[i] = true;
    }

    for (int i = 2; i <= sqrtN; i++) {
      if (isPrime[i]) {
        int j = i * i;
        while (j < within) {
          isPrime[j] = false;
          j += i;
        }
      }
    }

    isPrime[2] = true;
    isPrime[3] = true;

    final List<Integer> primes = new ArrayList<>();

    for (int i = 2; i < isPrime.length; i++) {
      if (isPrime[i]) {
        primes.add(i);
      }
    }

    Optional<Integer> optBig = primes.stream().max(Comparator.naturalOrder());

    return optBig.get();
  }
}
