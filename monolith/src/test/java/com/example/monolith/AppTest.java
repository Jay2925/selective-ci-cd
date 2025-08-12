package com.example.monolith;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class AppTest {
  @Test
  void sumsCorrectly() {
    assertEquals(5, App.sum(2,3));
  }
}
