package demo;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

/**
 * https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes
 */
public class Demo {

  public static void main(String[] args) {

    // Start
    int n = 30;

    double sqrtN = Math.sqrt(n);

    // Prime booleans
    boolean[] isPrime = new boolean[n];

    for (int i = 2; i < n; i++) {
      isPrime[i] = true;
    }

    for (int i = 2; i <= sqrtN; i++) {
      if (isPrime[i]) {
        int j = i * i;
        while (j < n) {
          isPrime[j] = false;
          j += i;
        }
      }
    }

    isPrime[2] = true;
    isPrime[3] = true;

    List<Integer> primes = new ArrayList<>();

    for (int i = 2; i < isPrime.length; i++) {
      if (isPrime[i]) {
        primes.add(i);
      }
    }
  }
}
