package com.example.calculator;

import com.example.calculator.exception.DivideByZeroException;
import com.example.calculator.service.CalculatorService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("CalculatorService — unit tests")
class CalculatorServiceTest {

    private CalculatorService service;

    @BeforeEach
    void setUp() {
        service = new CalculatorService();
    }

    @Test
    @DisplayName("add — basic")
    void addBasic() {
        assertEquals(5.0, service.add(2, 3), 1e-9);
    }

    @Test
    @DisplayName("add — negatives")
    void addNegatives() {
        assertEquals(-1.0, service.add(-4, 3), 1e-9);
    }

    @Test
    @DisplayName("subtract — basic")
    void subtractBasic() {
        assertEquals(1.0, service.subtract(5, 4), 1e-9);
    }

    @Test
    @DisplayName("multiply — basic")
    void multiplyBasic() {
        assertEquals(12.0, service.multiply(4, 3), 1e-9);
    }

    @Test
    @DisplayName("multiply — by zero")
    void multiplyByZero() {
        assertEquals(0.0, service.multiply(100, 0), 1e-9);
    }

    @Test
    @DisplayName("divide — basic")
    void divideBasic() {
        assertEquals(2.5, service.divide(5, 2), 1e-9);
    }

    @Test
    @DisplayName("divide — by zero throws DivideByZeroException")
    void divideByZeroThrows() {
        DivideByZeroException ex = assertThrows(
                DivideByZeroException.class,
                () -> service.divide(10, 0));
        assertEquals("Cannot divide by zero", ex.getMessage());
    }
}
